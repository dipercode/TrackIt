from rest_framework.routers import DefaultRouter
from .views import EstacionViewSet, UbicacionViewSet, ActivoViewSet, MovimientoViewSet

router = DefaultRouter()
router.register(r'estaciones', EstacionViewSet)
router.register(r'ubicaciones', UbicacionViewSet)
router.register(r'activos', ActivoViewSet)
router.register(r'movimientos', MovimientoViewSet)

urlpatterns = router.urls
