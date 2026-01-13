import spacy
import random
from apps.bible_content.models import Verse
from apps.exercises.models import Exercise

# Load Spanish model (lightweight)
try:
    nlp = spacy.load("es_core_news_sm")
except OSError:
    from spacy.cli import download
    download("es_core_news_sm")
    nlp = spacy.load("es_core_news_sm")

class SmartExerciseGenerator:
    """
    Generates exactly 10 varied exercises per lesson using NLP.
    Distribution: 1 Write, 2 Scramble, 3 Cloze, 2 Association, 2 True/False.
    """

    def generate_for_lesson(self, lesson):
        verses = list(lesson.verses.all())
        if not verses:
            return 
        
        # 1. Analyze global context for distractors/entities
        all_text = " ".join([v.text for v in verses])
        doc = nlp(all_text)
        
        # Word Bank (Nouns/Verbs) for distractors
        word_bank = list(set([t.text for t in doc if t.pos_ in ['NOUN', 'VERB'] and len(t.text) > 3]))
        
        # Entity Bank (People) for Association
        # Filter for PER (Person) entities roughly
        person_bank = list(set([ent.text for ent in doc.ents if ent.label_ in ['PER', 'PERSON']]))
        if len(person_bank) < 3:
            # Fallback to Proper Nouns if entity recognition is weak
            person_bank = list(set([t.text for t in doc if t.pos_ == 'PROPN']))

        # 2. Define Distribution Plan
        plan = [
            'write', 
            'scramble', 'scramble', 
            'cloze', 'cloze', 'cloze', 
            'association', 'association', 
            'true_false', 'true_false'
        ]
        
        # Shuffle verses to ensure variety
        random.shuffle(verses)
        verse_iterator = iter(verses)
        
        generated_count = 0
        
        for exercise_type in plan:
            # Try to generate specific type
            success = False
            attempts = 0
            
            # Try up to 5 different verses for this slot if needed
            while not success and attempts < 5:
                try:
                    verse = next(verse_iterator)
                except StopIteration:
                    # Recycle verses if we run out
                    random.shuffle(verses)
                    verse_iterator = iter(verses)
                    verse = next(verse_iterator)
                
                attempts += 1
                
                if exercise_type == 'write':
                    success = self._create_write(verse)
                elif exercise_type == 'scramble':
                    success = self._create_scramble(verse)
                elif exercise_type == 'cloze':
                    success = self._create_cloze(verse, word_bank)
                elif exercise_type == 'association':
                    success = self._create_association(verse, person_bank)
                elif exercise_type == 'true_false':
                    success = self._create_true_false(verse, word_bank)
            
            if success:
                generated_count += 1

    def _create_write(self, verse):
        Exercise.objects.create(
            verse=verse,
            exercise_type='type_in',
            question_data={'prompt': 'Escribe el versículo completo:'},
            answer_data={'text': verse.text}
        )
        return True

    def _create_scramble(self, verse):
        # Prefer shorter verses for scramble, but enforce limit
        words = verse.text.split()
        if len(words) > 20: 
            return False # Skip too long
            
        shuffled = list(words)
        random.shuffle(shuffled)
        
        Exercise.objects.create(
            verse=verse,
            exercise_type='scramble',
            question_data={'words': shuffled},
            answer_data={'correct_order': words}
        )
        return True

    def _create_cloze(self, verse, word_bank):
        doc = nlp(verse.text)
        targets = [t for t in doc if t.pos_ in ['NOUN', 'VERB'] and len(t.text) > 3]
        if not targets: 
            return False

        target = random.choice(targets)
        text_masked = verse.text.replace(target.text, "_____", 1)
        
        # Generate 5 options (Target + 4 Distractors)
        distractors = [w for w in word_bank if w != target.text]
        if len(distractors) < 4:
            return False
            
        options = random.sample(distractors, 4) + [target.text]
        random.shuffle(options)

        Exercise.objects.create(
            verse=verse,
            exercise_type='cloze',
            question_data={
                'text': text_masked,
                'options': options
            },
            answer_data={'correct': target.text}
        )
        return True

    def _create_association(self, verse, person_bank):
        doc = nlp(verse.text)
        # Find person/proper noun in this verse
        entities = [ent.text for ent in doc.ents if ent.label_ in ['PER', 'PERSON']] 
        if not entities:
            # Fallback to PROPN
            entities = [t.text for t in doc if t.pos_ == 'PROPN']
        
        if not entities:
            return False
            
        target_person = random.choice(entities)
        
        # Question: Who is mentioned?
        # Distractors: Other people from the chapter
        distractors = [p for p in person_bank if p != target_person]
        if len(distractors) < 2:
            return False # Not enough distinct people
            
        options = random.sample(distractors, 2) + [target_person]
        random.shuffle(options)
        
        Exercise.objects.create(
            verse=verse,
            exercise_type='selection', # New type mapping to Selection UI
            question_data={
                'text': f"¿Quién se menciona en este versículo?\n\n\"{verse.text}\"",
                'options': options
            },
            answer_data={'correct': target_person}
        )
        return True

    def _create_true_false(self, verse, word_bank):
        # Create a False version by swapping a noun
        doc = nlp(verse.text)
        nouns = [t for t in doc if t.pos_ == 'NOUN' and len(t.text) > 4]
        if not nouns:
            return False
            
        target_noun = random.choice(nouns)
        distractor_noun = random.choice([w for w in word_bank if w != target_noun.text])
        
        # Coin flip for True or False
        is_true = random.choice([True, False])
        
        if is_true:
            question_text = verse.text
            correct_answer = "Verdadero"
        else:
            question_text = verse.text.replace(target_noun.text, distractor_noun, 1)
            correct_answer = "Falso"
            
        Exercise.objects.create(
            verse=verse,
            exercise_type='true_false',
            question_data={
                'text': f"¿Es este versículo correcto?\n\n\"{question_text}\"",
                'options': ["Verdadero", "Falso"]
            },
            answer_data={'correct': correct_answer}
        )
        return True
