"""
URL configuration for trackit_backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework.authtoken.views import obtain_auth_token
from django.contrib.auth import views as auth_views
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse

# 1. IMPORTACIONES AÑADIDAS PARA ARCHIVOS MULTIMEDIA
from django.conf import settings
from django.conf.urls.static import static

@csrf_exempt
def public_reset_password(request, *args, **kwargs):
    # Forzamos a que Django crea que no hay sesión ni necesidad de CSRF
    request._dont_enforce_csrf_checks = True
    return auth_views.PasswordResetView.as_view()(request, *args, **kwargs)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/login/', obtain_auth_token),
    path('api/', include('inventory.urls')),

    path('api/password_reset/', public_reset_password, name='password_reset'),

    # Rutas para el restablecimiento de contraseña
    path('api/password_reset/done/', auth_views.PasswordResetDoneView.as_view(), name='password_reset_done'),
    path('api/reset/<uidb64>/<token>/', auth_views.PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('api/reset/done/', auth_views.PasswordResetCompleteView.as_view(), name='password_reset_complete'),
]

# 2. BLOQUE AÑADIDO: Expone la carpeta media/ en desarrollo
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)