from django.conf import settings
from django.core.management.base import BaseCommand
from service.models import ParkingLotModel


class Command(BaseCommand):
  help = 'Clear informations of Seoul public parking lots'

  def handle(self, *args, **options):
    assert settings.DEBUG, 'Can not use production environment'
    ParkingLotModel.objects.all().delete()
