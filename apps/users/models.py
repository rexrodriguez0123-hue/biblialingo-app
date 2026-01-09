from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils import timezone
from datetime import timedelta

class User(AbstractUser):
    """Custom user model."""
    pass

class UserProfile(models.Model):
    """Profile to hold gamification data."""
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    hearts = models.IntegerField(default=5)
    last_heart_regen = models.DateTimeField(default=timezone.now)
    gems = models.IntegerField(default=0)
    streak_days = models.IntegerField(default=0)
    last_activity_date = models.DateField(null=True, blank=True)
    timezone = models.CharField(max_length=50, default='UTC')

    def __str__(self):
        return f"Profile for {self.user.username}"

    def regenerate_hearts(self):
        """Regenerate hearts based on 4-hour timer."""
        now = timezone.now()
        if self.hearts < 5:
            time_diff = now - self.last_heart_regen
            hearts_to_add = int(time_diff.total_seconds() // (4 * 3600))
            if hearts_to_add > 0:
                self.hearts = min(5, self.hearts + hearts_to_add)
                # Reset timer if full, or advance it by the time used
                if self.hearts == 5:
                    self.last_heart_regen = now
                else:
                    self.last_heart_regen += timedelta(hours=hearts_to_add * 4)
                self.save()

from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)

@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    instance.profile.save()
