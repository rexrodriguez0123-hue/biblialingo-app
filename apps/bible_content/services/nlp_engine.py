"""
NLP Engine for Camino Biblico.

Generates exercises from Bible verses using SpaCy for linguistic analysis.
Supports 5 exercise types:
  - cloze: Fill in the blank (key word removed)
  - type_in: Type the missing word (based on a hint/context)
  - scramble: Reorder scrambled words of a verse
  - selection: Multiple choice (select the correct word)
  - true_false: True or false statement about the verse

VALIDACIONES:
- Detecta y rechaza ejercicios con texto corrupto (ej: "morirás; rás")
- Valida que el texto esté limpio (sin caracteres especiales)
- Evita ejercicios con saltos abruptos de línea
"""
import random
import re
import spacy

# Load SpaCy model (lazy singleton)
_nlp = None

# Patrones de corrupción a detectar
_CORRUPTION_PATTERNS = [
    r';\s*[a-záéíóúñ]{1,3}(?=[\s.,;:!?)\]¿¡]|$)',  # "morirás; rás"
    r'(?:mo|rá|sé|la|el|de)-\s*(?=[a-z])',          # "ex- pansión"
    r'ĳ',                                            # ligadura ĳ aún presente
    r'[a-záéíóúñ]\s{2,}[a-záéíóúñ]',               # espacios dobles entre palabras
    r'del$',                                         # versículos incompletos (ej: "...tomó del")
    r'que\s+(?:el|la)\s*$',                         # frase sin terminar
]


def get_nlp():
    """Lazy-load the SpaCy model."""
    global _nlp
    if _nlp is None:
        _nlp = spacy.load('es_core_news_sm')
    return _nlp


def _is_text_corrupted(text):
    """
    Detecta si un texto está corrupto basándose en patrones conocidos.
    
    Returns:
        bool: True si el texto tiene signos de corrupción
    """
    if not text:
        return False
    
    for pattern in _CORRUPTION_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            return True
    
    return False


def _is_exercise_valid(exercise):
    """
    Valida que un ejercicio no contenga texto corrupto.
    
    Args:
        exercise (dict): Diccionario de ejercicio con exercise_type, question_data, answer_data
        
    Returns:
        bool: True si el ejercicio es válido
    """
    if not exercise:
        return False
    
    try:
        # Concatenar todos los textos del ejercicio
        texts_to_check = []
        
        if 'question_data' in exercise:
            qd = exercise['question_data']
            if isinstance(qd, dict):
                texts_to_check.extend([
                    qd.get('text', ''),
                    qd.get('context', ''),
                    qd.get('statement', ''),
                    str(qd.get('template', '')),
                ])
        
        if 'answer_data' in exercise:
            ad = exercise['answer_data']
            if isinstance(ad, dict):
                texts_to_check.extend([
                    ad.get('correct', ''),
                    ad.get('explanation', ''),
                ])
        
        # Validar que ningún texto esté corrupto
        combined_text = ' '.join(str(t) for t in texts_to_check if t)
        
        if _is_text_corrupted(combined_text):
            return False
        
        return True
        
    except Exception:
        return False


def generate_exercises_for_verse(verse_text, verse_id=None, num_exercises=2):
    """
    Generate a list of exercise dicts from a single verse.

    Returns list of dicts with keys:
        exercise_type, question_data, answer_data, difficulty
    
    NOTA: Rechaza automáticamente ejercicios que contienen texto corrupto.
    """
    # Validar que el versículo en sí no esté corrupto
    if _is_text_corrupted(verse_text):
        return []
    
    nlp = get_nlp()
    doc = nlp(verse_text)

    exercises = []

    # Get candidate words for cloze/selection (nouns, verbs, adjectives)
    key_tokens = [
        tok for tok in doc
        if tok.pos_ in ('NOUN', 'VERB', 'ADJ', 'PROPN')
        and len(tok.text) > 2
        and not tok.is_stop
        and tok.is_alpha
    ]

    # Fallback: if no key tokens, use any non-stop word > 3 chars
    if len(key_tokens) < 2:
        key_tokens = [
            tok for tok in doc
            if len(tok.text) > 3 and not tok.is_stop and tok.is_alpha
        ]

    # Shuffle to get variety
    random.shuffle(key_tokens)

    generators = [
        _generate_cloze,
        _generate_selection,
        _generate_scramble,
        _generate_type_in,
        _generate_true_false,
    ]

    # Try each generator, collect up to num_exercises
    attempts = 0
    gen_index = 0
    while len(exercises) < num_exercises and attempts < num_exercises * 3:
        generator = generators[gen_index % len(generators)]
        try:
            ex = generator(verse_text, doc, key_tokens)
            # Validar que el ejercicio no sea corrupto
            if ex and ex not in exercises and _is_exercise_valid(ex):
                exercises.append(ex)
        except Exception:
            pass
        gen_index += 1
        attempts += 1

    return exercises


