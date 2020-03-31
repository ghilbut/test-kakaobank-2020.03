import binascii
import json
import os
import requests
import time
from django.core.management.base import BaseCommand
from service.models import ParkingLot


class Command(BaseCommand):
  help = 'Crawling informations of Seoul public parking lots'

  def handle(self, *args, **options):
    key = os.environ['OPEN_API_KEY']

    steps = 100  # 1000
    begin = 1
    end   = steps

    version = int(time.time())

    while True:
      print(f'BEGIN({begin}) - END({end})')

      url = f'http://openapi.seoul.go.kr:8088/{key}/json/GetParkInfo/{begin}/{end}/'
      res = requests.get(url)
      obj = res.json()

      r = obj['GetParkInfo']['RESULT']
      _assert_result(r)

      total = obj['GetParkInfo']['list_total_count']
      row   = obj['GetParkInfo']['row']
      end   = begin + len(row) - 1

      _update_parking_lot(row, version)

      break  # temp for test

      if end == total:
        break

      begin = end + 1
      end   = min(total, end + steps)

    n = ParkingLot.objects.exclude(version=version).delete()
    n = n[1].get('service.ParkingLot', 0)
    print(f'ParkingLot: {n} rows are deleted')


def _assert_result(result: dict) -> None:
  c = result['CODE']
  m = result['MESSAGE']
  assert c == 'INFO-000', f'[CODE: {c}] {m}'


def _update_parking_lot(input: list, version: int) -> None:
  code_list = [item['PARKING_CODE'] for item in input]

  rows = ParkingLot.objects.filter(code__in=code_list)
  rows = {row.code:row for row in rows}

  for item in input:
    code = int(item['PARKING_CODE'])
    json_string = json.dumps(item, ensure_ascii=False)
    crc32 = binascii.crc32(json_string.encode('utf8'))

    try:
      row = rows[code]
      update = (row.crc32 != crc32)
    except KeyError:
      row = ParkingLot()
      update = True

    if update:
      row.code = code
      row.name = item['PARKING_NAME']
      row.address = item['ADDR']
      row.phone_num = _regulate_phone_number(item['TEL'])
      row.json_string = json_string
      row.crc32 = crc32
    row.version = version
    row.save()


def _regulate_phone_number(tel: str) -> str:
  assert isinstance(tel, str)

  tel = tel.strip().replace(')', '-')
  if '~' in tel:
    p = tel[:-3]
    b = int(tel[-3:-2])
    e = int(tel[-1:])
    tel = {f'{p}{n}' for n in range(b, e+1)}
  else:
    tel = [tel]

  return ','.join(tel)
