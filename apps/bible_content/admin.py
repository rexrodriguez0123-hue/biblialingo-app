from django.contrib import admin
from .models import Book, Chapter, Verse, TheologicalTag, VerseTag


@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    list_display = ['name', 'abbreviation', 'testament', 'order']
    list_filter = ['testament']


@admin.register(Chapter)
class ChapterAdmin(admin.ModelAdmin):
    list_display = ['book', 'number']
    list_filter = ['book']


@admin.register(Verse)
class VerseAdmin(admin.ModelAdmin):
    list_display = ['chapter', 'number', 'short_text']
    list_filter = ['chapter__book']
    search_fields = ['text']

    def short_text(self, obj):
        return obj.text[:80] + '...' if len(obj.text) > 80 else obj.text
    short_text.short_description = 'Texto'


@admin.register(TheologicalTag)
class TheologicalTagAdmin(admin.ModelAdmin):
    list_display = ['name', 'category']
    list_filter = ['category']


@admin.register(VerseTag)
class VerseTagAdmin(admin.ModelAdmin):
    list_display = ['verse', 'tag']
    list_filter = ['tag__category']
