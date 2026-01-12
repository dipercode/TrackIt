from rest_framework import serializers
from .models import Activo, Ubicacion, Movimiento


class UbicacionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Ubicacion
        fields = '__all__'


class ActivoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Activo
        fields = '__all__'


class MovimientoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Movimiento
        fields = '__all__'
