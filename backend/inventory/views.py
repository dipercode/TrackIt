from django.utils import timezone

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
    serializer_class = ActivoSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['estado', 'ubicacion', 'ubicacion__estacion']
    search_fields = ['nombre', 'descripcion']

    def get_queryset(self):
        queryset = Activo.objects.all()
        
        # Filtro personalizado para Urgencias/Vencimientos
        vencidos = self.request.query_params.get('vencidos', None)
        
        if vencidos == 'true':
            hoy = timezone.now().date()
            # Filtramos: requiere calibración Y la fecha es hoy o anterior
            queryset = queryset.filter(
                requiere_calibracion=True,
                fecha_proxima_verificacion__lte=hoy
            )
            
        return queryset

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
