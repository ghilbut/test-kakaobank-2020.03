import json
from django.db.models import (
  F,
  Func,
  Q,
)
from django.utils.decorators import method_decorator
from drf_yasg.openapi import (
  IN_PATH,
  IN_QUERY,
  Parameter,
  TYPE_INTEGER,
  TYPE_STRING,
)
from drf_yasg.utils import swagger_auto_schema
from rest_framework.pagination import PageNumberPagination
from rest_framework.routers import DefaultRouter
from rest_framework.serializers import (
  CharField,
  Serializer,
)
from rest_framework.status import HTTP_404_NOT_FOUND
from rest_framework.viewsets import ReadOnlyModelViewSet
from .models import ParkingLotModel


class ParkingLotModelSerializer(Serializer):
  def to_representation(self, value: ParkingLotModel) -> dict:
    return json.loads(value.json_string)


class ErrorSerializer(Serializer):
  detail = CharField()


class ParkingLotModelPagination(PageNumberPagination):
  page_size = 20
  page_query_description = '조회하려는 페이지의 숫자'
  page_size_query_param = 'size'
  page_size_query_description = '하나의 페이지에 들어가는 공용주차장의 갯수'
  max_page_size = 1000


@method_decorator(
  name = 'list',
  decorator = swagger_auto_schema(
    manual_parameters = [
      Parameter(
        'q', IN_QUERY,
        description = '검색을 위한 키워드 (주차장 이름과 주소, 전화번호가 대상이다)',
        required = False,
        type = TYPE_STRING,
      ),
    ],
    operation_summary = '서울시 공용주차장들의 목록을 검색한다.',
    responses = {
      HTTP_404_NOT_FOUND: ErrorSerializer('Invalid Page.'),
    },
  )
)
@method_decorator(
  name = 'retrieve',
  decorator = swagger_auto_schema(
    manual_parameters = [
      Parameter(
        'code', IN_PATH,
        description = '조회하려는 공용주차장의 코드',
        required = True,
        type = TYPE_INTEGER,
      ),
    ],
    operation_id = 'parking_lots_retrieve',
    operation_summary = '선택한 서울시 공용주차장의 상세 정보를 제공한다.',
    responses = {
      HTTP_404_NOT_FOUND: ErrorSerializer('Not found.'),
    },
  )
)
class ParkingLotModelViewSet(ReadOnlyModelViewSet):
  queryset = ParkingLotModel.objects.all()
  lookup_field = 'code'
  serializer_class = ParkingLotModelSerializer
  pagination_class = ParkingLotModelPagination

  def get_queryset(self):
    query = self.queryset.distinct()
    q = Q()

    # 키워드 검색
    key = self.request.query_params.get('q')
    if key != None:
      q.add(Q(address__contains=key),   q.OR)
      q.add(Q(phone_num__contains=key), q.OR)
      q.add(Q(name__contains=key),      q.OR)

    sort = self.request.query_params.get('sort')
    time = int(self.request.query_params.get('sortPrice', 1))
    lat = self.request.query_params.get('lat')
    lng = self.request.query_params.get('lng')

    if sort == 'distance':
      o = self._query_order_by_position(query, lat, lng)
    else:
      o = self._query_order_by_price(query, time)
    query = o
    query = query.filter(q)
    return query

  @staticmethod
  def _query_order_by_position(query, lat, lng):
    if lat == None or lng == None:
      return None

    # TODO(ghilbut): check lat and lng validation 

    """
    SELECT
      code, (
        6371 * acos (
        cos ( radians(37.35224320) )
        * cos( radians( lat ) )
        * cos( radians( lng ) - radians(127.11034880) )
        + sin ( radians(37.35224320) )
        * sin( radians( lat ) )
      )
    ) AS distance
    FROM spps_parking_lots
    ORDER BY distance
    LIMIT 0 , 20;
    """

    lat = float(lat)
    lng = float(lng)

    class Sin(Func):
      function = 'SIN'
    class Cos(Func):
      function = 'COS'
    class Acos(Func):
      function = 'ACOS'
    class Radians(Func):
      function = 'RADIANS'

    rlat = Radians(lat)
    rlng = Radians(lng)
    rflat = Radians(F('lat'))
    rflng = Radians(F('lng'))

    exp = 3959.0 * Acos(Sin(rlat) * Sin(rflat) +
                        Cos(rlat) * Cos(rflat) * Cos(rflng - rlng))
    query = query.annotate(distance=exp).order_by('distance')
    return query

  @staticmethod
  def _query_order_by_price(query, time):
    query = query.filter(price__time=time)
    query = query.order_by('price__price')
    return query


router = DefaultRouter()
router.register(r'', ParkingLotModelViewSet)
