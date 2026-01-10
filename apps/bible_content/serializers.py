from rest_framework import serializers
from .models import Book, Chapter, Verse, TheologicalTag
from apps.exercises.models import Exercise

class TheologicalTagSerializer(serializers.ModelSerializer):
    class Meta:
        model = TheologicalTag
        fields = ['id', 'name', 'category']

class NestedExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Exercise
        fields = ['id', 'exercise_type', 'question_data', 'answer_data']

class VerseSerializer(serializers.ModelSerializer):
    tags = TheologicalTagSerializer(many=True, read_only=True)
    exercises = NestedExerciseSerializer(many=True, read_only=True)

    class Meta:
        model = Verse
        fields = ['id', 'number', 'text', 'tags', 'exercises']

class ChapterSerializer(serializers.ModelSerializer):
    verses = VerseSerializer(many=True, read_only=True)

    class Meta:
        model = Chapter
        fields = ['id', 'number', 'verses']

class BookSerializer(serializers.ModelSerializer):
    class Meta:
        model = Book
        fields = ['id', 'name', 'testament', 'order']
