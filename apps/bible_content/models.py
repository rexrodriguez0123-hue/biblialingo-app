from django.db import models


class Book(models.Model):
    """A book of the Bible (e.g., Genesis)."""
    TESTAMENT_CHOICES = [
        ('AT', 'Antiguo Testamento'),
        ('NT', 'Nuevo Testamento'),
    ]

    name = models.CharField(max_length=100, help_text='Nombre del libro (ej. Génesis)')
    abbreviation = models.CharField(max_length=10, help_text='Abreviatura (ej. Gn)')
    testament = models.CharField(max_length=2, choices=TESTAMENT_CHOICES)
    order = models.IntegerField(unique=True, help_text='Orden en la Biblia (1=Génesis)')

    class Meta:
        verbose_name = 'Libro'
        verbose_name_plural = 'Libros'
        ordering = ['order']

    def __str__(self):
        return self.name


class Chapter(models.Model):
    """A chapter within a book."""
    book = models.ForeignKey(Book, on_delete=models.CASCADE, related_name='chapters')
    number = models.IntegerField(help_text='Número de capítulo')

    class Meta:
        verbose_name = 'Capítulo'
        verbose_name_plural = 'Capítulos'
        ordering = ['book', 'number']
        unique_together = ['book', 'number']

    def __str__(self):
        return f'{self.book.name} {self.number}'


class Verse(models.Model):
    """A single verse."""
    chapter = models.ForeignKey(Chapter, on_delete=models.CASCADE, related_name='verses')
    number = models.IntegerField(help_text='Número de versículo')
    text = models.TextField(help_text='Texto del versículo')

    class Meta:
        verbose_name = 'Versículo'
        verbose_name_plural = 'Versículos'
        ordering = ['chapter', 'number']
        unique_together = ['chapter', 'number']

    def __str__(self):
        return f'{self.chapter} : {self.number}'


class TheologicalTag(models.Model):
    """Tags for categorizing verses by theological theme."""
    CATEGORY_CHOICES = [
        ('tema', 'Tema'),
        ('festividad', 'Festividad'),
        ('profecia', 'Profecía'),
        ('doctrina', 'Doctrina'),
        ('personaje', 'Personaje'),
    ]

    name = models.CharField(max_length=100, unique=True)
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default='tema')

    class Meta:
        verbose_name = 'Etiqueta Teológica'
        verbose_name_plural = 'Etiquetas Teológicas'
        ordering = ['category', 'name']

    def __str__(self):
        return f'{self.name} ({self.get_category_display()})'


class VerseTag(models.Model):
    """Many-to-many relationship between verses and theological tags."""
    verse = models.ForeignKey(Verse, on_delete=models.CASCADE, related_name='tags')
    tag = models.ForeignKey(TheologicalTag, on_delete=models.CASCADE, related_name='verses')

    class Meta:
        verbose_name = 'Etiqueta de Versículo'
        verbose_name_plural = 'Etiquetas de Versículos'
        unique_together = ['verse', 'tag']

    def __str__(self):
        return f'{self.verse} → {self.tag}'
