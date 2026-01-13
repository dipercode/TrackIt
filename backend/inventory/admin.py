from django.contrib import admin
from .models import Estacion, Ubicacion, Movimiento, Activo

admin.site.register(Estacion)
admin.site.register(Ubicacion)
admin.site.register(Movimiento)
admin.site.register(Activo)
