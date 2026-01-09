import random
import spacy
from datetime import timedelta
from django.utils import timezone

# Try to load spacy model, fallback if not present (for initial setup)
try:
    nlp = spacy.load("es_core_news_sm")
except OSError:
    nlp = None

class SM2:
    @staticmethod
    def calculate(quality, repetitions, previous_interval, previous_easiness_factor):
        """
        Calculate new SM-2 parameters.
        quality: 0-5 rating of user's answer.
        """
        if quality >= 3:
            if repetitions == 0:
                interval = 1
            elif repetitions == 1:
                interval = 6
            else:
                interval = int(previous_interval * previous_easiness_factor)
            
            repetitions += 1
            easiness_factor = previous_easiness_factor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
        else:
            repetitions = 0
            interval = 1
            easiness_factor = previous_easiness_factor
        
        if easiness_factor < 1.3:
            easiness_factor = 1.3
            
        return interval, repetitions, easiness_factor

class NLPEngine:
    @staticmethod
    def generate_cloze(text):
        """
        Generate a cloze deletion exercise.
        Returns the text with blanks and the missing words.
        """
        if not nlp:
            # Fallback if spacy not installed/model missing
            words = text.split()
            if not words:
                return text, []
            idx = random.randint(0, len(words)-1)
            missing_word = words[idx]
            words[idx] = "______"
            return " ".join(words), [missing_word]

        doc = nlp(text)
        # Select tokens to mask (verbs, nouns, adjectives)
        candidates = [token for token in doc if token.pos_ in ["VERB", "NOUN", "ADJ"] and not token.is_punct]
        
        if not candidates:
            candidates = [token for token in doc if not token.is_punct]
            
        if not candidates:
             return text, []

        # Mask 1-2 words
        num_to_mask = min(len(candidates), 2)
        to_mask = random.sample(candidates, num_to_mask)
        
        masked_text = text
        answers = []
        
        # Sort by position reverse to avoid index shifting issues if we were doing index replacement
        # But here we do string replacement (simple version) or token reconstruction
        # Better: reconstruct string
        
        result_tokens = []
        for token in doc:
            if token in to_mask:
                result_tokens.append("______")
                answers.append(token.text)
            else:
                result_tokens.append(token.text_with_ws)
                
        return "".join(result_tokens), answers

    @staticmethod
    def generate_scramble(text):
        """
        Generate a sentence scramble exercise.
        """
        if not nlp:
            words = text.split()
            random.shuffle(words)
            return words

        doc = nlp(text)
        tokens = [token.text for token in doc if not token.is_punct]
        random.shuffle(tokens)
        return tokens
