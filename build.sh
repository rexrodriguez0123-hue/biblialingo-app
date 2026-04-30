#!/usr/bin/env bash
# Exit on error
set -o errexit

echo "Installing dependencies..."
pip install -r requirements.txt

echo "Downloading SpaCy Spanish model..."
python -m spacy download es_core_news_sm

echo "Collecting static files..."
python manage.py collectstatic --no-input

echo "Running database migrations..."
python manage.py migrate

echo "Checking if initial database population is required..."
python manage.py shell -c "from apps.bible_content.models import Book; exit(0) if Book.objects.filter(name='Génesis').exists() else exit(1)" || (
    echo "Initial data not found. Running load_genesis and generate_genesis_curriculum..."
    python manage.py load_genesis
    python manage.py generate_genesis_curriculum
)

echo "Applying specific text corrections for Genesis 1..."
python fix_genesis_1.py

echo "Creating superuser if it doesn't exist..."
python manage.py shell -c "from django.contrib.auth.models import User; User.objects.filter(username='admin').exists() or User.objects.create_superuser('admin', 'rexrodriguez0123@gmail.com', 'rexCamino Biblico.')"

echo "Clearing ALL old exercises to force complete JIT regeneration..."
python manage.py shell -c "from apps.exercises.models import Exercise; Exercise.objects.all().delete()"

