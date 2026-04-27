from django.db import models
from django.contrib.auth.models import User
from apps.bible_content.models import Verse
from apps.curriculum.models import Lesson


class Exercise(models.Model):
    """An exercise generated from a Bible verse."""
    EXERCISE_TYPES = [
        ('cloze', 'Completar espacio (Cloze)'),
        ('type_in', 'Escribir respuesta'),
        ('scramble', 'Ordenar palabras'),
        ('selection', 'Selección múltiple'),
        ('true_false', 'Verdadero o Falso'),
    ]

    DIFFICULTY_CHOICES = [
        (1, 'Fácil'),
        (2, 'Medio'),
        (3, 'Difícil'),
    ]

    lesson = models.ForeignKey(Lesson, on_delete=models.CASCADE, related_name='exercises')
    verse = models.ForeignKey(Verse, on_delete=models.CASCADE, related_name='exercises')
    exercise_type = models.CharField(max_length=20, choices=EXERCISE_TYPES)
    question_data = models.JSONField(
        help_text='Datos de la pregunta (formato depende del tipo de ejercicio)'
    )
    answer_data = models.JSONField(
        help_text='Datos de la respuesta correcta'
    )
    difficulty = models.IntegerField(choices=DIFFICULTY_CHOICES, default=1)
    order = models.IntegerField(default=0)

    class Meta:
        verbose_name = 'Ejercicio'
        verbose_name_plural = 'Ejercicios'
        ordering = ['lesson', 'order']

    def __str__(self):
        return f'{self.get_exercise_type_display()} - {self.verse}'


class UserExerciseAttempt(models.Model):
    """Records each attempt a user makes on an exercise."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='exercise_attempts')
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE, related_name='attempts')
    is_correct = models.BooleanField()
    answered_at = models.DateTimeField(auto_now_add=True)
    time_spent_seconds = models.IntegerField(default=0, help_text='Time spent on this exercise in seconds')

    class Meta:
        verbose_name = 'Intento de Ejercicio'
        verbose_name_plural = 'Intentos de Ejercicios'
        ordering = ['-answered_at']

    def __str__(self):
        result = '✓' if self.is_correct else '✗'
        return f'{result} {self.user.username} - {self.exercise}'
