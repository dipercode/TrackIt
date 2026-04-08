from django.db import models
from django.contrib.auth.models import User


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
    codigo_qr = models.CharField(max_length=255, unique=True)
    
    # 🎨 Este campo es el que controla el color del icono en la App
    estado = models.CharField(
        max_length=20, 
        choices=ESTADOS, 
        default='DISPONIBLE' 
    )
    
    ubicacion = models.ForeignKey(
        Ubicacion, 
        on_delete=models.SET_NULL, 
        null=True,
        related_name="activos" # 👈 Útil para hacer consultas inversas
    )
    
    fecha_ultimo_mantenimiento = models.DateField(null=True, blank=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True)

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
    
    # Razón breve que pediremos en el modal de Flutter
    motivo = models.CharField(max_length=255, blank=True, null=True, help_text="Razón breve del movimiento")
    
    fecha = models.DateTimeField(auto_now_add=True)
    
    observaciones = models.TextField(blank=True)

    def save(self, *args, **kwargs):
        # 1. Si es un movimiento nuevo, capturamos el origen ANTES de moverlo
        if not self.pk:
            # El origen es donde está el activo justo ahora
            self.ubicacion_origen = self.activo.ubicacion

        # 2. Guardamos el registro del movimiento
        super().save(*args, **kwargs)

        # 3. Si hay un destino definido, actualizamos el Activo
        if self.ubicacion_destino:
            self.activo.ubicacion = self.ubicacion_destino
            
            # Sincronizar el estado del activo con el tipo de movimiento
            # Si se mueve algo como 'AVERIADO', el estado del activo cambia a 'AVERIADO'
            if self.tipo in ['AVERIADO', 'REPARACIÓN', 'OPERATIVO', 'BAJA']:
                self.activo.estado = self.tipo
                
            self.activo.save()

    def __str__(self):
        dest = self.ubicacion_destino.nombre if self.ubicacion_destino else "N/A"
        return f"{self.tipo}: {self.activo.nombre} -> {dest}"
    