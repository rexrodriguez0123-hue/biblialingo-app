"""
ASGI config for Camino Biblico project.
"""
import os
from django.core.asgi import get_asgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Camino Biblico.settings.prod')

application = get_asgi_application()

