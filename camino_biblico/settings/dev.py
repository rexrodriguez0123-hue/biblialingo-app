"""
Django development settings for Camino Biblico project.
"""
from .base import *  # noqa: F401,F403

DEBUG = True

ALLOWED_HOSTS = ['*']

# Database - SQLite for local development
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# CORS - Allow all origins in development
CORS_ALLOW_ALL_ORIGINS = True

# Make DRF browsable API available without auth in dev
REST_FRAMEWORK['DEFAULT_PERMISSION_CLASSES'] = [  # noqa: F405
    'rest_framework.permissions.AllowAny',
]

