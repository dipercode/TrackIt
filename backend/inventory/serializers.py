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
    ubicacion = UbicacionSerializer(read_only=True)

    class Meta:
        model = Activo
        fields = '__all__'


class MovimientoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Movimiento
        fields = '__all__'
