from rest_framework import serializers
from .models import Exercise, UserExerciseAttempt


class ExerciseSerializer(serializers.ModelSerializer):
    """Serializer matching the Flutter frontend's expected format."""
    class Meta:
        model = Exercise
        fields = ['id', 'exercise_type', 'question_data', 'answer_data', 'difficulty', 'order']


class SubmitAnswerSerializer(serializers.Serializer):
    exercise_id = serializers.IntegerField()
    is_correct = serializers.BooleanField()
    time_spent_seconds = serializers.IntegerField(required=False, default=0)


class UserExerciseAttemptSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserExerciseAttempt
        fields = ['id', 'exercise', 'is_correct', 'answered_at', 'time_spent_seconds']
        read_only_fields = ['answered_at']
