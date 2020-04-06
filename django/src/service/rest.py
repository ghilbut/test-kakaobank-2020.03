import json
from django.db.models import (
  F,
  Func,
  Q,
  Min,
)
from django.utils.decorators import method_decorator
from drf_yasg.openapi import (
  IN_PATH,
  IN_QUERY,
  Parameter,
  TYPE_INTEGER,
  TYPE_NUMBER,
  TYPE_STRING,
)
from drf_yasg.utils import swagger_auto_schema
from rest_framework.pagination import PageNumberPagination
from rest_framework.routers import DefaultRouter
from rest_framework.serializers import (
  CharField,
  FloatField,
  Serializer,
  Serializer,
)
from rest_framework.status import HTTP_404_NOT_FOUND
from rest_framework.viewsets import ReadOnlyModelViewSet
from .models import ParkingLotModel


class ParkingLotModelSerializer(Serializer):
  target_price = FloatField(read_only=True, required=False)
  distance = FloatField(read_only=True, required=False)

  def to_representation(self, value: ParkingLotModel) -> dict:
    v = json.loads(value.json_string)
    v['price'] = value.target_price
    v['distance'] =int( value.distance * 10) / 10
    return v

  #class Meta:
  #  model = ParkingLotModel
  #  fields = ['json_string', 'target_price', 'distance']


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
        'sort', IN_QUERY,
        description = '''우선 정렬기준을 지정한다.
값이 없거나 유효한 값이 아니면 price 우선 옵션으로 동작한다.
''',
        required = False,
        type = TYPE_STRING,
        enum = [
          'price',
          'distance',
        ],
      ),
      Parameter(
        'sortPrice', IN_QUERY,
        description = '''가격정렬 기준을 지정한다.
1시간(1), 2시간(2), 3시간(3), 4시간(4), 하루(0), 월정액(-1)을 선택할 수 있다.
''',
        required = False,
        type = TYPE_INTEGER,
        enum = [-1, 0, 1, 2, 3, 4],
      ),
      Parameter(
        'lat', IN_QUERY,
        description = '거리정렬에 사용되는 사용자의 현재 Latitude 값이다.',
        required = False,
        type = TYPE_NUMBER,
      ),
      Parameter(
        'lng', IN_QUERY,
        description = '거리정렬에 사용되는 사용자의 현재 Longitude 값이다.',
        required = False,
        type = TYPE_NUMBER,
      ),
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
    query = self.queryset
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

    query = query.filter(q)
    query = query.filter(price__time=time).annotate(target_price=Min('price__price'))

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

    exp = 6371 * Acos(Sin(rlat) * Sin(rflat) +
                      Cos(rlat) * Cos(rflat) * Cos(rflng - rlng))
    query = query.annotate(distance=exp)

    if sort == 'distance':
      return query.order_by('distance', 'target_price')

    return query.order_by('target_price', 'distance')


router = DefaultRouter()
router.register(r'', ParkingLotModelViewSet)
