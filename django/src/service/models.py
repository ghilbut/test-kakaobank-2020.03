from django.db import models


class ParkingLot(models.Model):
  code        = models.PositiveIntegerField(primary_key=True)
  name        = models.CharField(max_length=128, db_index=True)
  address     = models.CharField(max_length=512, db_index=True)
  phone_num   = models.CharField(max_length=64,  db_index=True)
  json_string = models.TextField()
  crc32       = models.PositiveIntegerField()
  version     = models.PositiveIntegerField()

  class Meta:
    db_table = 'spps_parking_lot'

  def __str__(self):
    return f'[{self.code}] {self.name}'
