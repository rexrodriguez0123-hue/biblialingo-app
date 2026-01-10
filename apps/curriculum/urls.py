from .views import CurriculumViewSet, LessonViewSet

router = DefaultRouter()
router.register(r'courses', CurriculumViewSet)
router.register(r'lessons', LessonViewSet)

urlpatterns = [
    path('', include(router.urls)),
]
