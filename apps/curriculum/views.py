from rest_framework import viewsets, permissions, response
from rest_framework.decorators import action
from django.shortcuts import get_object_or_404
from .models import Course, Lesson, UserLessonProgress
from .serializers import CourseSerializer, LessonSerializer
from apps.bible_content.services.smart_generator import SmartExerciseGenerator

class CurriculumViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint that allows courses and lessons to be viewed.
    """
    queryset = Course.objects.all()
    serializer_class = CourseSerializer
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=True, methods=['get'])
    def dashboard_data(self, request, pk=None):
        """
        Custom endpoint to return lessons with user-specific progress and locking status.
        """
        course = self.get_object()
        lessons = course.lessons.all().order_by('order')
        
        user = request.user
        lesson_data = []
        
        # Unlock logic: First lesson is always unlocked.
        # Following lessons are unlocked if the previous one is completed.
        previous_completed = True 
        
        for lesson in lessons:
            # Check if user has progress
            progress = UserLessonProgress.objects.filter(user=user, lesson=lesson).first()
            is_completed = progress is not None and progress.score >= 80 # Threshold?
            
            # Simple progress calc (placeholder logic)
            # If we have UserLessonProgress, assume 100% or store % there
            progress_percent = 1.0 if is_completed else 0.0
            
            is_unlocked = previous_completed
            
            lesson_data.append({
                'id': lesson.id,
                'title': lesson.title,
                'order': lesson.order,
                'is_unlocked': is_unlocked,
                'is_completed': is_completed,
                'progress': progress_percent,
            })
            
            # Update for next iteration
            previous_completed = is_completed

        return response.Response({
            'course_title': course.title,
            'lessons': lesson_data
        })

class LessonViewSet(viewsets.ReadOnlyModelViewSet):
    """
    API endpoint for individual lessons.
    """
    queryset = Lesson.objects.all()
    serializer_class = LessonSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def retrieve(self, request, *args, **kwargs):
        instance = self.get_object()
        
        # Check if lesson has any exercises
        # We need to check exercises attached to any of its verses
        has_exercises = any(v.exercises.exists() for v in instance.verses.all())
        
        if not has_exercises:
            print(f"JIT Generation: Generating content for {instance.title}...")
            generator = SmartExerciseGenerator()
            generator.generate_for_lesson(instance)
            # Re-fetch instance to include new exercises in serialization? 
            # Actually, standard retrieve might use cached queryset, so let's refresh.
            instance = self.get_object()

        serializer = self.get_serializer(instance)
        return response.Response(serializer.data)
