from rest_framework import serializers
from .models import Exercise, UserProgress
from apps.bible_content.serializers import VerseSerializer

class ExerciseSerializer(serializers.ModelSerializer):
    verse = VerseSerializer(read_only=True)

    class Meta:
        model = Exercise
        fields = ['id', 'verse', 'exercise_type', 'question_data']

class UserProgressSerializer(serializers.ModelSerializer):
    exercise = ExerciseSerializer(read_only=True)

    class Meta:
        model = UserProgress
        fields = ['id', 'exercise', 'easiness_factor', 'interval', 'repetitions', 'next_practice_due']
