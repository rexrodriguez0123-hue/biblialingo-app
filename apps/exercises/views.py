from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone

from .models import Exercise, UserExerciseAttempt
from .serializers import SubmitAnswerSerializer
from apps.curriculum.models import UserLessonProgress
from apps.curriculum.services.srs_engine import calculate_quality, update_srs


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def submit_answer(request):
    """
    POST /api/v1/exercises/submit/
    Body: {exercise_id, is_correct, time_spent_seconds}

    Records the attempt, updates lesson progress, adjusts gamification stats,
    and applies SM-2 spaced repetition when a lesson is completed.

    Returns: {
        "result": "correct" | "incorrect",
        "hearts": 5,
        "gems": 10,
        "xp_gained": 5,
        "lesson_progress": 0.3,
        "lesson_completed": false,
        "next_review_in_days": null
    }
    """
    serializer = SubmitAnswerSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    try:
        exercise = Exercise.objects.select_related('lesson').get(
            pk=serializer.validated_data['exercise_id']
        )
    except Exercise.DoesNotExist:
        return Response(
            {'error': 'Ejercicio no encontrado.'},
            status=status.HTTP_404_NOT_FOUND,
        )

    is_correct = serializer.validated_data['is_correct']
    time_spent = serializer.validated_data.get('time_spent_seconds', 0)
    user = request.user
    profile = user.profile

    # Record the attempt
    UserExerciseAttempt.objects.create(
        user=user,
        exercise=exercise,
        is_correct=is_correct,
        time_spent_seconds=time_spent,
    )

    # Update gamification
    xp_gained = 0
    if is_correct:
        xp_gained = 10
        profile.total_xp += xp_gained
        profile.gems += 1
    else:
        # Deduct a heart for incorrect answer
        if profile.hearts > 0:
            profile.hearts -= 1

    # Update streak
    today = timezone.now().date()
    if profile.last_practice_date != today:
        if profile.last_practice_date and (today - profile.last_practice_date).days == 1:
            profile.streak_days += 1
        elif profile.last_practice_date and (today - profile.last_practice_date).days > 1:
            profile.streak_days = 1
        else:
            profile.streak_days = 1
        profile.last_practice_date = today

    profile.save()

    # Update lesson progress
    lesson = exercise.lesson
    total_exercises = Exercise.objects.filter(lesson=lesson).count()
    correct_attempts = UserExerciseAttempt.objects.filter(
        user=user,
        exercise__lesson=lesson,
        is_correct=True,
    ).values('exercise').distinct().count()

    progress_pct = correct_attempts / total_exercises if total_exercises > 0 else 0.0

    lesson_progress, _ = UserLessonProgress.objects.get_or_create(
        user=user,
        lesson=lesson,
    )
    lesson_progress.progress_percentage = progress_pct
    lesson_progress.last_practiced = timezone.now()

    # Apply SRS when lesson is completed
    next_review_days = None
    if progress_pct >= 1.0 and not lesson_progress.is_completed:
        lesson_progress.is_completed = True

        # Calculate quality from this session's performance
        session_correct = UserExerciseAttempt.objects.filter(
            user=user,
            exercise__lesson=lesson,
            is_correct=True,
        ).count()
        session_total = UserExerciseAttempt.objects.filter(
            user=user,
            exercise__lesson=lesson,
        ).count()

        quality = calculate_quality(session_correct, session_total)
        update_srs(lesson_progress, quality)
        next_review_days = lesson_progress.interval

        # Bonus gems for completing a lesson
        profile.gems += 10
        profile.save()

    lesson_progress.save()

    return Response({
        'result': 'correct' if is_correct else 'incorrect',
        'hearts': profile.hearts,
        'gems': profile.gems,
        'xp_gained': xp_gained,
        'total_xp': profile.total_xp,
        'streak_days': profile.streak_days,
        'lesson_progress': progress_pct,
        'lesson_completed': lesson_progress.is_completed,
        'next_review_in_days': next_review_days,
    })

