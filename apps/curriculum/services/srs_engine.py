"""
SM-2 Spaced Repetition Algorithm for BibliaLingo.

Implements the SuperMemo 2 algorithm to schedule lesson reviews.
Fields used in UserLessonProgress:
  - easiness_factor (EF): float, default 2.5, min 1.3
  - interval: int (days), default 1
  - repetitions: int, default 0
  - next_practice_due: datetime

Quality mapping (from exercise performance):
  5 = Perfect (100% correct)
  4 = Good (80-99% correct)
  3 = Acceptable (60-79% correct)
  2 = Poor (40-59% correct)
  1 = Bad (20-39% correct)
  0 = Failure (0-19% correct)
"""
from datetime import timedelta
from django.utils import timezone


def calculate_quality(correct_count, total_count):
    """
    Convert exercise results to SM-2 quality score (0-5).

    Args:
        correct_count: number of correct answers
        total_count: total exercises attempted

    Returns:
        int: quality score 0-5
    """
    if total_count == 0:
        return 0

    ratio = correct_count / total_count

    if ratio >= 1.0:
        return 5
    elif ratio >= 0.8:
        return 4
    elif ratio >= 0.6:
        return 3
    elif ratio >= 0.4:
        return 2
    elif ratio >= 0.2:
        return 1
    else:
        return 0


def update_srs(progress, quality):
    """
    Apply the SM-2 algorithm to update a UserLessonProgress instance.

    Args:
        progress: UserLessonProgress instance
        quality: int 0-5 (quality of the response)

    Returns:
        The modified progress instance (not saved — caller must .save())
    """
    # SM-2 Algorithm
    if quality >= 3:
        # Correct response
        if progress.repetitions == 0:
            progress.interval = 1
        elif progress.repetitions == 1:
            progress.interval = 6
        else:
            progress.interval = round(progress.interval * progress.easiness_factor)

        progress.repetitions += 1
    else:
        # Incorrect — reset
        progress.repetitions = 0
        progress.interval = 1

    # Update easiness factor
    # EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
    ef_delta = 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)
    progress.easiness_factor = max(1.3, progress.easiness_factor + ef_delta)

    # Schedule next review
    progress.last_practiced = timezone.now()
    progress.next_practice_due = timezone.now() + timedelta(days=progress.interval)

    return progress


def get_lessons_due_for_review(user):
    """
    Get all lessons that are due for review for a given user.

    Returns a queryset of UserLessonProgress objects where
    next_practice_due <= now and is_completed = True.
    """
    from apps.curriculum.models import UserLessonProgress

    now = timezone.now()
    return UserLessonProgress.objects.filter(
        user=user,
        is_completed=True,
        next_practice_due__lte=now,
    ).select_related('lesson').order_by('next_practice_due')


def get_review_count(user):
    """Get the number of lessons due for review."""
    return get_lessons_due_for_review(user).count()
