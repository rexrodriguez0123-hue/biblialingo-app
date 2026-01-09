from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    # API endpoints
    path('api/v1/users/', include('apps.users.urls')),
    # path('api/v1/bible/', include('apps.bible_content.urls')),
    # path('api/v1/exercises/', include('apps.exercises.urls')),
]
