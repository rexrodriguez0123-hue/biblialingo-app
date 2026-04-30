from django.db import models
from django.contrib.auth.models import User


class UserProfile(models.Model):
    """
    Extended user profile for Camino Biblico.
    Stores gamification data, preferences, and practice tracking.
    """
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')

    # Gamification
    hearts = models.IntegerField(default=5, help_text='Vidas disponibles (máx 5)')
    gems = models.IntegerField(default=0, help_text='Gemas acumuladas')
    streak_days = models.IntegerField(default=0, help_text='Días consecutivos de práctica')
    total_xp = models.IntegerField(default=0, help_text='Experiencia total acumulada')

    # Practice tracking
    last_practice_date = models.DateField(null=True, blank=True)
    last_heart_regen = models.DateTimeField(null=True, blank=True)

    # Preferences
    timezone = models.CharField(max_length=50, default='America/Bogota')
    theological_preferences = models.JSONField(
        default=dict,
        blank=True,
        help_text='Preferencias teológicas del usuario (ej. excluir festividades)'
    )

    class Meta:
        verbose_name = 'Perfil de Usuario'
        verbose_name_plural = 'Perfiles de Usuarios'

    def __str__(self):
        return f'Perfil de {self.user.username}'

