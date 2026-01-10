from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import CurriculumViewSet, LessonViewSet

router = DefaultRouter()
router.register(r'courses', CurriculumViewSet)
router.register(r'lessons', LessonViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
