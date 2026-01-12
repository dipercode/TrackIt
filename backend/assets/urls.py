from django.urls import path
from .views import ActivoListAPIView

urlpatterns = [
    path('activos/', ActivoListAPIView.as_view(), name='activo-list'),
]
