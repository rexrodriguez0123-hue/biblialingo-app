from django.contrib import admin
from .models import UserProfile


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'hearts', 'gems', 'streak_days', 'total_xp', 'last_practice_date']
    list_filter = ['streak_days']
    search_fields = ['user__username', 'user__email']
    readonly_fields = ['last_heart_regen']
