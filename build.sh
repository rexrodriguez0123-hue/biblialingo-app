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
