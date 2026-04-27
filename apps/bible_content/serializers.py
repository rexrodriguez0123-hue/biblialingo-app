from rest_framework import serializers
from .models import Book, Chapter, Verse, TheologicalTag


class VerseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Verse
        fields = ['id', 'number', 'text']


class ChapterSerializer(serializers.ModelSerializer):
    verses = VerseSerializer(many=True, read_only=True)

    class Meta:
        model = Chapter
        fields = ['id', 'number', 'verses']


class ChapterListSerializer(serializers.ModelSerializer):
    """Lighter serializer for listing chapters without all verses."""
    verse_count = serializers.IntegerField(source='verses.count', read_only=True)

    class Meta:
        model = Chapter
        fields = ['id', 'number', 'verse_count']


class BookSerializer(serializers.ModelSerializer):
    chapters = ChapterListSerializer(many=True, read_only=True)

    class Meta:
        model = Book
        fields = ['id', 'name', 'abbreviation', 'testament', 'order', 'chapters']


class BookListSerializer(serializers.ModelSerializer):
    chapter_count = serializers.IntegerField(source='chapters.count', read_only=True)

    class Meta:
        model = Book
        fields = ['id', 'name', 'abbreviation', 'testament', 'order', 'chapter_count']


class TheologicalTagSerializer(serializers.ModelSerializer):
    class Meta:
        model = TheologicalTag
        fields = ['id', 'name', 'category']
