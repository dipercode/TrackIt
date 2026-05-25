import os
import qrcode
import uuid
import re  # Para limpiar el nombre del activo y hacerlo amigable en el código
from io import BytesIO
from django.core.files import File
from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone


def generar_codigo_uuid_temporal():
    return f"PRE-QR-{uuid.uuid4().hex[:12].upper()}"


class Estacion(models.Model):
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True)

    def __str__(self):
        return self.nombre


class Ubicacion(models.Model):
    nombre = models.CharField(max_length=100)
    estacion = models.ForeignKey(
        Estacion,
        on_delete=models.CASCADE,
        related_name="ubicaciones"
    )

    def __str__(self):
        return f"{self.estacion.nombre} - {self.nombre}"


class Activo(models.Model):
    ESTADOS = [
        ('OPERATIVO', 'Operativo'),
        ('DISPONIBLE', 'Disponible'),
        ('TRASLADO', 'Traslado'),
        ('AVERIADO', 'Averiado'),
        ('REPARACIÓN', 'Reparación'),
        ('CALIBRACIÓN', 'Calibración'),
        ('BAJA', 'Baja'),
    ]

    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True)
    
    codigo_qr = models.CharField(
        max_length=255, 
        unique=True, 
        blank=True, 
        default=generar_codigo_uuid_temporal
    )
    
    qr_imagen = models.ImageField(upload_to='activos/qrs/', null=True, blank=True)
    imagen = models.ImageField(upload_to='activos/fotos/', null=True, blank=True)
    certificado_pdf = models.FileField(upload_to='activos/certificados/', null=True, blank=True)
    fecha_calibracion = models.DateField(null=True, blank=True)
    fecha_proxima_verificacion = models.DateField(null=True, blank=True)
    requiere_calibracion = models.BooleanField(default=False)
    
    estado = models.CharField(
        max_length=20, 
        choices=ESTADOS, 
        default='DISPONIBLE' 
    )
    
    ubicacion = models.ForeignKey(
        Ubicacion, 
        on_delete=models.SET_NULL, 
        null=True,
        related_name="activos"
    )
    
    fecha_ultimo_mantenimiento = models.DateField(null=True, blank=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True)

    @property
    def esta_vencido(self):
        if self.requiere_calibracion and self.fecha_proxima_verificacion:
            return self.fecha_proxima_verificacion <= timezone.now().date()
        return False

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        
        # 1. Primer guardado con código temporal seguro
        super().save(*args, **kwargs)

        # 2. Si es nuevo o no posee imagen QR, se genera el código profesional final
        if is_new or not self.qr_imagen:
            # Generamos un identificador único aleatorio corto (8 caracteres)
            uuid_corto = uuid.uuid4().hex[:8].upper()
            
            # Limpiamos el nombre del activo para adaptarlo al código (le quitamos caracteres raros y espacios)
            nombre_limpio = re.sub(r'[^a-zA-Z0-9]', '-', self.nombre.upper())
            nombre_limpio = re.sub(r'-+', '-', nombre_limpio).strip('-')
            
            # Formato Profesional: Prefijo corporativo + Hash Unico + Nombre Normalizado + ID incremental
            self.codigo_qr = f"TRACKIT-{uuid_corto}-{nombre_limpio}-{self.id}"
            
            # Configuramos el generador de QRs
            qr = qrcode.QRCode(
                version=1,
                error_correction=qrcode.constants.ERROR_CORRECT_L,
                box_size=10,
                border=4,
            )
            qr.add_data(self.codigo_qr)
            qr.make(fit=True)

            img = qr.make_image(fill_color="black", back_color="white")
            
            blob = BytesIO()
            img.save(blob, 'PNG')
            
            # Asignamos el archivo de la imagen
            self.qr_imagen.save(f'qr_{self.id}.png', File(blob), save=False)
            
            # Guardamos por segunda vez únicamente los campos generados automáticamente
            super().save(update_fields=['codigo_qr', 'qr_imagen'])

    def __str__(self):
        return f"{self.nombre} [{self.estado}]"


class Movimiento(models.Model):
    TIPO_CHOICES = [
        ('OPERATIVO', 'Operativo'),
        ('DISPONIBLE', 'Disponible'),
        ('TRASLADO', 'Traslado'),
        ('AVERIADO', 'Averiado'),
        ('REPARACIÓN', 'Reparación'),
        ('CALIBRACIÓN', 'Calibración'),
        ('BAJA', 'Baja'),
    ]

    activo = models.ForeignKey(Activo, on_delete=models.CASCADE)

    usuario = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    ubicacion_origen = models.ForeignKey(
        Ubicacion,
        related_name="movimientos_origen",
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    ubicacion_destino = models.ForeignKey(
        Ubicacion,
        related_name="movimientos_destino",
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )

    tipo = models.CharField(max_length=20, choices=TIPO_CHOICES, default='TRASLADO')
    motivo = models.CharField(max_length=255, blank=True, null=True, help_text="Razón breve del movimiento")
    fecha = models.DateTimeField(auto_now_add=True)
    observaciones = models.TextField(blank=True)

    def save(self, *args, **kwargs):
        if not self.pk:
            self.ubicacion_origen = self.activo.ubicacion

        super().save(*args, **kwargs)

        if self.ubicacion_destino:
            self.activo.ubicacion = self.ubicacion_destino
            
            if self.tipo in ['AVERIADO', 'REPARACIÓN', 'OPERATIVO', 'BAJA']:
                self.activo.estado = self.tipo
                
            self.activo.save()

    def __str__(self):
        dest = self.ubicacion_destino.nombre if self.ubicacion_destino else "N/A"
        return f"{self.tipo}: {self.activo.nombre} -> {dest}"