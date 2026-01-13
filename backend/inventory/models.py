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
        ('DISPONIBLE', 'Disponible'),
        ('ASIGNADO', 'Asignado'),
        ('MANTENIMIENTO', 'Mantenimiento'),
    ]

    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True)
    codigo_qr = models.CharField(max_length=255, unique=True)
    estado = models.CharField(max_length=20, choices=ESTADOS, default='DISPONIBLE')
    ubicacion = models.ForeignKey(Ubicacion, on_delete=models.SET_NULL, null=True)
    fecha_ultimo_mantenimiento = models.DateField(null=True, blank=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nombre


class Movimiento(models.Model):
    TIPOS = [
        ('CHECKOUT', 'Salida'),
        ('CHECKIN', 'Devolución'),
    ]

    tipo = models.CharField(max_length=10, choices=TIPOS)
    fecha_hora = models.DateTimeField(auto_now_add=True)
    activo = models.ForeignKey(Activo, on_delete=models.CASCADE)
    usuario = models.ForeignKey(User, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.tipo} - {self.activo.nombre}"
