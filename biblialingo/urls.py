"""
URL configuration for BibliaLingo project.
"""
from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse


def api_root(request):
    """Simple API root endpoint."""
    return JsonResponse({
        'message': 'BibliaLingo API v1',
        'endpoints': {
            'users': '/api/v1/users/',
            'bible': '/api/v1/bible/',
            'curriculum': '/api/v1/curriculum/',
            'exercises': '/api/v1/exercises/',
        }
    })


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/', api_root),
    path('api/v1/users/', include('apps.users.urls')),
    path('api/v1/bible/', include('apps.bible_content.urls')),
    path('api/v1/curriculum/', include('apps.curriculum.urls')),
    path('api/v1/exercises/', include('apps.exercises.urls')),
]
