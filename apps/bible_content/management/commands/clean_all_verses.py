"""
Management Command: clean_all_verses

Limpia y saneamientos todos los versículos de la base de datos eliminando:
- Caracteres especiales (ĳ → ij, ligaduras, etc.)
- Guiones huérfanos y palabras separadas
- Espacios dobles
- Saltos de línea inadecuados
- Palabras duplicadas por errores OCR

Uso:
  python manage.py clean_all_verses [--dry-run] [--delete-exercises]

Opciones:
  --dry-run          : Simula cambios sin guardar (solo muestra reporte)
  --delete-exercises : Elimina ejercicios corruptos (fuerza regeneración JIT)
"""

import re
from django.core.management.base import BaseCommand, CommandError
from apps.bible_content.models import Verse, Book
from apps.exercises.models import Exercise


class Command(BaseCommand):
    help = 'Limpia y saneamientos todos los versículos bíblicos en la BD'

    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Simula cambios sin guardar nada'
        )
        parser.add_argument(
            '--delete-exercises',
            action='store_true',
            help='Elimina ejercicios corruptos después de limpiar (fuerza regeneración)'
        )
        parser.add_argument(
            '--book',
            type=str,
            default=None,
            help='Limpia solo un libro (ej: "Génesis")'
        )

    def handle(self, *args, **options):
        dry_run = options['dry_run']
        delete_exercises = options['delete_exercises']
        book_name = options['book']

        self.stdout.write(self.style.SUCCESS('\n' + '=' * 80))
        self.stdout.write(self.style.SUCCESS('🔍 INICIANDO LIMPIEZA DE VERSÍCULOS BÍBLICOS'))
        self.stdout.write(self.style.SUCCESS('=' * 80))

        # Filtrar versículos
        if book_name:
            verses = Verse.objects.filter(book__name=book_name)
            self.stdout.write(f"\n📖 Procesando libro: {book_name}")
        else:
            verses = Verse.objects.all()
            self.stdout.write("\n📖 Procesando: TODOS LOS LIBROS")

        total_verses = verses.count()
        updated_verses = 0
        changes_log = []

        self.stdout.write(f"📊 Total de versículos a procesar: {total_verses}")
        self.stdout.write(f"📋 Modo: {'DRY-RUN (Sin cambios)' if dry_run else 'CAMBIOS REALES'}")
        self.stdout.write('')

        # Procesar cada versículo
        for verse in verses:
            original_text = verse.text
            cleaned_text = self._clean_text(original_text)

            # Solo registrar si hay cambios
            if original_text != cleaned_text:
                updated_verses += 1
                change_record = {
                    'reference': f"{verse.chapter.book.name} {verse.chapter.number}:{verse.number}",
                    'before': original_text[:80] + ('...' if len(original_text) > 80 else ''),
                    'after': cleaned_text[:80] + ('...' if len(cleaned_text) > 80 else ''),
                    'bytes_saved': len(original_text) - len(cleaned_text),
                }
                changes_log.append(change_record)

                # Mostrar primeros cambios y cada 100
                if updated_verses <= 5 or updated_verses % 100 == 0:
                    self.stdout.write(
                        self.style.WARNING(f"✏️  [{updated_verses}] {change_record['reference']}:")
                    )
                    self.stdout.write(f"    ANTES: {change_record['before']}")
                    self.stdout.write(f"    AHORA: {change_record['after']}")
                    self.stdout.write('')

                # Guardar cambio si no es dry-run
                if not dry_run:
                    verse.text = cleaned_text
                    verse.save()

        # Eliminar ejercicios corruptos si se solicita
        exercises_deleted = 0
        if not dry_run and delete_exercises and updated_verses > 0:
            exercises_deleted = self._delete_corrupted_exercises()

        # Imprimir resumen
        self._print_summary(total_verses, updated_verses, changes_log, exercises_deleted, dry_run)

    def _clean_text(self, text):
        """
        Aplica todas las reglas de limpieza a un versículo.
        """
        if not text:
            return text

        # 1. Reemplazar caracteres especiales (ligaduras, caracteres raros)
        replacements = {
            'ĳ': 'ij',      # dĳo → dijo, bendĳo → bendijo
            'ſ': 's',       # Long s
            '–': '-',       # En-dash → hyphen
            '—': '-',       # Em-dash → hyphen
            '…': '...',     # Ellipsis
            '"': '"',       # Curly quotes
            '"': '"',
            ''': "'",       # Curly apostrophes
            ''': "'",
            '´': "'",       # Acute accent as apostrophe
            '`': "'",       # Grave accent
        }

        for old, new in replacements.items():
            text = text.replace(old, new)

        # 2. Eliminar guiones huérfanos (expan- sión → expansión)
        text = re.sub(r'(\w+)-\s+(\w+)', r'\1\2', text)

        # 3. Eliminar espacios múltiples
        text = re.sub(r' {2,}', ' ', text)

        # 4. Eliminar saltos de línea y tabulaciones
        text = re.sub(r'[\n\r\t]+', ' ', text)

        # 5. Limpiar espacios antes de puntuación
        text = re.sub(r'\s+([.,;:!?)\]¿¡])', r'\1', text)

        # 6. Limpiar espacios después de apertura
        text = re.sub(r'([\[(¿¡])\s+', r'\1', text)

        # 7. Arreglar problema de palabras duplicadas con punto y coma
        # Patrón: "morirás; rás" → "morirás"
        # Detecta: palabra + punto y coma + fragmento de la misma palabra
        def fix_word_duplication(match):
            word = match.group(1)
            return word + match.group(2)  # palabra + puntuación

        text = re.sub(r'(\w+)([;,])\s+(?:\w{1,3})\b', r'\1\2', text)

        # 8. Normalizar espacios inicio/final
        text = text.strip()

        # 9. Asegurar que no haya espacios antes de coma pero sí después
        text = re.sub(r',(?! )', ', ', text)

        return text

    def _delete_corrupted_exercises(self):
        """
        Elimina ejercicios que contienen texto corrupto.
        Esto fuerza su regeneración en la próxima lectura.
        """
        self.stdout.write(self.style.WARNING('\n' + '=' * 80))
        self.stdout.write(self.style.WARNING('🗑️  ELIMINANDO EJERCICIOS CORRUPTOS'))
        self.stdout.write(self.style.WARNING('=' * 80))

        # Patrones de corrupción a buscar
        corruption_patterns = [
            r';\s*[a-záéíóúñ]{1,3}(?=[\s.,;:!?)]|$)',  # "morirás; rás"
            r'(?:mo|rá|sé|la|el|de)-\s*',               # guiones huérfanos
            r'ĳ',                                        # ligadura ĳ aún presente
            r'[a-záéíóúñ]\s{2,}[a-záéíóúñ]',           # espacios dobles entre palabras
        ]

        exercises_to_delete = []

        for exercise in Exercise.objects.all():
            try:
                question_str = str(exercise.question_data or "")
                answer_str = str(exercise.answer_data or "")
                combined = question_str + " " + answer_str

                # Buscar patrones de corrupción
                for pattern in corruption_patterns:
                    if re.search(pattern, combined):
                        exercises_to_delete.append(exercise.id)
                        break
            except Exception:
                pass

        if exercises_to_delete:
            deleted_count, _ = Exercise.objects.filter(id__in=exercises_to_delete).delete()
            self.stdout.write(
                self.style.SUCCESS(f"✅ {deleted_count} ejercicio(s) eliminado(s)")
            )
            self.stdout.write(
                self.style.WARNING("📝 Los ejercicios se regenerarán en la próxima lectura (JIT)")
            )
            return deleted_count
        else:
            self.stdout.write(self.style.SUCCESS("✓ No se encontraron ejercicios corruptos"))
            return 0

    def _print_summary(self, total, updated, changes, exercises_deleted, dry_run):
        """Imprime resumen de cambios realizados."""
        self.stdout.write(self.style.SUCCESS('\n' + '=' * 80))
        self.stdout.write(self.style.SUCCESS('📊 RESUMEN DE LIMPIEZA'))
        self.stdout.write(self.style.SUCCESS('=' * 80))

        percentage = (updated / total * 100) if total > 0 else 0
        self.stdout.write(f"\n📚 VERSÍCULOS:")
        self.stdout.write(f"   Total procesados: {total}")
        self.stdout.write(f"   Actualizados: {updated} ({percentage:.1f}%)")

        if changes:
            total_bytes = sum(c['bytes_saved'] for c in changes)
            self.stdout.write(f"   Bytes liberados: {total_bytes:,}")

        self.stdout.write(f"\n🎯 EJERCICIOS:")
        self.stdout.write(f"   Eliminados (regeneración): {exercises_deleted}")

        mode_msg = "DRY-RUN (cambios simulados)" if dry_run else "CAMBIOS REALES GUARDADOS"
        self.stdout.write(f"\n📋 Modo: {mode_msg}")

        self.stdout.write(self.style.SUCCESS('\n✅ Limpieza completada exitosamente'))
        self.stdout.write(self.style.SUCCESS('=' * 80 + '\n'))
