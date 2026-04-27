from django.contrib import admin
from .models import Exercise, UserExerciseAttempt


@admin.register(Exercise)
class ExerciseAdmin(admin.ModelAdmin):
    list_display = ['exercise_type', 'lesson', 'verse', 'difficulty', 'order']
    list_filter = ['exercise_type', 'difficulty', 'lesson__unit__course']
    search_fields = ['verse__text']


@admin.register(UserExerciseAttempt)
class UserExerciseAttemptAdmin(admin.ModelAdmin):
    list_display = ['user', 'exercise', 'is_correct', 'answered_at', 'time_spent_seconds']
    list_filter = ['is_correct', 'answered_at']
    search_fields = ['user__username']
