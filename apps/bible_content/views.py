from rest_framework import generics
from rest_framework.permissions import AllowAny
from .models import Book, Chapter, Verse
from .serializers import BookListSerializer, BookSerializer, ChapterSerializer, VerseSerializer


class BookListView(generics.ListAPIView):
    """List all books."""
    queryset = Book.objects.all()
    serializer_class = BookListSerializer
    permission_classes = [AllowAny]


class BookDetailView(generics.RetrieveAPIView):
    """Retrieve a book with its chapters."""
    queryset = Book.objects.prefetch_related('chapters')
    serializer_class = BookSerializer
    permission_classes = [AllowAny]


class ChapterDetailView(generics.RetrieveAPIView):
    """Retrieve a chapter with all its verses."""
    queryset = Chapter.objects.prefetch_related('verses')
    serializer_class = ChapterSerializer
    permission_classes = [AllowAny]


class VerseListView(generics.ListAPIView):
    """List verses for a specific chapter."""
    serializer_class = VerseSerializer
    permission_classes = [AllowAny]

    def get_queryset(self):
        chapter_id = self.kwargs['chapter_id']
        return Verse.objects.filter(chapter_id=chapter_id)