def generate_exercises_for_lesson(verses, exercises_per_verse=2):
    """
    Generate exercises for a full lesson (list of verses).
    Rotates exercise types across verses for variety.

    Args:
        verses: list of (verse_id, verse_number, verse_text) tuples
        exercises_per_verse: how many exercises to generate per verse

    Returns:
        list of dicts ready to create Exercise objects
    
    NOTA: Valida automáticamente que los ejercicios no contengan texto corrupto.
    """
    nlp = get_nlp()
    all_exercises = []

    # Collect all verse texts for distractor generation
    all_texts = [v[2] for v in verses]
    all_key_words = _extract_all_keywords(all_texts)

    # Rotate through all 5 types to ensure variety across the lesson
    all_generators = [
        _generate_cloze,
        _generate_selection,
        _generate_scramble,
        _generate_type_in,
        _generate_true_false,
    ]

    order = 1
    type_index = 0

    for verse_id, verse_number, verse_text in verses:
        if not verse_text or len(verse_text.split()) < 4:
            continue
        
        # Saltar versículos corruptos
        if _is_text_corrupted(verse_text):
            continue

        doc = nlp(verse_text)

        key_tokens = [
            tok for tok in doc
            if tok.pos_ in ('NOUN', 'VERB', 'ADJ', 'PROPN')
            and len(tok.text) > 2
            and not tok.is_stop
            and tok.is_alpha
        ]
        if len(key_tokens) < 2:
            key_tokens = [
                tok for tok in doc
                if len(tok.text) > 3 and not tok.is_stop and tok.is_alpha
            ]

        random.shuffle(key_tokens)
        verse_exercises = []

        # Try to generate exercises_per_verse exercises, rotating types
        attempts = 0
        while len(verse_exercises) < exercises_per_verse and attempts < exercises_per_verse * 5:
            gen = all_generators[type_index % len(all_generators)]
            type_index += 1
            attempts += 1
            try:
                ex = gen(verse_text, doc, key_tokens)
                # Validar que el ejercicio no sea corrupto
                if ex and _is_exercise_valid(ex):
                    # Enrich selection exercises with cross-verse distractors
                    if ex['exercise_type'] == 'selection' and all_key_words:
                        correct = ex['answer_data']['correct']
                        distractors = _get_distractors(correct, all_key_words, n=3)
                        if distractors:
                            ex['question_data']['options'] = distractors + [correct]
                            random.shuffle(ex['question_data']['options'])

                    ex['verse_id'] = verse_id
                    ex['order'] = order
                    order += 1
                    verse_exercises.append(ex)
            except Exception:
                pass

        all_exercises.extend(verse_exercises)

    return all_exercises


# ---------------------------------------------------------------------------
# Exercise Generators
# ---------------------------------------------------------------------------

def _generate_cloze(verse_text, doc, key_tokens):
    """
    Cloze deletion: remove a key word and replace with _____.

    question_data: {"text": "En el principio creó _____ los cielos...", "hint": "D"}
    answer_data:   {"correct": "Dios"}
    """
    if not key_tokens:
        return None

    target = random.choice(key_tokens)
    word = target.text

    # Replace the word with blanks
    cloze_text = verse_text[:target.idx] + '_____' + verse_text[target.idx + len(word):]

    # Hint: first letter
    hint = word[0].upper()

    return {
        'exercise_type': 'cloze',
        'question_data': {
            'text': cloze_text,
            'hint': hint,
        },
        'answer_data': {
            'correct': word,
        },
        'difficulty': 1 if len(word) <= 5 else 2,
    }


def _generate_selection(verse_text, doc, key_tokens):
    """
    Multiple choice: which word completes the verse?

    question_data: {"text": "En el principio creó _____ los cielos...", "options": ["Dios", "Abel", "tierra", "luz"]}
    answer_data:   {"correct": "Dios"}
    """
    if not key_tokens:
        return None

    target = random.choice(key_tokens)
    word = target.text

    cloze_text = verse_text[:target.idx] + '_____' + verse_text[target.idx + len(word):]

    # Generate distractors from other tokens in the doc
    distractors = []
    for tok in doc:
        if (tok.text != word and tok.pos_ == target.pos_
                and tok.is_alpha and len(tok.text) > 2
                and tok.text not in distractors):
            distractors.append(tok.text)
        if len(distractors) >= 3:
            break

    # Pad with generic Bible words if needed
    bible_words = [
        'tierra', 'cielo', 'Dios', 'hombre', 'mujer', 'agua', 'luz',
        'día', 'noche', 'vida', 'muerte', 'bien', 'mal', 'hijo',
        'padre', 'madre', 'hermano', 'pueblo', 'casa', 'campo',
    ]
    while len(distractors) < 3:
        w = random.choice(bible_words)
        if w != word and w not in distractors:
            distractors.append(w)

    options = distractors[:3] + [word]
    random.shuffle(options)

    return {
        'exercise_type': 'selection',
        'question_data': {
            'text': cloze_text,
            'options': options,
        },
        'answer_data': {
            'correct': word,
        },
        'difficulty': 1,
    }


