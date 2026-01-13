from rest_framework.routers import DefaultRouter
from .views import ActivoViewSet, UbicacionViewSet, MovimientoViewSet

router = DefaultRouter()
router.register(r'activos', ActivoViewSet)
router.register(r'ubicaciones', UbicacionViewSet)
router.register(r'movimientos', MovimientoViewSet)

urlpatterns = router.urls
