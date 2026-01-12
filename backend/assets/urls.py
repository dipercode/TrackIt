from django.urls import path
from .views import (
    ActivoListAPIView,
    UbicacionListAPIView,
    MovimientoListAPIView
)

urlpatterns = [
    path('activos/', ActivoListAPIView.as_view(), name='activo-list'),
    path('ubicaciones/', UbicacionListAPIView.as_view(), name='ubicacion-list'),
    path('movimientos/', MovimientoListAPIView.as_view(), name='movimiento-list'),
]
