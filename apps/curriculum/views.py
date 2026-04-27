from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from .models import Course, Lesson
from .serializers import LessonDashboardSerializer
from apps.bible_content.models import Verse
from apps.exercises.models import Exercise
from apps.exercises.serializers import ExerciseSerializer

import logging
logger = logging.getLogger(__name__)


@api_view(['GET'])
@permission_classes([AllowAny])
def course_dashboard_data(request, course_id):
    """
    GET /api/v1/curriculum/courses/{course_id}/dashboard_data/
    Returns the course with all lessons and their progress/unlock status.

    Response format (matching Flutter frontend):
    {
        "course_title": "Génesis RVR1960",
        "lessons": [
            {"id": 1, "title": "...", "order": 1, "is_unlocked": true, "progress": 0.7},
            ...
        ]
    }
    """
    try:
        course = Course.objects.get(pk=course_id)
    except Course.DoesNotExist:
        return Response(
            {'error': 'Curso no encontrado.'},
            status=status.HTTP_404_NOT_FOUND,
        )

    lessons = Lesson.objects.filter(
        unit__course=course
    ).select_related('unit').order_by('order')

    serializer = LessonDashboardSerializer(
        lessons,
        many=True,
        context={'user': request.user},
    )

    return Response({
        'course_title': course.title,
        'lessons': serializer.data,
    })


def _jit_generate_exercises(lesson, verses_qs):
    """
    JIT (Just-In-Time) exercise generation.
    If a lesson has no exercises, generate them using the NLP engine.
    """
    existing_count = Exercise.objects.filter(lesson=lesson).count()
    if existing_count > 0:
        return  # Already has exercises

    try:
        from apps.bible_content.services.nlp_engine import generate_exercises_for_lesson

        verses_data = [(v.id, v.number, v.text) for v in verses_qs]
        if not verses_data:
            return

        exercises = generate_exercises_for_lesson(verses_data, exercises_per_verse=2)

        for ex_data in exercises:
            Exercise.objects.create(
                lesson=lesson,
                verse_id=ex_data['verse_id'],
                exercise_type=ex_data['exercise_type'],
                question_data=ex_data['question_data'],
                answer_data=ex_data['answer_data'],
                difficulty=ex_data.get('difficulty', 1),
                order=ex_data['order'],
            )

        logger.info(f'JIT generated {len(exercises)} exercises for lesson {lesson.id}')
    except Exception as e:
        logger.error(f'JIT exercise generation failed for lesson {lesson.id}: {e}')


@api_view(['GET'])
@permission_classes([AllowAny])
def lesson_detail(request, lesson_id):
    """
    GET /api/v1/curriculum/lessons/{lesson_id}/
    Returns lesson details with verses and exercises.
    If no exercises exist, generates them on-the-fly (JIT) using SpaCy NLP.

    Response format (matching Flutter frontend):
    {
        "id": 1,
        "title": "Génesis 1: La Creación",
        "verses": [
            {
                "text": "En el principio creó Dios...",
                "exercises": [
                    {
                        "exercise_type": "cloze",
                        "question_data": {"text": "En el principio creó Dios los _____ y la tierra."},
                        "answer_data": {"correct": "cielos"}
                    }
                ]
            }
        ]
    }
    """
    try:
        lesson = Lesson.objects.select_related('chapter').get(pk=lesson_id)
    except Lesson.DoesNotExist:
        return Response(
            {'error': 'Lección no encontrada.'},
            status=status.HTTP_404_NOT_FOUND,
        )

    # Get verses in the lesson's range
    verses_qs = Verse.objects.filter(chapter=lesson.chapter)
    if lesson.verse_range_start:
        verses_qs = verses_qs.filter(number__gte=lesson.verse_range_start)
    if lesson.verse_range_end:
        verses_qs = verses_qs.filter(number__lte=lesson.verse_range_end)
    verses_qs = verses_qs.order_by('number')

    # JIT: Generate exercises if none exist
    _jit_generate_exercises(lesson, verses_qs)

    # Build response with verses and their exercises
    verses_data = []
    for verse in verses_qs:
        exercises = Exercise.objects.filter(verse=verse, lesson=lesson).order_by('order')
        exercises_data = ExerciseSerializer(exercises, many=True).data

        verses_data.append({
            'text': verse.text,
            'number': verse.number,
            'exercises': exercises_data,
        })

    return Response({
        'id': lesson.id,
        'title': lesson.title,
        'verses': verses_data,
    })

