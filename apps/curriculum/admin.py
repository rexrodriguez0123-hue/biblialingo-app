from django.contrib import admin
from .models import Course, Unit, Lesson, UserLessonProgress


class LessonInline(admin.TabularInline):
    model = Lesson
    extra = 0
    fields = ['title', 'chapter', 'order', 'verse_range_start', 'verse_range_end']


class UnitInline(admin.TabularInline):
    model = Unit
    extra = 0
    show_change_link = True


@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ['title', 'book', 'order']
    inlines = [UnitInline]


@admin.register(Unit)
class UnitAdmin(admin.ModelAdmin):
    list_display = ['title', 'course', 'order']
    list_filter = ['course']
    inlines = [LessonInline]


@admin.register(Lesson)
class LessonAdmin(admin.ModelAdmin):
    list_display = ['title', 'unit', 'chapter', 'order']
    list_filter = ['unit__course', 'unit']


@admin.register(UserLessonProgress)
class UserLessonProgressAdmin(admin.ModelAdmin):
    list_display = ['user', 'lesson', 'is_completed', 'progress_percentage', 'last_practiced']
    list_filter = ['is_completed', 'lesson__unit__course']
    search_fields = ['user__username']
