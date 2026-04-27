"""
Management command to generate exercises for all lessons using the NLP engine.
Can generate for all lessons or a specific lesson ID.
"""
from django.core.management.base import BaseCommand
from apps.bible_content.models import Verse
from apps.bible_content.services.nlp_engine import generate_exercises_for_lesson
from apps.curriculum.models import Lesson
from apps.exercises.models import Exercise


class Command(BaseCommand):
    help = 'Generate exercises for lessons using the NLP engine'

    def add_arguments(self, parser):
        parser.add_argument(
            '--lesson', type=int, default=None,
            help='Generate exercises for a specific lesson ID only',
        )
        parser.add_argument(
            '--force', action='store_true',
            help='Regenerate even if exercises already exist',
        )
        parser.add_argument(
            '--per-verse', type=int, default=2,
            help='Number of exercises to generate per verse (default: 2)',
        )

    def handle(self, *args, **options):
        lesson_id = options['lesson']
        force = options['force']
        per_verse = options['per_verse']

        if lesson_id:
            lessons = Lesson.objects.filter(pk=lesson_id)
        else:
            lessons = Lesson.objects.all().order_by('order')

        if not lessons.exists():
            self.stderr.write(self.style.ERROR('No lessons found.'))
            return

        total_created = 0

        for lesson in lessons:
            # Skip if exercises already exist (unless --force)
            existing = Exercise.objects.filter(lesson=lesson).count()
            if existing > 0 and not force:
                self.stdout.write(f'  Lesson {lesson.order}: {lesson.title} - {existing} exercises exist (skip)')
                continue

            if force and existing > 0:
                Exercise.objects.filter(lesson=lesson).delete()
                self.stdout.write(f'  Lesson {lesson.order}: Deleted {existing} old exercises')

            # Get verses for this lesson
            verses_qs = Verse.objects.filter(chapter=lesson.chapter)
            if lesson.verse_range_start:
                verses_qs = verses_qs.filter(number__gte=lesson.verse_range_start)
            if lesson.verse_range_end:
                verses_qs = verses_qs.filter(number__lte=lesson.verse_range_end)
            verses_qs = verses_qs.order_by('number')

            verses_data = [(v.id, v.number, v.text) for v in verses_qs]

            if not verses_data:
                self.stdout.write(f'  Lesson {lesson.order}: No verses found (skip)')
                continue

            # Generate exercises
            exercises = generate_exercises_for_lesson(verses_data, exercises_per_verse=per_verse)

            # Save to database
            created = 0
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
                created += 1

            total_created += created
            self.stdout.write(f'  Lesson {lesson.order}: {lesson.title} - {created} exercises created')

        self.stdout.write(self.style.SUCCESS(f'\nTotal: {total_created} exercises generated'))
