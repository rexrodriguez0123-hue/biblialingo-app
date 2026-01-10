import os
import json
import time
import google.generativeai as genai
from django.core.management.base import BaseCommand
from django.conf import settings
from apps.curriculum.models import Course, Lesson
from apps.exercises.models import Exercise
from apps.bible_content.models import Verse

class Command(BaseCommand):
    help = 'Generates smart exercises using Gemini AI'

    def add_arguments(self, parser):
        parser.add_argument('api_key', type=str, help='Gemini API Key')
        parser.add_argument('--chapter', type=int, help='Specific chapter number to process (optional)')

    def handle(self, *args, **options):
        api_key = options['api_key']
        target_chapter = options['chapter']

        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-1.5-flash')

        course = Course.objects.first()
        if not course:
            self.stdout.write(self.style.ERROR("No course found. Run populate_genesis first."))
            return

        lessons = course.lessons.all().order_by('order')
        if target_chapter:
            lessons = lessons.filter(order=target_chapter)

        self.stdout.write(f"Starting AI generation for {lessons.count()} lessons...")

        for lesson in lessons:
            self.stdout.write(f"Processing {lesson.title}...")
            
            # Fetch verses text for context
            verses = lesson.verses.all().order_by('number')
            if not verses.exists():
                self.stdout.write(f"Skipping {lesson.title} (no verses linked)")
                continue
                
            text_context = " ".join([v.text for v in verses[:20]]) # Limit context to first 20 verses to save tokens/complexity
            
            prompt = f"""
            Act as a Bible teacher. Create 3 varied exercises for a student learning Genesis Chapter {lesson.order} based on this text:
            "{text_context}..."

            Generate exactly 3 exercises in this JSON format:
            [
              {{
                "type": "question",
                "question": "Question text here?",
                "options": ["Option A", "Option B", "Option C"],
                "answer": "Correct Option Text"
              }},
              {{
                "type": "cloze",
                "text": "Sentence with _____ blank.",
                "answer": "word"
              }},
              {{
                "type": "scramble",
                "text": "Correct sentence order",
                "shuffled": ["order", "sentence", "Correct"]
              }}
            ]
            Return ONLY the valid JSON list. No markdown formatting.
            """

            try:
                response = model.generate_content(prompt)
                content = response.text.strip()
                # Clean markdown code blocks if present
                if content.startswith("```json"):
                    content = content[7:]
                if content.endswith("```"):
                    content = content[:-3]
                
                exercises_data = json.loads(content)
                
                # Clear existing old exercises for this lesson's verses (optional, or append?)
                # For MVP, let's just append or replacing might be better. 
                # Ideally, we attach these to the first verse or distributed?
                # Attaching to the first verse of the chapter is simplest for now.
                target_verse = verses.first()

                for ex in exercises_data:
                    ex_type = ex['type']
                    if ex_type == 'question':
                        # Mapping "question" to our "cloze" or need new type?
                        # Our frontend supports: cloze, type_in. 
                        # We need to adapt 'question' (multiple choice) to 'cloze' structure or add support.
                        # Wait, user asked for "preguntas". 
                        # Let's map "question" to "cloze" but with options data we put in question_data.
                        Exercise.objects.create(
                            verse=target_verse,
                            exercise_type='cloze', # We reuse cloze UI for multiple choice for now, or use type_in
                            question_data={'text': ex['question'], 'options': ex['options']},
                            answer_data={'correct': ex['answer']}
                        )
                    elif ex_type == 'cloze':
                        Exercise.objects.create(
                            verse=target_verse,
                            exercise_type='cloze',
                            question_data={'text': ex['text']},
                            answer_data={'correct': ex['answer']}
                        )
                    elif ex_type == 'scramble':
                        # We have scramble type in backend
                         Exercise.objects.create(
                            verse=target_verse,
                            exercise_type='scramble',
                            question_data={'words': ex['shuffled']},
                            answer_data={'correct_order': ex['text'].split()}
                        )
                
                self.stdout.write(self.style.SUCCESS(f"Generated 3 AI exercises for {lesson.title}"))
                time.sleep(1) # Avoid rate limits

            except Exception as e:
                import traceback
                self.stdout.write(self.style.ERROR(f"Failed to generate for {lesson.title}: {e}"))
                self.stdout.write(traceback.format_exc())

        self.stdout.write(self.style.SUCCESS("AI Generation Complete"))
