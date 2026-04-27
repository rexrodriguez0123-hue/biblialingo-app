from django.db import models
from django.contrib.auth.models import User
from apps.bible_content.models import Book, Chapter


class Course(models.Model):
    """A course covering a book of the Bible."""
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    book = models.ForeignKey(Book, on_delete=models.CASCADE, related_name='courses')
    order = models.IntegerField(default=1)

    class Meta:
        verbose_name = 'Curso'
        verbose_name_plural = 'Cursos'
        ordering = ['order']

    def __str__(self):
        return self.title


class Unit(models.Model):
    """A unit within a course, grouping several lessons."""
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='units')
    title = models.CharField(max_length=200)
    order = models.IntegerField()

    class Meta:
        verbose_name = 'Unidad'
        verbose_name_plural = 'Unidades'
        ordering = ['course', 'order']
        unique_together = ['course', 'order']

    def __str__(self):
        return f'{self.course.title} - {self.title}'


class Lesson(models.Model):
    """A single lesson covering a chapter or part of a chapter."""
    unit = models.ForeignKey(Unit, on_delete=models.CASCADE, related_name='lessons')
    title = models.CharField(max_length=200)
    chapter = models.ForeignKey(Chapter, on_delete=models.CASCADE, related_name='lessons')
    order = models.IntegerField(help_text='Global order across the course')
    verse_range_start = models.IntegerField(default=1)
    verse_range_end = models.IntegerField(null=True, blank=True, help_text='null = all verses in chapter')

    class Meta:
        verbose_name = 'Lección'
        verbose_name_plural = 'Lecciones'
        ordering = ['order']

    def __str__(self):
        return self.title


class UserLessonProgress(models.Model):
    """Tracks a user's progress on a specific lesson, including SRS data."""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='lesson_progress')
    lesson = models.ForeignKey(Lesson, on_delete=models.CASCADE, related_name='user_progress')

    # Progress
    is_completed = models.BooleanField(default=False)
    progress_percentage = models.FloatField(default=0.0, help_text='0.0 to 1.0')

    # Practice tracking
    last_practiced = models.DateTimeField(null=True, blank=True)
    next_practice_due = models.DateTimeField(null=True, blank=True)

    # SRS (SM-2 algorithm) fields
    easiness_factor = models.FloatField(default=2.5)
    interval = models.IntegerField(default=1, help_text='Days until next review')
    repetitions = models.IntegerField(default=0)

    class Meta:
        verbose_name = 'Progreso de Lección'
        verbose_name_plural = 'Progresos de Lecciones'
        unique_together = ['user', 'lesson']

    def __str__(self):
        return f'{self.user.username} - {self.lesson.title} ({self.progress_percentage:.0%})'
