from rest_framework import serializers
from .models import Activo, Ubicacion, Movimiento


class UbicacionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ubicacion
        fields = '__all__'


class ActivoSerializer(serializers.ModelSerializer):
    ubicacion = UbicacionSerializer(read_only=True)

    class Meta:
        model = Activo
        fields = '__all__'


class MovimientoSerializer(serializers.ModelSerializer):
    activo = ActivoSerializer(read_only=True)

    class Meta:
        model = Movimiento
        fields = '__all__'
