from django.test import TestCase

class MyTests(TestCase):
  def test_failed(self):
    self.fail('fail test')
