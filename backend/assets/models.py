from django.db import models


class Ubicacion(models.Model):
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True)
    fecha_creacion = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nombre


class Activo(models.Model):
    nombre = models.CharField(max_length=100)
    descripcion = models.TextField(blank=True)
    codigo_identificacion = models.CharField(max_length=50, unique=True)
    ubicacion_actual = models.ForeignKey(
        Ubicacion,
        on_delete=models.SET_NULL,
        null=True,
        related_name='activos'
    )
    fecha_registro = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nombre


class Movimiento(models.Model):
    activo = models.ForeignKey(
        Activo,
        on_delete=models.CASCADE,
        related_name='movimientos'
    )
    ubicacion_origen = models.ForeignKey(
        Ubicacion,
        on_delete=models.SET_NULL,
        null=True,
        related_name='movimientos_salida'
    )
    ubicacion_destino = models.ForeignKey(
        Ubicacion,
        on_delete=models.SET_NULL,
        null=True,
        related_name='movimientos_entrada'
    )
    fecha_movimiento = models.DateTimeField(auto_now_add=True)
    observaciones = models.TextField(blank=True)

    def __str__(self):
        return f"Movimiento de {self.activo} ({self.fecha_movimiento})"
