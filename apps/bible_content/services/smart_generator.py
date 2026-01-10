import spacy
import random
from apps.bible_content.models import Verse
from apps.exercises.models import Exercise

# Load Spanish model (lightweight)
try:
    nlp = spacy.load("es_core_news_sm")
except OSError:
    # Fallback if not downloaded
    from spacy.cli import download
    download("es_core_news_sm")
    nlp = spacy.load("es_core_news_sm")

class SmartExerciseGenerator:
    """
    Generates varied exercises strictly from the lesson text.
    Optimized for Just-in-Time execution.
    """

    def generate_for_lesson(self, lesson):
        # 1. Fetch text
        verses = list(lesson.verses.all())
        if not verses:
            return 
        
        # Collect all significant words for distractors
        all_text = " ".join([v.text for v in verses])
        doc = nlp(all_text)
        
        # Valid candidates for blanks/distractors (Nouns, Proper Nouns, Verbs)
        candidates = [token.text for token in doc if token.pos_ in ['NOUN', 'PROPN', 'VERB'] and len(token.text) > 3]
        unique_candidates = list(set(candidates))

        generated_count = 0
        target_count = 10
        
        # Shuffle verses to pick random ones for exercises
        random.shuffle(verses)

        # Loop to generate varied exercises
        for verse in verses:
            if generated_count >= target_count:
                break
            
            # Determine exercise type based on modulo or random
            ex_type = generated_count % 3 
            
            if ex_type == 0: # CLOZE (Fill in the blank)
                self._create_cloze(verse, unique_candidates)
            elif ex_type == 1: # SCRAMBLE (Order sentence)
                if len(verse.text.split()) < 15: # Only short verses
                    self._create_scramble(verse)
                else:
                    self._create_cloze(verse, unique_candidates) # Fallback
            else: # SELECTION (Multiple Choice)
                self._create_selection(verse, unique_candidates)
                
            generated_count += 1
            
    def _create_cloze(self, verse, word_bank):
        doc = nlp(verse.text)
        # Find a good token to blank out
        targets = [t for t in doc if t.pos_ in ['NOUN', 'PROPN', 'VERB'] and len(t.text) > 3]
        
        if not targets:
            return

        target_token = random.choice(targets)
        text_masked = verse.text.replace(target_token.text, "_____", 1)
        
        Exercise.objects.create(
            verse=verse,
            exercise_type='cloze',
            question_data={'text': text_masked},
            answer_data={'correct': target_token.text}
        )

    def _create_scramble(self, verse):
        words = verse.text.split()
        random.shuffle(words)
        
        Exercise.objects.create(
            verse=verse,
            exercise_type='scramble',
            question_data={'words': words}, # Send shuffled list
            answer_data={'correct_order': verse.text.split()} # Send original ordered list
        )

    def _create_selection(self, verse, word_bank):
        doc = nlp(verse.text)
        targets = [t for t in doc if t.pos_ in ['NOUN', 'PROPN'] and len(t.text) > 3]
        
        if not targets:
            return

        target_token = random.choice(targets)
        text_question = verse.text.replace(target_token.text, "_____", 1)
        
        # Generate distractors from the word bank
        distractors = random.sample([w for w in word_bank if w != target_token.text], 3)
        options = distractors + [target_token.text]
        random.shuffle(options)

        Exercise.objects.create(
            verse=verse,
            exercise_type='cloze', # UI handles it as multiple choice if options present
            question_data={
                'text': text_question,
                'options': options
            },
            answer_data={'correct': target_token.text}
        )
