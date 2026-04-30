"""
WSGI config for Camino Biblico project.
"""
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'camino_biblico.settings.prod')

application = get_wsgi_application()

