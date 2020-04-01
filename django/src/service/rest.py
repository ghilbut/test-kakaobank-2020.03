import json
from django.db.models import Q
from rest_framework.pagination import PageNumberPagination
from rest_framework.routers import DefaultRouter
from rest_framework.serializers import Serializer
from rest_framework.viewsets import ReadOnlyModelViewSet
from .models import ParkingLot


class ParkingLotSerializer(Serializer):
  def to_representation(self, value: ParkingLot) -> dict:
    return json.loads(value.json_string)


class ParkingLotPagination(PageNumberPagination):
  page_size = 20
  page_size_query_param = 'size'
  max_page_size = 1000


class ParkingLotViewSet(ReadOnlyModelViewSet):
  queryset = ParkingLot.objects.all()
  lookup_field = 'code'
  serializer_class = ParkingLotSerializer
  pagination_class = ParkingLotPagination

  def get_queryset(self):
    key = self.request.query_params.get('q')
    if key == None:
      return self.queryset

    q = Q()
    q.add(Q(address__contains=key),   q.OR)
    q.add(Q(phone_num__contains=key), q.OR)
    q.add(Q(name__contains=key),      q.OR)
    return self.queryset.filter(q)


router = DefaultRouter()
router.register(r'', ParkingLotViewSet)
