import re
import random
import json
from apps.bible_content.models import Book, Chapter, Verse
from apps.curriculum.models import Lesson
from apps.exercises.models import Exercise

class BibleImporter:
    def __init__(self, course_id=1):
        self.course_id = course_id
    
    def parse_json(self, json_data, book_name="Génesis"):
        """
        Parses JSON data with structure:
        {
            "chapters": [
                ["Verse 1 text", "Verse 2 text", ...], # Chapter 1
                ["Verse 1 text", ...]                  # Chapter 2
            ]
        }
        """
        # Ensure Book exists
        current_book, _ = Book.objects.get_or_create(
            name=book_name, 
            defaults={
                'testament': 'Old',
                'order': 1  # Genesis is the first book
            }
        )
        
        chapters = json_data.get('chapters', [])
        
        for chapter_idx, verses_list in enumerate(chapters):
            chapter_num = chapter_idx + 1
            
            # Create Chapter
            current_chapter, _ = Chapter.objects.get_or_create(book=current_book, number=chapter_num)
            
            # Create Lesson for this Chapter
            lesson = None
            if self.course_id:
                lesson, _ = Lesson.objects.get_or_create(
                    course_id=self.course_id,
                    title=f"{book_name} {chapter_num}",
                    order=chapter_num,
                    defaults={}
                )
            
            print(f"Processing {book_name} {chapter_num} ({len(verses_list)} verses)...")

            for verse_idx, verse_text in enumerate(verses_list):
                verse_num = verse_idx + 1
                
                # Create Verse
                verse, created = Verse.objects.get_or_create(
                    chapter=current_chapter,
                    number=verse_num,
                    defaults={'text': verse_text, 'hebrew_text': ''}
                )
                
                # Link Verse to Lesson
                if lesson:
                    lesson.verses.add(verse)
                
                # Generate Exercises
                # Disabled in favor of JIT Smart Generation in API
                # if not verse.exercises.exists():
                #    self.generate_exercises(verse)

    def parse_text(self, text):
        """Legacy text parser"""
        lines = text.strip().split('\n')
        current_book_name = None
        current_book = None
        current_chapter_num = None
        current_chapter = None
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
                
            match = re.match(r'^(.+?)\s+(\d+):(\d+)\s+(.+)$', line)
            
            if match:
                book_name, chapter_num, verse_num, text_content = match.groups()
                chapter_num = int(chapter_num)
                verse_num = int(verse_num)
                
                if book_name != current_book_name:
                    current_book_name = book_name
                    current_book, _ = Book.objects.get_or_create(name=book_name, defaults={'testament': 'Old'})
                
                if chapter_num != current_chapter_num:
                    current_chapter_num = chapter_num
                    current_chapter, _ = Chapter.objects.get_or_create(book=current_book, number=chapter_num)
                    
                    if self.course_id:
                        Lesson.objects.get_or_create(
                            course_id=self.course_id,
                            title=f"{book_name} {chapter_num}",
                            order=chapter_num,
                            defaults={}
                        )

                verse, created = Verse.objects.get_or_create(
                    chapter=current_chapter,
                    number=verse_num,
                    defaults={'text': text_content, 'hebrew_text': ''}
                )
                self.generate_exercises(verse)

    def generate_exercises(self, verse):
        """Generates Cloze, Scramble, and Type-In exercises for a verse."""
        text = verse.text
        words = text.split()
        
        if len(words) < 3:
            return 
            
        # 1. Cloze Deletion
        valid_indices = [i for i, w in enumerate(words) if len(w) > 3]
        if valid_indices:
            idx = random.choice(valid_indices)
            answer = words[idx]
            clean_answer = re.sub(r'[^\w\s]', '', answer).lower()
            
            question_text = list(words)
            question_text[idx] = '_____'
            
            Exercise.objects.create(
                verse=verse,
                exercise_type='cloze',
                question_data={'text': ' '.join(question_text)},
                answer_data={'correct': clean_answer, 'display': answer}
            )

        # 2. Sentence Scramble
        scrambled = list(words)
        random.shuffle(scrambled)
        Exercise.objects.create(
            verse=verse,
            exercise_type='scramble',
            question_data={'words': scrambled},
            answer_data={'correct_order': words}
        )

        # 3. Type In
        Exercise.objects.create(
            verse=verse,
            exercise_type='type_in',
            question_data={'prompt': 'Escribe el versículo completo:'},
            answer_data={'text': text}
        )
