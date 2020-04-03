from spps.settings.local import *


DEBUG = False


ALLOWED_HOSTS = [
  '*:8000',
  'spps.ghilbut.net',
  'spps-api.ghilbut.net',
]


DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.mysql',
    'NAME': os.environ['SPPS_DB_NAME'],
    'HOST': os.environ['SPPS_DB_HOST'],
    'PORT': os.environ['SPPS_DB_PORT'],
    'USER': os.environ['SPPS_DB_USER'],
    'PASSWORD': os.environ['SPPS_DB_PASSWORD'],
    'OPTIONS': {
      'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
    },
    'CONN_MAX_AGE': 60,
  }
}
