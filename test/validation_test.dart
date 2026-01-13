import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';
import './fixtures/directives_json.dart';

void main() {
  group('Validation', () {
    late IclfParser parser;
    setUp(() {
      parser = IclfParser(getTestJson());
    });
    test('014 handles regex from json (creation_date)', () {
      const content =
          '{title: Test}\n{key: C}\n{creation_date: 2025-04-28}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.globals['creation_date'], '2025-04-28');
    });
    test('015 invalid regex from json (creation_date)', () {
      const content =
          '{title: Test}\n{key: C}\n{creation_date: invalid}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.invalid);
      expect(
          result.errors
              .any((e) => e.contains('Invalid value for creation_date')),
          isTrue);
    });
    test('016 handles integer from json (tempo)', () {
      const content = '{title: Test}\n{key: C}\n{tempo: 80}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.globals['tempo'], '80');
    });
    test('017 invalid integer from json (tempo)', () {
      const content = '{title: Test}\n{key: C}\n{tempo: 10}\n[C]Lyric';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.invalid);
      expect(result.errors.any((e) => e.contains('Invalid integer for tempo')),
          isTrue);
    });
  });

  group('Chord Validation', () {
    late IclfParser parser;
    setUp(() {
      parser = IclfParser(getTestJson());
    });

    test('018 validates basic major chords', () {
      const content = '{title: Test}\n{key: C}\n[C]do [G]sol [Bb]si [F#]fa#';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 4);
    });

    test('019 validates minor chords', () {
      const content = '{title: Test}\n{key: Am}\n[Am]la [Cm]do [F#m]fa# [Gmin]sol';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 4);
    });

    test('020 validates seventh chords', () {
      const content =
          '{title: Test}\n{key: C}\n[C7]dom7 [Cmaj7]maj7 [Cm7]min7 [Cdim7]dim7 [Caug7]aug7';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 5);
    });

    test('021 validates minor-major seventh chord (mmaj7)', () {
      const content = '{title: Test}\n{key: C}\n[Cmmaj7]minor-major [Ammaj7]test';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 2);
    });

    test('022 validates extended chords (9, 11, 13)', () {
      const content =
          '{title: Test}\n{key: C}\n[C9]ninth [Cmaj9]maj9 [Cm9]min9 [C11]eleventh [C13]thirteenth';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 5);
    });

    test('023 validates suspended chords', () {
      const content =
          '{title: Test}\n{key: C}\n[Csus2]sus2 [Csus4]sus4 [C7sus4]7sus4 [Asus2]asus2';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 4);
    });

    test('024 validates add chords', () {
      const content =
          '{title: Test}\n{key: C}\n[Cadd9]add9 [Cadd11]add11 [Cmadd9]minadd9 [Gadd13]add13';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 4);
    });

    test('025 validates altered chords', () {
      const content =
          '{title: Test}\n{key: C}\n[C7b5]b5 [C7#5]sharp5 [C7b9]b9 [C7#9]sharp9 [C7#11]sharp11';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 5);
    });

    test('026 validates altered chords with parentheses', () {
      const content =
          '{title: Test}\n{key: C}\n[C7(b5)]b5 [C7(#9)]sharp9 [D7(b9)]db9';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 3);
    });

    test('027 validates slash chords (bass notes)', () {
      const content =
          '{title: Test}\n{key: C}\n[C/E]c-over-e [Am/G]am-over-g [Bb7/Ab]bb7-over-ab [F#m/C#]fsharp-over-csharp';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 4);
    });

    test('028 validates complex chord combinations', () {
      const content =
          '{title: Test}\n{key: C}\n[Ebmmaj7/Gb]complex1 [Dm7b5]half-dim [F#m7b5/E]complex2 [Cmaj9add13]extended';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 4);
    });

    test('029 validates diminished and augmented symbols', () {
      const content =
          '{title: Test}\n{key: C}\n[C°7]dim-symbol [Cø7]half-dim-symbol [C+7]aug-plus';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 3);
    });

    test('030 validates multiple alterations', () {
      const content =
          '{title: Test}\n{key: C}\n[C7b9#11]multi-alt [G7#9b13]another';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.valid);
      expect(result.song?.sections.first.chords.length, 2);
    });

    test('031 rejects invalid chord root', () {
      const content = '{title: Test}\n{key: C}\n[H7]invalid-root';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.invalid);
      expect(result.errors.any((e) => e.contains('Invalid chord')), isTrue);
    });

    test('032 rejects malformed chord syntax', () {
      const content = '{title: Test}\n{key: C}\n[Cmajmin7]invalid';
      final result = parser.parse(content);
      expect(result.status, ParseStatus.invalid);
      expect(result.errors.any((e) => e.contains('Invalid chord')), isTrue);
    });
  });
}
