"""spps URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.0/topics/http/urls/
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
from django.http import HttpResponse
from django.urls import (
  include,
  path,
  re_path,
)
from drf_yasg.openapi import (
  Info,
  Contact,
  License,
)
from drf_yasg.views import get_schema_view
from rest_framework.permissions import AllowAny
from service.rest import router


schema_view = get_schema_view(
   Info(
      title = "서울시 공영주차장 검색 API",
      default_version = 'v1',
      description = "서울열린데이터 광장의 '서울시 공영주차장 안내 정보'를 활용해서 주차 가능한 주차장을 찾을 수 있는 서비스 API",
      contact = Contact(email="ghilbut@gmail.com"),
      license = License(name="MIT License"),
   ),
   public=True,
   permission_classes=(AllowAny,),
)


def healthz(request):
    return HttpResponse("OK")


urlpatterns = [
    path('', healthz),
    path('admin/', admin.site.urls),
    path('parking_lots/', include(router.urls)),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    re_path(r'^swagger(?P<format>\.json|\.yaml)$', schema_view.without_ui(cache_timeout=0), name='schema-json'),
]
