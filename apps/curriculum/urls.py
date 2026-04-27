from django.urls import path
from . import views

urlpatterns = [
    path('courses/<int:course_id>/dashboard_data/', views.course_dashboard_data, name='course-dashboard'),
    path('lessons/<int:lesson_id>/', views.lesson_detail, name='lesson-detail'),
]
