from rest_framework import viewsets, permissions
from .models import Activo, Ubicacion, Movimiento
from .serializers import (
    ActivoSerializer,
    UbicacionSerializer,
    MovimientoSerializer
)


class UbicacionViewSet(viewsets.ModelViewSet):
    queryset = Ubicacion.objects.all()
    serializer_class = UbicacionSerializer
    permission_classes = [permissions.AllowAny]


class ActivoViewSet(viewsets.ModelViewSet):
    queryset = Activo.objects.all()
    serializer_class = ActivoSerializer
    permission_classes = [permissions.AllowAny]


class MovimientoViewSet(viewsets.ModelViewSet):
    queryset = Movimiento.objects.all()
    serializer_class = MovimientoSerializer
    permission_classes = [permissions.AllowAny]
