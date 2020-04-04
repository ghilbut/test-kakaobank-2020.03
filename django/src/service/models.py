from django.contrib.gis.db.models import PointField
from django.core.validators import (
  MaxValueValidator,
  MinValueValidator,
)
from django.db import models


class ParkingLotModel(models.Model):
  code        = models.PositiveIntegerField(primary_key=True)
  name        = models.CharField(db_index=True, max_length=128)
  address     = models.CharField(db_index=True, max_length=512)
  phone_num   = models.CharField(db_index=True, max_length=64)
  json_string = models.TextField()
  crc32       = models.PositiveIntegerField()
  version     = models.CharField(db_index=True, max_length=32)

  class Meta:
    db_table = 'spps_parking_lots'

  def __str__(self):
    return f'[{self.code}] {self.name}'


class TimePriceTableModel(models.Model):
  parking_lot = models.ForeignKey(
    ParkingLotModel,
    db_column='parking_lot_code',
    on_delete=models.CASCADE,
    related_name='prices',
    related_query_name='price',
  )
  time = models.SmallIntegerField(
    db_index=True,
    default=0,
    validators=[
      MaxValueValidator(4),
      MinValueValidator(-1)
    ],
  )
  price = models.PositiveIntegerField(db_index=True, default=0)

  class Meta:
    db_table = 'spps_parking_lot_price_per_times'
    ordering = ['price']
    unique_together = ['parking_lot', 'time']
