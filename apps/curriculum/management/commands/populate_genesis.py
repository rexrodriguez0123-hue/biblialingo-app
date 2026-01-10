import os
from django.conf import settings
from django.core.management.base import BaseCommand
from apps.curriculum.models import Course, Lesson
from apps.bible_content.models import Verse, Book, Chapter
from apps.exercises.models import Exercise
from apps.bible_content.services.importer import BibleImporter

class Command(BaseCommand):
    help = 'Populates the database with Genesis RVR1960 curriculum'

    def handle(self, *args, **kwargs):
        self.stdout.write('Creating Genesis curriculum...')

        # 1. Create Course
        course, created = Course.objects.get_or_create(
            title="Génesis RVR1960",
            defaults={'description': "Aprende hebreo y español con el primer libro de la Biblia.", 'level': 1}
        )

        # 3. Import Content from Fixture
        self.stdout.write("Reading JSON fixture file...")
        fixture_path = os.path.join(settings.BASE_DIR, 'apps', 'bible_content', 'fixtures', 'genesis_rvr1960.json')
        
        if os.path.exists(fixture_path):
            with open(fixture_path, 'r', encoding='utf-8') as f:
                import json
                data = json.load(f)
            
            self.stdout.write("Importing text and generating exercises (this may take a moment)...")
            importer = BibleImporter(course_id=course.id)
            importer.parse_json(data)
            self.stdout.write(self.style.SUCCESS(f"Successfully imported content from {fixture_path}"))
        else:
            self.stdout.write(self.style.WARNING(f"Fixture file not found at {fixture_path}."))
            if os.path.exists(os.path.join(settings.BASE_DIR, 'apps', 'bible_content', 'fixtures', 'genesis_rvr1960.txt')):
                self.stdout.write("Falling back to text fixture...")
                with open(os.path.join(settings.BASE_DIR, 'apps', 'bible_content', 'fixtures', 'genesis_rvr1960.txt'), 'r', encoding='utf-8') as f:
                    content = f.read()
                importer = BibleImporter(course_id=course.id)
                importer.parse_text(content)

        self.stdout.write(self.style.SUCCESS('Successfully populated Genesis curriculum!'))
