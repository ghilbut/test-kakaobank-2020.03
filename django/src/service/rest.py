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
  """
  서울시 공용주차장 정보를 바탕으로 주차 가능한 주차장 목록을 제공한다. 
  """
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

  def list(self, request):
    """
    서울시 공용주차장들의 목록을 제공한다.
    ---
    # YAML

    type:
      name:
        required: true
        type: string
      url:
        required: false
        type: url
      created_at:
        required: true
        type: string
        format: date-time

    serializer: .ParkingLotSerializer
    omit_serializer: false
    many: true

    parameters_strategy: merge
    omit_parameters:
        - path

    parameters:
      - name: size
        paramType: query
        description: "요청에서 제공하는 최대 공용주차장 정보의 수"
        required: false
        type: integer
      - name: page
        paramType: query
        description: "요청할 페이지 번호"
        required: false
        type: integer
      - name: q
        paramType: query
        description: "검색할 키워드 - 주차장 이름과 주소, 전화번호를 대상으로 한다"
        required: false
        type: string
    """
    return super().list(self, request)

  def retrieve(self, request, code):
    """
    # 서울시 공용주차장의 상세 정보를 제공한다.
    """
    return super().retrieve(self, request, code)


router = DefaultRouter()
router.register(r'', ParkingLotViewSet)
