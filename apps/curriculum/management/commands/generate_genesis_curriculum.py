"""
Management command to generate the Genesis curriculum.
Creates 1 Course, 6 Units, and 50 Lessons (one per chapter).
"""
from django.core.management.base import BaseCommand
from apps.bible_content.models import Book, Chapter
from apps.curriculum.models import Course, Unit, Lesson


# Genesis curriculum structure: 6 thematic units
GENESIS_UNITS = [
    {
        'title': 'Los Orígenes',
        'order': 1,
        'chapters': list(range(1, 6)),  # Chapters 1-5
        'descriptions': {
            1: 'La Creación',
            2: 'El Edén',
            3: 'La Caída',
            4: 'Caín y Abel',
            5: 'Genealogía de Adán',
        },
    },
    {
        'title': 'El Diluvio',
        'order': 2,
        'chapters': list(range(6, 12)),  # Chapters 6-11
        'descriptions': {
            6: 'Maldad del hombre',
            7: 'El Diluvio',
            8: 'Las aguas bajan',
            9: 'Pacto con Noé',
            10: 'Tabla de naciones',
            11: 'Torre de Babel',
        },
    },
    {
        'title': 'Abraham',
        'order': 3,
        'chapters': list(range(12, 21)),  # Chapters 12-20
        'descriptions': {
            12: 'Llamado de Abram',
            13: 'Abram y Lot',
            14: 'Melquisedec',
            15: 'Pacto de Dios',
            16: 'Agar e Ismael',
            17: 'Circuncisión',
            18: 'Promesa a Sara',
            19: 'Sodoma y Gomorra',
            20: 'Abraham y Abimelec',
        },
    },
    {
        'title': 'Isaac y Jacob',
        'order': 4,
        'chapters': list(range(21, 31)),  # Chapters 21-30
        'descriptions': {
            21: 'Nacimiento de Isaac',
            22: 'Sacrificio de Isaac',
            23: 'Muerte de Sara',
            24: 'Rebeca',
            25: 'Jacob y Esaú',
            26: 'Isaac y Abimelec',
            27: 'La bendición',
            28: 'Escalera de Jacob',
            29: 'Lea y Raquel',
            30: 'Hijos de Jacob',
        },
    },
    {
        'title': 'Jacob regresa',
        'order': 5,
        'chapters': list(range(31, 37)),  # Chapters 31-36
        'descriptions': {
            31: 'Huida de Jacob',
            32: 'Peniel',
            33: 'Encuentro con Esaú',
            34: 'Dina en Siquem',
            35: 'Regreso a Bet-el',
            36: 'Descendientes de Esaú',
        },
    },
    {
        'title': 'La Historia de José',
        'order': 6,
        'chapters': list(range(37, 51)),  # Chapters 37-50
        'descriptions': {
            37: 'José vendido',
            38: 'Judá y Tamar',
            39: 'José y Potifar',
            40: 'El copero y el panadero',
            41: 'Sueños de Faraón',
            42: 'Los hermanos en Egipto',
            43: 'Segundo viaje',
            44: 'La copa de José',
            45: 'José se revela',
            46: 'Jacob va a Egipto',
            47: 'En tierra de Gosén',
            48: 'Bendición de Efraín',
            49: 'Profecía de las 12 tribus',
            50: 'Muerte de José',
        },
    },
]


class Command(BaseCommand):
    help = 'Generate the Genesis curriculum (1 course, 6 units, 50 lessons)'

    def add_arguments(self, parser):
        parser.add_argument(
            '--reset',
            action='store_true',
            help='Delete existing Genesis curriculum before creating',
        )

    def handle(self, *args, **options):
        try:
            book = Book.objects.get(name='Génesis')
        except Book.DoesNotExist:
            self.stderr.write(self.style.ERROR(
                'Book "Génesis" not found. Run `python manage.py load_genesis` first.'
            ))
            return

        if options['reset']:
            Course.objects.filter(book=book).delete()
            self.stdout.write('Deleted existing Genesis curriculum')

        # Create or get the course
        course, created = Course.objects.get_or_create(
            book=book,
            defaults={
                'title': 'Génesis RVR1960',
                'description': 'Curso completo del libro de Génesis, versión Reina Valera 1960.',
                'order': 1,
            }
        )

        if not created:
            self.stdout.write(f'Course already exists: {course.title}')
            if not options['reset']:
                self.stdout.write('Use --reset to recreate. Skipping.')
                return

        self.stdout.write(f'{"Created" if created else "Using"} course: {course.title}')

        lesson_order = 1
        total_lessons = 0

        for unit_data in GENESIS_UNITS:
            unit, _ = Unit.objects.get_or_create(
                course=course,
                order=unit_data['order'],
                defaults={'title': unit_data['title']},
            )
            self.stdout.write(f'  Unit {unit.order}: {unit.title}')

            for chapter_num in unit_data['chapters']:
                try:
                    chapter = Chapter.objects.get(book=book, number=chapter_num)
                except Chapter.DoesNotExist:
                    self.stderr.write(
                        f'    WARNING: Chapter {chapter_num} not found in database. Skipping.'
                    )
                    continue

                description = unit_data['descriptions'].get(chapter_num, f'Capítulo {chapter_num}')
                title = f'Génesis {chapter_num}: {description}'

                lesson, _ = Lesson.objects.get_or_create(
                    unit=unit,
                    chapter=chapter,
                    defaults={
                        'title': title,
                        'order': lesson_order,
                        'verse_range_start': 1,
                        'verse_range_end': None,  # All verses
                    },
                )
                self.stdout.write(f'    Lesson {lesson_order}: {title}')
                lesson_order += 1
                total_lessons += 1

        self.stdout.write(self.style.SUCCESS(
            f'\nGenesis curriculum created: {len(GENESIS_UNITS)} units, {total_lessons} lessons'
        ))