def _generate_scramble(verse_text, doc, key_tokens):
    """
    Drag and drop fill-in-the-blanks style.
    Replaces up to 7 words with blanks.
    """
    # Split using spaces to keep punctuation attached to words
    raw_words = verse_text.split()
    
    if len(raw_words) < 3:
        return None
        
    num_blanks = min(7, len(raw_words) - 1)
    if num_blanks < 1:
        num_blanks = 1
        
    # Pick indices to blank out
    indices_to_blank = sorted(random.sample(range(len(raw_words)), num_blanks))
    
    template = []
    correct_words = []
    
    for i, word in enumerate(raw_words):
        if i in indices_to_blank:
            template.append("[BLANK]")
            correct_words.append(word)
        else:
            template.append(word)
            
    scrambled = list(correct_words)
    attempts = 0
    while scrambled == correct_words and attempts < 10:
        random.shuffle(scrambled)
        attempts += 1
        
    return {
        'exercise_type': 'scramble',
        'question_data': {
            'template': template,
            'words': scrambled,
        },
        'answer_data': {
            'correct_order': correct_words,
        },
        'difficulty': 2 if len(raw_words) > 7 else 1,
    }


def _generate_type_in(verse_text, doc, key_tokens):
    """
    Type-in: given a partial verse with context, type the missing word.

    question_data: {"context": "En el principio creó ____ los cielos y la tierra.", "word_length": 4}
    answer_data:   {"correct": "Dios", "accept": ["dios", "DIOS"]}
    """
    if not key_tokens:
        return None

    target = random.choice(key_tokens)
    word = target.text

    context = verse_text[:target.idx] + '____' + verse_text[target.idx + len(word):]

    return {
        'exercise_type': 'type_in',
        'question_data': {
            'context': context,
            'word_length': len(word),
        },
        'answer_data': {
            'correct': word,
            'accept': [word.lower(), word.upper(), word.capitalize()],
        },
        'difficulty': 2,
    }


def _generate_true_false(verse_text, doc, key_tokens):
    """
    True/False: present a statement that is either the original verse
    or a modified version, and ask if it's correct.

    question_data: {"statement": "En el principio creó Abel los cielos...", "original_ref": "Génesis 1:1"}
    answer_data:   {"correct": false, "explanation": "La palabra correcta es 'Dios', no 'Abel'."}
    """
    if not key_tokens:
        return None

    # 50% chance of true statement, 50% false
    is_true = random.random() > 0.5

    if is_true:
        statement = verse_text
        return {
            'exercise_type': 'true_false',
            'question_data': {
                'statement': statement,
                'instruction': '¿Este versículo está escrito correctamente?',
            },
            'answer_data': {
                'correct': True,
                'explanation': 'El versículo está escrito correctamente.',
            },
            'difficulty': 1,
        }
    else:
        # Swap a key word with a different one
        target = random.choice(key_tokens)
        word = target.text

        # Get a replacement word of same POS
        replacements = [
            tok.text for tok in doc
            if tok.pos_ == target.pos_ and tok.text != word
            and tok.is_alpha and len(tok.text) > 2
        ]
        if not replacements:
            bible_replacements = {
                'NOUN': ['tierra', 'cielo', 'agua', 'monte', 'campo'],
                'VERB': ['creó', 'dijo', 'hizo', 'vio', 'llamó'],
                'PROPN': ['Abel', 'Noé', 'Sara', 'Isaac', 'Jacob'],
                'ADJ': ['bueno', 'grande', 'santo', 'nuevo', 'justo'],
            }
            replacements = bible_replacements.get(target.pos_, ['algo'])

        replacement = random.choice(replacements)
        false_statement = verse_text[:target.idx] + replacement + verse_text[target.idx + len(word):]

        return {
            'exercise_type': 'true_false',
            'question_data': {
                'statement': false_statement,
                'instruction': '¿Este versículo está escrito correctamente?',
            },
            'answer_data': {
                'correct': False,
                'explanation': f'La palabra correcta es "{word}", no "{replacement}".',
            },
            'difficulty': 2,
        }


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _extract_all_keywords(texts):
    """Extract key words from multiple texts for cross-verse distractors."""
    nlp = get_nlp()
    keywords = set()
    for text in texts:
        doc = nlp(text)
        for tok in doc:
            if (tok.pos_ in ('NOUN', 'VERB', 'ADJ', 'PROPN')
                    and tok.is_alpha and len(tok.text) > 2 and not tok.is_stop):
                keywords.add(tok.text)
    return list(keywords)


def _get_distractors(correct_word, word_pool, n=3):
    """Get n distractor words from the pool, excluding the correct answer."""
    candidates = [w for w in word_pool if w.lower() != correct_word.lower()]
    if len(candidates) < n:
        return candidates
    return random.sample(candidates, n)

