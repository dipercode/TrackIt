from rest_framework import viewsets, permissions, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend


from .models import Estacion, Ubicacion, Activo, Movimiento
from .serializers import (
    EstacionSerializer,
    UbicacionSerializer,
    ActivoSerializer,
    MovimientoSerializer,
)


class EstacionViewSet(viewsets.ModelViewSet):
    queryset = Estacion.objects.all()
    serializer_class = EstacionSerializer

class UbicacionViewSet(viewsets.ModelViewSet):
    queryset = Ubicacion.objects.all()
    serializer_class = UbicacionSerializer
    permission_classes = [permissions.AllowAny]

    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['estacion']



class ActivoViewSet(viewsets.ModelViewSet):
    queryset = Activo.objects.all()
    serializer_class = ActivoSerializer
    permission_classes = [permissions.AllowAny]

    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    # Permite filtrar por estado y ubicación, y buscar por nombre o descripción
    filterset_fields = ['estado','ubicacion', 'ubicacion__estacion']
    # Permite búsqueda parcial por nombre o descripción del activo
    search_fields = ['nombre', 'descripcion']

    @action(detail=True, methods=['get'])
    def movimientos(self, request, pk=None):
        activo = self.get_object()
        movimientos = Movimiento.objects.filter(activo=activo).order_by('-fecha')
        serializer = MovimientoSerializer(movimientos, many=True)
        return Response(serializer.data)


class MovimientoViewSet(viewsets.ModelViewSet):
    queryset = Movimiento.objects.all()
    serializer_class = MovimientoSerializer
    permission_classes = [permissions.AllowAny]
