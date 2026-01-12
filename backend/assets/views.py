from rest_framework import generics
from .models import Activo, Ubicacion, Movimiento
from .serializers import (
    ActivoSerializer,
    UbicacionSerializer,
    MovimientoSerializer
)


class ActivoListAPIView(generics.ListAPIView):
    queryset = Activo.objects.all()
    serializer_class = ActivoSerializer


class UbicacionListAPIView(generics.ListAPIView):
    queryset = Ubicacion.objects.all()
    serializer_class = UbicacionSerializer


class MovimientoListAPIView(generics.ListAPIView):
    queryset = Movimiento.objects.all()
    serializer_class = MovimientoSerializer
