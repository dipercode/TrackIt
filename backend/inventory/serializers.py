from rest_framework import serializers
from .models import Estacion, Ubicacion, Activo, Movimiento


class EstacionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Estacion
        fields = "__all__"


class UbicacionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ubicacion
        fields = '__all__'


class ActivoSerializer(serializers.ModelSerializer):
    ubicacion_nombre = serializers.ReadOnlyField(source='ubicacion.nombre')

    class Meta:
        model = Activo
        fields = [
            'id', 
            'nombre', 
            'descripcion', 
            'estado', 
            'ubicacion', 
            'ubicacion_nombre',
        ]


class MovimientoSerializer(serializers.ModelSerializer):
    # Traemos el nombre de las ubicaciones (relacionadas en el modelo Movimiento)
    ubicacion_origen_nombre = serializers.ReadOnlyField(source='ubicacion_origen.nombre')
    ubicacion_destino_nombre = serializers.ReadOnlyField(source='ubicacion_destino.nombre')
    # Nombre del usuario que hizo el movimiento
    usuario_nombre = serializers.ReadOnlyField(source='usuario.username')

    class Meta:
        model = Movimiento
        fields = [
            'id', 'activo', 'fecha', 'usuario', 'usuario_nombre',
            'ubicacion_origen', 'ubicacion_origen_nombre', 
            'ubicacion_destino', 'ubicacion_destino_nombre',
            'tipo', 'motivo', 'observaciones'
        ]