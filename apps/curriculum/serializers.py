from rest_framework import serializers
from .models import Course, Lesson
from apps.bible_content.serializers import VerseSerializer

class LessonSerializer(serializers.ModelSerializer):
    verses = VerseSerializer(many=True, read_only=True)

    class Meta:
        model = Lesson
        fields = ['id', 'title', 'order', 'verses']

class CourseSerializer(serializers.ModelSerializer):
    lessons = LessonSerializer(many=True, read_only=True)

    class Meta:
        model = Course
        fields = ['id', 'title', 'description', 'level', 'lessons']
