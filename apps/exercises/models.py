from django.db import models
from django.conf import settings
from apps.bible_content.models import Verse
from .utils import SM2

class Exercise(models.Model):
    TYPE_CHOICES = [
        ('cloze', 'Cloze Deletion'),
        ('scramble', 'Sentence Scramble'),
    ]
    verse = models.ForeignKey(Verse, on_delete=models.CASCADE, related_name='exercises')
    exercise_type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    question_data = models.JSONField(help_text="Structure depends on type")
    answer_data = models.JSONField(help_text="Correct answer(s)")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.exercise_type} - {self.verse}"

class UserProgress(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='progress')
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE, related_name='user_progress')
    easiness_factor = models.FloatField(default=2.5)
    interval = models.IntegerField(default=0)
    repetitions = models.IntegerField(default=0)
    next_practice_due = models.DateTimeField(null=True, blank=True)
    last_practiced = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ['user', 'exercise']

    def update_progress(self, quality):
        """Update SM-2 parameters based on quality (0-5)."""
        from django.utils import timezone
        from datetime import timedelta
        
        new_interval, new_reps, new_ef = SM2.calculate(
            quality, 
            self.repetitions, 
            self.interval, 
            self.easiness_factor
        )
        
        self.interval = new_interval
        self.repetitions = new_reps
        self.easiness_factor = new_ef
        self.next_practice_due = timezone.now() + timedelta(days=new_interval)
        self.save()
