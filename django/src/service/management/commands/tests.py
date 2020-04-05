import json
import unittest
from django import test
from django.test import tag
from .crawling import (
  _price_per_hours,
  _price_per_minutes,
)


@tag('unit')
class CrawlingUnitTestCase(unittest.TestCase):
  def setUp(self):
    pass

  def test_regulate_phone_number(self):
    pass

  def test_calc_time_price_table(self):
    pass

  def test_price_per_month(self):
    pass

  def test_price_per_day(self):
    pass

  def test_price_per_hours(self):
    pass

  def test_price_per_minutes(self):
    item = {
      'RATES': 1000.0,
      'TIME_RATE': 300.0,
      'ADD_RATES': 2000.0,
      'ADD_TIME_RATE': 10.0,
    }

    expected = [1000, 1000, 1000, 1000]
    for hour in range(1, 5):
      price = _price_per_minutes(item, hour * 60)
      self.assertEqual(price, expected[hour-1])


@tag('integration')
class CrawlingIntegrationTestCase(test.TestCase):
  def setUp(self):
    pass

  def test(self):
    pass
