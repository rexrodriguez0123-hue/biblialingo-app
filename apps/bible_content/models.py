from django.db import models

class Book(models.Model):
    TESTAMENT_CHOICES = [
        ('OT', 'Old Testament'),
        ('NT', 'New Testament'),
    ]
    name = models.CharField(max_length=100)
    testament = models.CharField(max_length=2, choices=TESTAMENT_CHOICES)
    order = models.IntegerField()

    def __str__(self):
        return self.name

class Chapter(models.Model):
    book = models.ForeignKey(Book, on_delete=models.CASCADE, related_name='chapters')
    number = models.IntegerField()

    class Meta:
        ordering = ['number']

    def __str__(self):
        return f"{self.book.name} {self.number}"

class TheologicalTag(models.Model):
    name = models.CharField(max_length=100)
    category = models.CharField(max_length=100, help_text="e.g., Festivity, Doctrine")

    def __str__(self):
        return f"{self.name} ({self.category})"

class Verse(models.Model):
    chapter = models.ForeignKey(Chapter, on_delete=models.CASCADE, related_name='verses')
    number = models.IntegerField()
    text = models.TextField()
    tags = models.ManyToManyField(TheologicalTag, blank=True, related_name='verses')

    class Meta:
        ordering = ['number']

    def __str__(self):
        return f"{self.chapter} :{self.number}"
