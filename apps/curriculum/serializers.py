from rest_framework import serializers
from .models import Course, Unit, Lesson, UserLessonProgress


class LessonProgressSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserLessonProgress
        fields = ['is_completed', 'progress_percentage', 'last_practiced', 'next_practice_due']


class LessonSerializer(serializers.ModelSerializer):
    class Meta:
        model = Lesson
        fields = ['id', 'title', 'order', 'verse_range_start', 'verse_range_end']


class LessonDashboardSerializer(serializers.ModelSerializer):
    """Serializer for the dashboard view — includes unlock/progress status."""
    is_unlocked = serializers.SerializerMethodField()
    progress = serializers.SerializerMethodField()

    class Meta:
        model = Lesson
        fields = ['id', 'title', 'order', 'is_unlocked', 'progress']

    def get_is_unlocked(self, obj):
        """A lesson is unlocked if it's the first, or the previous one is completed."""
        user = self.context.get('user')
        if obj.order == 1:
            return True
        if user and user.is_authenticated:
            # Check if previous lesson is completed
            prev_lesson = Lesson.objects.filter(
                unit__course=obj.unit.course,
                order=obj.order - 1
            ).first()
            if prev_lesson:
                progress = UserLessonProgress.objects.filter(
                    user=user, lesson=prev_lesson, is_completed=True
                ).exists()
                return progress
        return obj.order == 1

    def get_progress(self, obj):
        """Get the user's progress on this lesson (0.0 to 1.0)."""
        user = self.context.get('user')
        if user and user.is_authenticated:
            progress = UserLessonProgress.objects.filter(
                user=user, lesson=obj
            ).first()
            if progress:
                return progress.progress_percentage
        return 0.0


class UnitSerializer(serializers.ModelSerializer):
    lessons = LessonSerializer(many=True, read_only=True)

    class Meta:
        model = Unit
        fields = ['id', 'title', 'order', 'lessons']


class CourseSerializer(serializers.ModelSerializer):
    units = UnitSerializer(many=True, read_only=True)

    class Meta:
        model = Course
        fields = ['id', 'title', 'description', 'units']
