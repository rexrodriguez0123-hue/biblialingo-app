"""
Management command to parse the Genesis RVR1960 text file and load it into the database.

Strategy: Extract ALL numbers from the text stream, then use the known
Genesis structure (verse counts per chapter) to build a sequence of expected
markers: 1:1, 1:2, ..., 1:31, 2:1, 2:2, ..., 50:26.
Walk through the extracted numbers matching them to expected markers.
"""
import re
import os
from django.core.management.base import BaseCommand
from apps.bible_content.models import Book, Chapter, Verse


GENESIS_VERSE_COUNTS = {
    1: 31, 2: 25, 3: 24, 4: 26, 5: 32, 6: 22, 7: 24, 8: 22, 9: 29, 10: 32,
    11: 32, 12: 20, 13: 18, 14: 24, 15: 21, 16: 16, 17: 27, 18: 33, 19: 38,
    20: 18, 21: 34, 22: 24, 23: 20, 24: 67, 25: 34, 26: 35, 27: 46, 28: 22,
    29: 35, 30: 43, 31: 55, 32: 32, 33: 20, 34: 31, 35: 29, 36: 43, 37: 36,
    38: 30, 39: 23, 40: 23, 41: 57, 42: 38, 43: 34, 44: 34, 45: 28, 46: 34,
    47: 31, 48: 22, 49: 33, 50: 26,
}


def build_expected_sequence():
    """Build the full sequence of (chapter, verse) markers expected in Genesis."""
    seq = []
    for ch in range(1, 51):
        max_v = GENESIS_VERSE_COUNTS[ch]
        # Chapter marker (same number as chapter)
        seq.append(('chapter', ch))
        for v in range(1, max_v + 1):
            seq.append(('verse', ch, v))
    return seq


