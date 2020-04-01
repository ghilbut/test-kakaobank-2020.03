import json
from rest_framework.pagination import LimitOffsetPagination
from rest_framework.routers import DefaultRouter
from rest_framework.serializers import Serializer
from rest_framework.viewsets import ReadOnlyModelViewSet
from .models import ParkingLot


class ParkingLotSerializer(Serializer):
  def to_representation(self, value):
    return json.loads(value.json_string)

class ParkingLotPagination(LimitOffsetPagination):
  default_limit = 20
  max_limit = 1000


class ParkingLotViewSet(ReadOnlyModelViewSet):
  queryset = ParkingLot.objects.all()
  lookup_field = 'code'
  serializer_class = ParkingLotSerializer
  pagination_class = ParkingLotPagination


router = DefaultRouter()
router.register(r'', ParkingLotViewSet)
