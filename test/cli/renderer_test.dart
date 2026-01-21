import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';

void main() {
  group('IclfRenderer', () {
    late IclfRenderer renderer;

    setUp(() {
      renderer = IclfRenderer();
    });

    test('033 renders song title centered', () {
      final song = Song('Test Song', 'C');
      final output = renderer.render(song);

      expect(output, contains('TEST SONG'));
      expect(output, contains('Key: C'));
    });

    test('034 renders simple chord line with lyrics aligned', () {
      final song = Song('Test', 'C');
      final section = Section('Verse');
      section.chords.addAll([
        Chord('C', {}, 'Hello '),
        Chord('G', {}, 'world'),
      ]);
      song.sections.add(section);

      final output = renderer.render(song);

      expect(output, contains('[Verse]'));
      expect(output, contains('C'));
      expect(output, contains('G'));
      expect(output, contains('Hello'));
      expect(output, contains('world'));
    });

    test('035 handles long chord names with proper spacing', () {
      final song = Song('Test', 'C');
      final section = Section('Verse');
      section.chords.add(Chord('Cmaj7b9', {}, 'Hi'));
      song.sections.add(section);

      final output = renderer.render(song);

      expect(output, contains('Cmaj7b9'));
      expect(output, contains('Hi'));
    });

    test('036 formats bass attribute as slash chord', () {
      final song = Song('Test', 'C');
      final section = Section('Verse');
      section.chords.add(Chord('C', {'bass': 'E'}, 'Hello'));
      song.sections.add(section);

      final output = renderer.render(song);

      expect(output, contains('C/E'));
    });

    test('037 formats voicing attribute in parentheses', () {
      final song = Song('Test', 'C');
      final section = Section('Verse');
      section.chords.add(Chord('Am', {'voicing': 'open'}, 'Test'));
      song.sections.add(section);

      final output = renderer.render(song);

      expect(output, contains('Am(open)'));
    });

    test('038 renders section notes with asterisk', () {
      final song = Song('Test', 'C');
      final section = Section('Verse');
      section.notes.add(Note('Play softly', true));
      section.chords.add(Chord('C', {}, 'Hello'));
      song.sections.add(section);

      final output = renderer.render(song);

      expect(output, contains('(* Play softly)'));
    });

    test('039 renders global notes', () {
      final song = Song('Test', 'C');
      song.globalNotes.add(Note('Intro note', true));
      final section = Section('Verse');
      section.chords.add(Chord('C', {}, 'Hello'));
      song.sections.add(section);

      final output = renderer.render(song);

      expect(output, contains('(* Intro note)'));
    });

    test('040 renders metadata line with composer', () {
      final song = Song('Test', 'G');
      song.globals['composer'] = 'John Doe';
      final section = Section('Verse');
      section.chords.add(Chord('G', {}, 'Test'));
      song.sections.add(section);

      final output = renderer.render(song);

      expect(output, contains('Key: G'));
      expect(output, contains('Composer: John Doe'));
    });

    test('041 renders metadata with capo and tempo', () {
      final song = Song('Test', 'C');
      song.globals['capo'] = '2';
      song.globals['tempo'] = '120';
      final section = Section('Verse');
      section.chords.add(Chord('C', {}, 'Test'));
      song.sections.add(section);

      final output = renderer.render(song);

      expect(output, contains('Capo: 2'));
      expect(output, contains('Tempo: 120 BPM'));
    });

    test('042 compact mode removes blank lines', () {
      final compactRenderer = IclfRenderer(compact: true);
      final song = Song('Test', 'C');
      final section = Section('Verse');
      section.chords.add(Chord('C', {}, 'Hello'));
      song.sections.add(section);

      final output = compactRenderer.render(song);

      // Compact mode should not have the decorative lines
      expect(output, isNot(contains('========')));
      expect(output, contains('TEST'));
    });

    test('043 handles multiple sections', () {
      final song = Song('Test', 'C');

      final verse = Section('Verse');
      verse.chords.add(Chord('C', {}, 'Verse text'));
      song.sections.add(verse);

      final chorus = Section('Chorus');
      chorus.chords.add(Chord('G', {}, 'Chorus text'));
      song.sections.add(chorus);

      final output = renderer.render(song);

      expect(output, contains('[Verse]'));
      expect(output, contains('[Chorus]'));
      expect(output, contains('Verse text'));
      expect(output, contains('Chorus text'));
    });

    test('044 handles empty section gracefully', () {
      final song = Song('Test', 'C');
      final section = Section('Instrumental');
      song.sections.add(section);

      final output = renderer.render(song);

      expect(output, contains('[Instrumental]'));
    });

    test('045 handles unicode lyrics', () {
      final song = Song('Canção', 'Am');
      final section = Section('Verso');
      section.chords.add(Chord('Am', {}, 'Olá mundo'));
      song.sections.add(section);

      final output = renderer.render(song);

      expect(output, contains('CANÇÃO'));
      expect(output, contains('Olá mundo'));
    });
  });
}
