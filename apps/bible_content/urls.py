from django.urls import path
from . import views

urlpatterns = [
    path('books/', views.BookListView.as_view(), name='book-list'),
    path('books/<int:pk>/', views.BookDetailView.as_view(), name='book-detail'),
    path('chapters/<int:pk>/', views.ChapterDetailView.as_view(), name='chapter-detail'),
    path('chapters/<int:chapter_id>/verses/', views.VerseListView.as_view(), name='verse-list'),
]