class Command(BaseCommand):
    help = 'Parse the Genesis RVR1960 text file and load verses into the database'

    def add_arguments(self, parser):
        parser.add_argument('--file', type=str, default=None)
        parser.add_argument('--dry-run', action='store_true')

    def handle(self, *args, **options):
        file_path = options['file']
        if not file_path:
            from django.conf import settings
            file_path = os.path.join(
                settings.BASE_DIR, 'apps', 'bible_content', 'fixtures', 'genesis_rvr1960.txt'
            )

        if not os.path.exists(file_path):
            self.stderr.write(self.style.ERROR(f'File not found: {file_path}'))
            return

        self.stdout.write(f'Reading: {file_path}')
        with open(file_path, 'r', encoding='utf-8') as f:
            raw = f.read()

        verses = self._parse(raw)
        chs = set(v[0] for v in verses)
        self.stdout.write(f'Result: {len(verses)} verses in {len(chs)} chapters')

        if options['dry_run']:
            for ch, vn, txt in verses[:10]:
                self.stdout.write(f'  {ch}:{vn} - {txt[:80]}')
            self.stdout.write('  ...')
            for ch in sorted(chs):
                cnt = sum(1 for v in verses if v[0] == ch)
                exp = GENESIS_VERSE_COUNTS.get(ch, '?')
                st = 'OK' if cnt == exp else f'GOT {cnt}/{exp}'
                self.stdout.write(f'  Ch{ch}: {st}')
            return

        self._save(verses)
        self.stdout.write(self.style.SUCCESS('Done!'))

    def _clean_text(self, raw):
        """Clean the raw text: remove headers, fix hyphens, fix ligatures."""
        lines = raw.replace('\r', '').split('\n')

        clean = []
        for line in lines:
            line = line.replace('\f', '')
            s = line.strip()

            # Skip empty, headers, title
            if not s:
                continue
            if 'Génesis' in s or 'génesis' in s:
                continue
            if s.lower() in ('libro primero de moisés',):
                continue

            clean.append(line)

        # Join, fix hyphens
        text = ''
        for line in clean:
            s = line.rstrip()
            if s.endswith('-'):
                text += s[:-1]
            else:
                text += s + ' '

        # Fix ligatures
        text = text.replace('\u0133', 'ij')

        # Fix separated first letter
        text = re.sub(r'E\s{2,}n\s+el\s+principio', 'En el principio', text)

        # Collapse whitespace
        text = re.sub(r'\s+', ' ', text).strip()

        return text

    def _parse(self, raw):
        """Parse using the expected marker sequence approach."""
        text = self._clean_text(raw)
        words = text.split()

        # Build expected sequence of markers
        # For chapter 1: we expect markers 1,2 (paired), 3, 4, 5, 6, 7, ...
        # Some markers appear as pairs: "13, 14" or "1, 2"
        # The chapter marker appears as the chapter number right before verse 1

        # We'll track: current expected chapter & verse
        current_ch = 1
        current_v = 0  # Before first verse
        max_v = GENESIS_VERSE_COUNTS[1]
        next_verse = 1  # Next verse we expect to see a marker for

        verses = {}
        buf = []

        def save_verse(ch, v):
            """Save buffered text as verse text."""
            if buf:
                txt = ' '.join(buf).strip()
                if txt:
                    if (ch, v) in verses:
                        verses[(ch, v)] += ' ' + txt
                    else:
                        verses[(ch, v)] = txt
                buf.clear()

        wi = 0
        while wi < len(words):
            w = words[wi]
            wi += 1

            clean_w = w.strip('.,;:!?()[]')

            # Check for paired marker: "N," followed by "M"
            if re.match(r'^\d{1,2},$', w) and wi < len(words):
                next_clean = words[wi].strip('.,;:!?()')
                if re.match(r'^\d{1,2}$', next_clean):
                    n1 = int(w.rstrip(','))
                    n2 = int(next_clean)
                    # Check if this pair makes sense as verse markers
                    if n2 == n1 + 1 and self._matches_expected(n1, current_ch, next_verse, max_v):
                        save_verse(current_ch, n1)
                        current_v = n2
                        next_verse = n2 + 1
                        wi += 1  # consume second number
                        continue
                # Not a valid pair, treat first number individually
                # (fall through to single number check below)
                # But we already consumed w, so process it as single

            # Check for single number
            if re.match(r'^\d{1,2}$', clean_w):
                num = int(clean_w)

                # Priority 1: Is it the next expected verse?
                if self._matches_expected(num, current_ch, next_verse, max_v):
                    save_verse(current_ch, num)
                    current_v = num
                    next_verse = num + 1
                    continue

                # Priority 2: Is it a chapter marker?
                # A chapter marker occurs when:
                # - num equals next chapter
                # - We've processed all (or nearly all) verses of current chapter
                if self._is_chapter_marker(num, current_ch, current_v, max_v):
                    # Flush remaining text to last verse of current chapter
                    if buf and current_v > 0:
                        save_verse(current_ch, current_v)

                    current_ch = num
                    max_v = GENESIS_VERSE_COUNTS.get(num, 50)
                    current_v = 0
                    next_verse = 1
                    continue

                # Priority 3: Not a marker, it's a number in the text
                buf.append(w)
            else:
                buf.append(w)

        # Flush remaining
        if buf:
            if current_v > 0:
                nv = current_v + 1
                if nv <= max_v:
                    save_verse(current_ch, nv)
                else:
                    save_verse(current_ch, current_v)

        # Build result
        result = []
        for (ch, vn), txt in sorted(verses.items()):
            txt = re.sub(r'\s+', ' ', txt).strip()
            if txt:
                result.append((ch, vn, txt))
        return result

    def _matches_expected(self, num, current_ch, next_verse, max_v):
        """Check if num matches an expected verse marker."""
        if num < 1 or num > max_v:
            return False
        # Accept if it's the next expected verse, or up to 5 ahead
        # (some markers get absorbed into text)
        if next_verse <= num <= next_verse + 5:
            return True
        return False

    def _is_chapter_marker(self, num, current_ch, current_v, max_v):
        """
        Determine if num is a chapter transition marker.
        Key insight: chapter numbers in Genesis are 1-50.
        A chapter marker occurs when num = current_ch + 1 AND
        we've finished (or nearly finished) the current chapter.
        The tricky case is when current chapter has more verses than
        the next chapter number (e.g., ch31 has 55 verses, so verse 32
        looks like chapter 32). We disambiguate by checking proximity
        to the end of the chapter.
        """
        if num != current_ch + 1:
            return False
        if num > 50:
            return False

        # If num > max_v, it can't be a verse, so it must be a chapter marker
        if num > max_v:
            return True

        # If num <= max_v, it COULD be a verse number.
        # It's a chapter marker only if we've already processed nearly all verses
        # (within 3 of the maximum)
        if current_v >= max_v - 3:
            return True

        return False

    def _save(self, verses):
        book, created = Book.objects.get_or_create(
            name='Génesis',
            defaults={'abbreviation': 'Gn', 'testament': 'AT', 'order': 1}
        )
        if not created:
            book.chapters.all().delete()
            self.stdout.write('  Cleared old data')

        ch_data = {}
        for ch, vn, txt in verses:
            ch_data.setdefault(ch, []).append((vn, txt))

        total = 0
        for ch_num in sorted(ch_data.keys()):
            chapter = Chapter.objects.create(book=book, number=ch_num)
            for vn, txt in sorted(ch_data[ch_num]):
                Verse.objects.create(chapter=chapter, number=vn, text=txt)
                total += 1

        self.stdout.write(f'  {len(ch_data)} chapters, {total} verses')
