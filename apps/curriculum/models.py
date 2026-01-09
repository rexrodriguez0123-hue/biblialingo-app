from django.db import models
from apps.bible_content.models import Verse

class Course(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True)
    level = models.IntegerField(default=1)

    def __str__(self):
        return self.title

class Lesson(models.Model):
    course = models.ForeignKey(Course, on_delete=models.CASCADE, related_name='lessons')
    title = models.CharField(max_length=200)
    order = models.IntegerField()
    verses = models.ManyToManyField(Verse, related_name='lessons')

    class Meta:
        ordering = ['order']

    def __str__(self):
        return f"{self.course.title} - {self.title}"
