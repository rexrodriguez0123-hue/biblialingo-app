"""
Django production settings for BibliaLingo project.
Configured for Render.com deployment.
"""
import os
import dj_database_url
from .base import *  # noqa: F401,F403

DEBUG = False

ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', 'biblialingo-app.onrender.com').split(',')

# Database - PostgreSQL via DATABASE_URL
DATABASES = {
    'default': dj_database_url.config(
        default=os.environ.get('DATABASE_URL'),
        conn_max_age=600,
        conn_health_checks=True,
    )
}

# CORS - Only allow the Flutter app origins
CORS_ALLOWED_ORIGINS = os.environ.get(
    'CORS_ALLOWED_ORIGINS',
    'https://biblialingo-app.onrender.com'
).split(',')

# Security settings
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True

# WhiteNoise for static files
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
