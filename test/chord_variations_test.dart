import 'package:iclf_parser/iclf_parser.dart';
import 'package:test/test.dart';
import './fixtures/directives_json.dart';

/// Comprehensive tests for all chord variations supported by ICLF.
/// These tests go through the actual parser to ensure the full pipeline works.
///
/// Chord pattern components:
/// - Root: A-G
/// - Accidental: # or b
/// - Minor: m or min
/// - Quality: maj, dim, °, ˚, ø, +, aug
/// - Suspension: sus2, sus4
/// - Extension: 6, 7, 9, 11, 13
/// - Add: add9, add11, add13
/// - Alteration: b5, #5, b9, #9, #11, b13 (with optional parentheses)
/// - Bass: /[A-G][#b]?
/// - Special: N.C.
void main() {
  late IclfParser parser;

  setUp(() {
    parser = IclfParser(getTestJson());
  });

  /// Helper to test if a chord is valid by parsing it in context
  ParseResult parseChord(String chord) {
    final content = '{title: Test}\n{key: C}\n[$chord]lyrics';
    return parser.parse(content);
  }

  /// Helper to test a chord with a descriptive name
  void expectValid(String chord, String description) {
    test('$chord - $description', () {
      final result = parseChord(chord);
      expect(result.status, isNot(ParseStatus.invalid),
          reason:
              'Chord "$chord" ($description) should be valid but got errors: ${result.errors}');
    });
  }

  /// Helper to test an invalid chord with a descriptive name
  void expectInvalid(String chord, String description) {
    test('$chord - $description', () {
      final result = parseChord(chord);
      expect(result.status, ParseStatus.invalid,
          reason: 'Chord "$chord" ($description) should be invalid');
    });
  }

  // ============================================================================
  // ROOT NOTES
  // ============================================================================
  group('Root Notes - Natural', () {
    expectValid('A', 'A natural');
    expectValid('B', 'B natural');
    expectValid('C', 'C natural');
    expectValid('D', 'D natural');
    expectValid('E', 'E natural');
    expectValid('F', 'F natural');
    expectValid('G', 'G natural');
  });

  group('Root Notes - Invalid', () {
    expectInvalid('H', 'H is not a valid note');
    expectInvalid('I', 'I is not a valid note');
    expectInvalid('J', 'J is not a valid note');
    expectInvalid('K', 'K is not a valid note');
    expectInvalid('L', 'L is not a valid note');
    expectInvalid('M', 'M is not a valid note');
    expectInvalid('N', 'N alone is not valid (only N.C.)');
    expectInvalid('O', 'O is not a valid note');
    expectInvalid('P', 'P is not a valid note');
    expectInvalid('Q', 'Q is not a valid note');
    expectInvalid('R', 'R is not a valid note');
    expectInvalid('S', 'S is not a valid note');
    expectInvalid('T', 'T is not a valid note');
    expectInvalid('U', 'U is not a valid note');
    expectInvalid('V', 'V is not a valid note');
    expectInvalid('W', 'W is not a valid note');
    expectInvalid('X', 'X is not a valid note');
    expectInvalid('Y', 'Y is not a valid note');
    expectInvalid('Z', 'Z is not a valid note');
  });

  // ============================================================================
  // ACCIDENTALS
  // ============================================================================
  group('Accidentals - Sharps', () {
    expectValid('A#', 'A sharp');
    expectValid('B#', 'B sharp');
    expectValid('C#', 'C sharp');
    expectValid('D#', 'D sharp');
    expectValid('E#', 'E sharp');
    expectValid('F#', 'F sharp');
    expectValid('G#', 'G sharp');
  });

  group('Accidentals - Flats', () {
    expectValid('Ab', 'A flat');
    expectValid('Bb', 'B flat');
    expectValid('Cb', 'C flat');
    expectValid('Db', 'D flat');
    expectValid('Eb', 'E flat');
    expectValid('Fb', 'F flat');
    expectValid('Gb', 'G flat');
  });

  group('Accidentals - Invalid', () {
    expectInvalid('C##', 'double sharp not allowed');
    expectInvalid('Cbb', 'double flat not allowed');
    expectInvalid('C#b', 'sharp then flat not allowed');
    expectInvalid('Cb#', 'flat then sharp not allowed');
    expectInvalid('Cx', 'x is not a valid accidental');
  });

  // ============================================================================
  // MINOR CHORDS
  // ============================================================================
  group('Minor - Using m suffix', () {
    expectValid('Am', 'A minor with m');
    expectValid('Bm', 'B minor with m');
    expectValid('Cm', 'C minor with m');
    expectValid('Dm', 'D minor with m');
    expectValid('Em', 'E minor with m');
    expectValid('Fm', 'F minor with m');
    expectValid('Gm', 'G minor with m');
    expectValid('A#m', 'A sharp minor with m');
    expectValid('Bbm', 'B flat minor with m');
    expectValid('C#m', 'C sharp minor with m');
    expectValid('Ebm', 'E flat minor with m');
    expectValid('F#m', 'F sharp minor with m');
    expectValid('G#m', 'G sharp minor with m');
    expectValid('Abm', 'A flat minor with m');
  });

  group('Minor - Using min suffix', () {
    expectValid('Amin', 'A minor with min');
    expectValid('Bmin', 'B minor with min');
    expectValid('Cmin', 'C minor with min');
    expectValid('Dmin', 'D minor with min');
    expectValid('Emin', 'E minor with min');
    expectValid('Fmin', 'F minor with min');
    expectValid('Gmin', 'G minor with min');
    expectValid('C#min', 'C sharp minor with min');
    expectValid('Bbmin', 'B flat minor with min');
  });

  // ============================================================================
  // QUALITY - DIMINISHED
  // ============================================================================
  group('Quality - Diminished with dim suffix', () {
    expectValid('Adim', 'A diminished with dim');
    expectValid('Bdim', 'B diminished with dim');
    expectValid('Cdim', 'C diminished with dim');
    expectValid('Ddim', 'D diminished with dim');
    expectValid('Edim', 'E diminished with dim');
    expectValid('Fdim', 'F diminished with dim');
    expectValid('Gdim', 'G diminished with dim');
    expectValid('C#dim', 'C sharp diminished with dim');
    expectValid('Bbdim', 'B flat diminished with dim');
    expectValid('F#dim', 'F sharp diminished with dim');
    expectValid('Ebdim', 'E flat diminished with dim');
  });

  group('Quality - Diminished with ° (degree sign U+00B0)', () {
    expectValid('A°', 'A diminished with °');
    expectValid('B°', 'B diminished with °');
    expectValid('C°', 'C diminished with °');
    expectValid('D°', 'D diminished with °');
    expectValid('E°', 'E diminished with °');
    expectValid('F°', 'F diminished with °');
    expectValid('G°', 'G diminished with °');
    expectValid('C#°', 'C sharp diminished with °');
    expectValid('Bb°', 'B flat diminished with °');
    expectValid('F#°', 'F sharp diminished with °');
  });

  group('Quality - Diminished with ˚ (ring above U+02DA)', () {
    expectValid('A˚', 'A diminished with ˚');
    expectValid('B˚', 'B diminished with ˚');
    expectValid('C˚', 'C diminished with ˚');
    expectValid('D˚', 'D diminished with ˚');
    expectValid('E˚', 'E diminished with ˚');
    expectValid('F˚', 'F diminished with ˚');
    expectValid('G˚', 'G diminished with ˚');
    expectValid('C#˚', 'C sharp diminished with ˚');
    expectValid('Bb˚', 'B flat diminished with ˚');
    expectValid('F#˚', 'F sharp diminished with ˚');
  });

  group('Quality - Diminished 7th', () {
    expectValid('Adim7', 'A diminished 7th with dim');
    expectValid('Bdim7', 'B diminished 7th with dim');
    expectValid('Cdim7', 'C diminished 7th with dim');
    expectValid('Ddim7', 'D diminished 7th with dim');
    expectValid('Edim7', 'E diminished 7th with dim');
    expectValid('Fdim7', 'F diminished 7th with dim');
    expectValid('Gdim7', 'G diminished 7th with dim');
    expectValid('C°7', 'C diminished 7th with °');
    expectValid('D°7', 'D diminished 7th with °');
    expectValid('E°7', 'E diminished 7th with °');
    expectValid('C˚7', 'C diminished 7th with ˚');
    expectValid('D˚7', 'D diminished 7th with ˚');
    expectValid('E˚7', 'E diminished 7th with ˚');
    expectValid('F#dim7', 'F sharp diminished 7th');
    expectValid('Bbdim7', 'B flat diminished 7th');
  });

  // ============================================================================
  // QUALITY - HALF-DIMINISHED
  // ============================================================================
  group('Quality - Half-Diminished with ø', () {
    expectValid('Aø', 'A half-diminished with ø');
    expectValid('Bø', 'B half-diminished with ø');
    expectValid('Cø', 'C half-diminished with ø');
    expectValid('Dø', 'D half-diminished with ø');
    expectValid('Eø', 'E half-diminished with ø');
    expectValid('Fø', 'F half-diminished with ø');
    expectValid('Gø', 'G half-diminished with ø');
    expectValid('C#ø', 'C sharp half-diminished with ø');
    expectValid('Bbø', 'B flat half-diminished with ø');
    expectValid('F#ø', 'F sharp half-diminished with ø');
  });

  group('Quality - Half-Diminished 7th with ø', () {
    expectValid('Aø7', 'A half-diminished 7th with ø');
    expectValid('Bø7', 'B half-diminished 7th with ø');
    expectValid('Cø7', 'C half-diminished 7th with ø');
    expectValid('Dø7', 'D half-diminished 7th with ø');
    expectValid('Eø7', 'E half-diminished 7th with ø');
    expectValid('Fø7', 'F half-diminished 7th with ø');
    expectValid('Gø7', 'G half-diminished 7th with ø');
  });

  group('Quality - Half-Diminished with m7b5 notation', () {
    expectValid('Am7b5', 'A half-diminished as m7b5');
    expectValid('Bm7b5', 'B half-diminished as m7b5');
    expectValid('Cm7b5', 'C half-diminished as m7b5');
    expectValid('Dm7b5', 'D half-diminished as m7b5');
    expectValid('Em7b5', 'E half-diminished as m7b5');
    expectValid('Fm7b5', 'F half-diminished as m7b5');
    expectValid('Gm7b5', 'G half-diminished as m7b5');
    expectValid('C#m7b5', 'C sharp half-diminished as m7b5');
    expectValid('F#m7b5', 'F sharp half-diminished as m7b5');
    expectValid('Bbm7b5', 'B flat half-diminished as m7b5');
  });

  // ============================================================================
  // QUALITY - AUGMENTED
  // ============================================================================
  group('Quality - Augmented with aug suffix', () {
    expectValid('Aaug', 'A augmented with aug');
    expectValid('Baug', 'B augmented with aug');
    expectValid('Caug', 'C augmented with aug');
    expectValid('Daug', 'D augmented with aug');
    expectValid('Eaug', 'E augmented with aug');
    expectValid('Faug', 'F augmented with aug');
    expectValid('Gaug', 'G augmented with aug');
    expectValid('C#aug', 'C sharp augmented with aug');
    expectValid('Bbaug', 'B flat augmented with aug');
    expectValid('F#aug', 'F sharp augmented with aug');
  });

  group('Quality - Augmented with + symbol', () {
    expectValid('A+', 'A augmented with +');
    expectValid('B+', 'B augmented with +');
    expectValid('C+', 'C augmented with +');
    expectValid('D+', 'D augmented with +');
    expectValid('E+', 'E augmented with +');
    expectValid('F+', 'F augmented with +');
    expectValid('G+', 'G augmented with +');
    expectValid('C#+', 'C sharp augmented with +');
    expectValid('Bb+', 'B flat augmented with +');
    expectValid('F#+', 'F sharp augmented with +');
  });

  // ============================================================================
  // QUALITY - MAJOR
  // ============================================================================
  group('Quality - Major with maj suffix', () {
    expectValid('Amaj', 'A major with maj');
    expectValid('Bmaj', 'B major with maj');
    expectValid('Cmaj', 'C major with maj');
    expectValid('Dmaj', 'D major with maj');
    expectValid('Emaj', 'E major with maj');
    expectValid('Fmaj', 'F major with maj');
    expectValid('Gmaj', 'G major with maj');
    expectValid('C#maj', 'C sharp major with maj');
    expectValid('Bbmaj', 'B flat major with maj');
  });

  group('Quality - Major 7th', () {
    expectValid('Amaj7', 'A major 7th');
    expectValid('Bmaj7', 'B major 7th');
    expectValid('Cmaj7', 'C major 7th');
    expectValid('Dmaj7', 'D major 7th');
    expectValid('Emaj7', 'E major 7th');
    expectValid('Fmaj7', 'F major 7th');
    expectValid('Gmaj7', 'G major 7th');
    expectValid('C#maj7', 'C sharp major 7th');
    expectValid('Bbmaj7', 'B flat major 7th');
    expectValid('Ebmaj7', 'E flat major 7th');
    expectValid('Abmaj7', 'A flat major 7th');
    expectValid('F#maj7', 'F sharp major 7th');
  });

  group('Quality - Major 9th', () {
    expectValid('Amaj9', 'A major 9th');
    expectValid('Cmaj9', 'C major 9th');
    expectValid('Dmaj9', 'D major 9th');
    expectValid('Fmaj9', 'F major 9th');
    expectValid('Gmaj9', 'G major 9th');
    expectValid('Bbmaj9', 'B flat major 9th');
  });

  // ============================================================================
  // MINOR-MAJOR CHORDS
  // ============================================================================
  group('Quality - Minor-Major 7th (mmaj7)', () {
    expectValid('Ammaj7', 'A minor-major 7th');
    expectValid('Bmmaj7', 'B minor-major 7th');
    expectValid('Cmmaj7', 'C minor-major 7th');
    expectValid('Dmmaj7', 'D minor-major 7th');
    expectValid('Emmaj7', 'E minor-major 7th');
    expectValid('Fmmaj7', 'F minor-major 7th');
    expectValid('Gmmaj7', 'G minor-major 7th');
    expectValid('C#mmaj7', 'C sharp minor-major 7th');
    expectValid('F#mmaj7', 'F sharp minor-major 7th');
    expectValid('Bbmmaj7', 'B flat minor-major 7th');
    expectValid('Ebmmaj7', 'E flat minor-major 7th');
  });

  // ============================================================================
  // SUSPENDED CHORDS
  // ============================================================================
  group('Suspended - sus2', () {
    expectValid('Asus2', 'A suspended 2nd');
    expectValid('Bsus2', 'B suspended 2nd');
    expectValid('Csus2', 'C suspended 2nd');
    expectValid('Dsus2', 'D suspended 2nd');
    expectValid('Esus2', 'E suspended 2nd');
    expectValid('Fsus2', 'F suspended 2nd');
    expectValid('Gsus2', 'G suspended 2nd');
    expectValid('C#sus2', 'C sharp suspended 2nd');
    expectValid('Bbsus2', 'B flat suspended 2nd');
    expectValid('F#sus2', 'F sharp suspended 2nd');
  });

  group('Suspended - sus4', () {
    expectValid('Asus4', 'A suspended 4th');
    expectValid('Bsus4', 'B suspended 4th');
    expectValid('Csus4', 'C suspended 4th');
    expectValid('Dsus4', 'D suspended 4th');
    expectValid('Esus4', 'E suspended 4th');
    expectValid('Fsus4', 'F suspended 4th');
    expectValid('Gsus4', 'G suspended 4th');
    expectValid('C#sus4', 'C sharp suspended 4th');
    expectValid('Bbsus4', 'B flat suspended 4th');
    expectValid('F#sus4', 'F sharp suspended 4th');
  });

  group('Suspended - 7sus2', () {
    expectValid('A7sus2', 'A dominant 7th suspended 2nd');
    expectValid('C7sus2', 'C dominant 7th suspended 2nd');
    expectValid('D7sus2', 'D dominant 7th suspended 2nd');
    expectValid('E7sus2', 'E dominant 7th suspended 2nd');
    expectValid('G7sus2', 'G dominant 7th suspended 2nd');
  });

  group('Suspended - 7sus4', () {
    expectValid('A7sus4', 'A dominant 7th suspended 4th');
    expectValid('B7sus4', 'B dominant 7th suspended 4th');
    expectValid('C7sus4', 'C dominant 7th suspended 4th');
    expectValid('D7sus4', 'D dominant 7th suspended 4th');
    expectValid('E7sus4', 'E dominant 7th suspended 4th');
    expectValid('F7sus4', 'F dominant 7th suspended 4th');
    expectValid('G7sus4', 'G dominant 7th suspended 4th');
  });

  group('Suspended - 9sus4', () {
    expectValid('A9sus4', 'A 9th suspended 4th');
    expectValid('C9sus4', 'C 9th suspended 4th');
    expectValid('D9sus4', 'D 9th suspended 4th');
    expectValid('G9sus4', 'G 9th suspended 4th');
  });

  group('Suspended - Invalid', () {
    expectInvalid('Csus1', 'sus1 is not valid');
    expectInvalid('Csus3', 'sus3 is not valid');
    expectInvalid('Csus5', 'sus5 is not valid');
    expectInvalid('Csus6', 'sus6 is not valid');
    expectInvalid('Csus7', 'sus7 is not valid');
  });

  // ============================================================================
  // EXTENSIONS - 6TH
  // ============================================================================
  group('Extensions - Major 6th', () {
    expectValid('A6', 'A major 6th');
    expectValid('B6', 'B major 6th');
    expectValid('C6', 'C major 6th');
    expectValid('D6', 'D major 6th');
    expectValid('E6', 'E major 6th');
    expectValid('F6', 'F major 6th');
    expectValid('G6', 'G major 6th');
    expectValid('C#6', 'C sharp major 6th');
    expectValid('Bb6', 'B flat major 6th');
    expectValid('F#6', 'F sharp major 6th');
  });

  group('Extensions - Minor 6th', () {
    expectValid('Am6', 'A minor 6th');
    expectValid('Bm6', 'B minor 6th');
    expectValid('Cm6', 'C minor 6th');
    expectValid('Dm6', 'D minor 6th');
    expectValid('Em6', 'E minor 6th');
    expectValid('Fm6', 'F minor 6th');
    expectValid('Gm6', 'G minor 6th');
    expectValid('C#m6', 'C sharp minor 6th');
    expectValid('Bbm6', 'B flat minor 6th');
    expectValid('Ebm6', 'E flat minor 6th');
    expectValid('Abm6', 'A flat minor 6th');
  });

  // ============================================================================
  // EXTENSIONS - 7TH
  // ============================================================================
  group('Extensions - Dominant 7th', () {
    expectValid('A7', 'A dominant 7th');
    expectValid('B7', 'B dominant 7th');
    expectValid('C7', 'C dominant 7th');
    expectValid('D7', 'D dominant 7th');
    expectValid('E7', 'E dominant 7th');
    expectValid('F7', 'F dominant 7th');
    expectValid('G7', 'G dominant 7th');
    expectValid('C#7', 'C sharp dominant 7th');
    expectValid('F#7', 'F sharp dominant 7th');
    expectValid('Bb7', 'B flat dominant 7th');
    expectValid('Eb7', 'E flat dominant 7th');
    expectValid('Ab7', 'A flat dominant 7th');
  });

  group('Extensions - Minor 7th', () {
    expectValid('Am7', 'A minor 7th');
    expectValid('Bm7', 'B minor 7th');
    expectValid('Cm7', 'C minor 7th');
    expectValid('Dm7', 'D minor 7th');
    expectValid('Em7', 'E minor 7th');
    expectValid('Fm7', 'F minor 7th');
    expectValid('Gm7', 'G minor 7th');
    expectValid('C#m7', 'C sharp minor 7th');
    expectValid('F#m7', 'F sharp minor 7th');
    expectValid('Bbm7', 'B flat minor 7th');
    expectValid('Ebm7', 'E flat minor 7th');
  });

  // ============================================================================
  // EXTENSIONS - 9TH
  // ============================================================================
  group('Extensions - Dominant 9th', () {
    expectValid('A9', 'A dominant 9th');
    expectValid('B9', 'B dominant 9th');
    expectValid('C9', 'C dominant 9th');
    expectValid('D9', 'D dominant 9th');
    expectValid('E9', 'E dominant 9th');
    expectValid('F9', 'F dominant 9th');
    expectValid('G9', 'G dominant 9th');
    expectValid('C#9', 'C sharp dominant 9th');
    expectValid('Bb9', 'B flat dominant 9th');
  });

  group('Extensions - Minor 9th', () {
    expectValid('Am9', 'A minor 9th');
    expectValid('Bm9', 'B minor 9th');
    expectValid('Cm9', 'C minor 9th');
    expectValid('Dm9', 'D minor 9th');
    expectValid('Em9', 'E minor 9th');
    expectValid('Fm9', 'F minor 9th');
    expectValid('Gm9', 'G minor 9th');
  });

  // ============================================================================
  // EXTENSIONS - 11TH
  // ============================================================================
  group('Extensions - Dominant 11th', () {
    expectValid('A11', 'A dominant 11th');
    expectValid('B11', 'B dominant 11th');
    expectValid('C11', 'C dominant 11th');
    expectValid('D11', 'D dominant 11th');
    expectValid('E11', 'E dominant 11th');
    expectValid('F11', 'F dominant 11th');
    expectValid('G11', 'G dominant 11th');
  });

  group('Extensions - Minor 11th', () {
    expectValid('Am11', 'A minor 11th');
    expectValid('Cm11', 'C minor 11th');
    expectValid('Dm11', 'D minor 11th');
    expectValid('Em11', 'E minor 11th');
    expectValid('Gm11', 'G minor 11th');
  });

  // ============================================================================
  // EXTENSIONS - 13TH
  // ============================================================================
  group('Extensions - Dominant 13th', () {
    expectValid('A13', 'A dominant 13th');
    expectValid('B13', 'B dominant 13th');
    expectValid('C13', 'C dominant 13th');
    expectValid('D13', 'D dominant 13th');
    expectValid('E13', 'E dominant 13th');
    expectValid('F13', 'F dominant 13th');
    expectValid('G13', 'G dominant 13th');
  });

  group('Extensions - Minor 13th', () {
    expectValid('Am13', 'A minor 13th');
    expectValid('Cm13', 'C minor 13th');
    expectValid('Dm13', 'D minor 13th');
    expectValid('Em13', 'E minor 13th');
    expectValid('Gm13', 'G minor 13th');
  });

  // ============================================================================
  // ADD CHORDS
  // ============================================================================
  group('Add Chords - add9', () {
    expectValid('Aadd9', 'A add 9');
    expectValid('Cadd9', 'C add 9');
    expectValid('Dadd9', 'D add 9');
    expectValid('Eadd9', 'E add 9');
    expectValid('Fadd9', 'F add 9');
    expectValid('Gadd9', 'G add 9');
    expectValid('C#add9', 'C sharp add 9');
    expectValid('Bbadd9', 'B flat add 9');
  });

  group('Add Chords - add11', () {
    expectValid('Aadd11', 'A add 11');
    expectValid('Cadd11', 'C add 11');
    expectValid('Dadd11', 'D add 11');
    expectValid('Gadd11', 'G add 11');
  });

  group('Add Chords - add13', () {
    expectValid('Aadd13', 'A add 13');
    expectValid('Cadd13', 'C add 13');
    expectValid('Dadd13', 'D add 13');
    expectValid('Gadd13', 'G add 13');
  });

  group('Add Chords - Minor add', () {
    expectValid('Amadd9', 'A minor add 9');
    expectValid('Cmadd9', 'C minor add 9');
    expectValid('Dmadd9', 'D minor add 9');
    expectValid('Emadd9', 'E minor add 9');
  });

  // ============================================================================
  // ALTERATIONS - ALTERED 5TH
  // ============================================================================
  group('Alterations - b5 (flat 5th)', () {
    expectValid('C7b5', 'C dominant 7th flat 5');
    expectValid('D7b5', 'D dominant 7th flat 5');
    expectValid('E7b5', 'E dominant 7th flat 5');
    expectValid('F7b5', 'F dominant 7th flat 5');
    expectValid('G7b5', 'G dominant 7th flat 5');
    expectValid('A7b5', 'A dominant 7th flat 5');
    expectValid('B7b5', 'B dominant 7th flat 5');
    expectValid('Bb7b5', 'B flat dominant 7th flat 5');
  });

  group('Alterations - #5 (sharp 5th)', () {
    expectValid('C7#5', 'C dominant 7th sharp 5');
    expectValid('D7#5', 'D dominant 7th sharp 5');
    expectValid('E7#5', 'E dominant 7th sharp 5');
    expectValid('F7#5', 'F dominant 7th sharp 5');
    expectValid('G7#5', 'G dominant 7th sharp 5');
    expectValid('A7#5', 'A dominant 7th sharp 5');
    expectValid('B7#5', 'B dominant 7th sharp 5');
  });

  // ============================================================================
  // ALTERATIONS - ALTERED 9TH
  // ============================================================================
  group('Alterations - b9 (flat 9th)', () {
    expectValid('C7b9', 'C dominant 7th flat 9');
    expectValid('D7b9', 'D dominant 7th flat 9');
    expectValid('E7b9', 'E dominant 7th flat 9');
    expectValid('F7b9', 'F dominant 7th flat 9');
    expectValid('G7b9', 'G dominant 7th flat 9');
    expectValid('A7b9', 'A dominant 7th flat 9');
    expectValid('B7b9', 'B dominant 7th flat 9');
    expectValid('Bb7b9', 'B flat dominant 7th flat 9');
    expectValid('F#7b9', 'F sharp dominant 7th flat 9');
  });

  group('Alterations - #9 (sharp 9th)', () {
    expectValid('C7#9', 'C dominant 7th sharp 9');
    expectValid('D7#9', 'D dominant 7th sharp 9');
    expectValid('E7#9', 'E dominant 7th sharp 9');
    expectValid('F7#9', 'F dominant 7th sharp 9');
    expectValid('G7#9', 'G dominant 7th sharp 9');
    expectValid('A7#9', 'A dominant 7th sharp 9');
    expectValid('B7#9', 'B dominant 7th sharp 9');
  });

  group('Alterations - b9 with parentheses', () {
    expectValid('C7(b9)', 'C dominant 7th (flat 9) with parens');
    expectValid('D7(b9)', 'D dominant 7th (flat 9) with parens');
    expectValid('G7(b9)', 'G dominant 7th (flat 9) with parens');
    expectValid('A7(b9)', 'A dominant 7th (flat 9) with parens');
    expectValid('B7(b9)', 'B7(b9) - B dominant 7th flat 9 with parens');
  });

  group('Alterations - #9 with parentheses', () {
    expectValid('C7(#9)', 'C dominant 7th (sharp 9) with parens');
    expectValid('D7(#9)', 'D dominant 7th (sharp 9) with parens');
    expectValid('G7(#9)', 'G dominant 7th (sharp 9) with parens');
  });

  // ============================================================================
  // ALTERATIONS - ALTERED 11TH
  // ============================================================================
  group('Alterations - #11 (sharp 11th)', () {
    expectValid('C7#11', 'C dominant 7th sharp 11');
    expectValid('D7#11', 'D dominant 7th sharp 11');
    expectValid('E7#11', 'E dominant 7th sharp 11');
    expectValid('F7#11', 'F dominant 7th sharp 11');
    expectValid('G7#11', 'G dominant 7th sharp 11');
    expectValid('A7#11', 'A dominant 7th sharp 11');
    expectValid('Bb7#11', 'B flat dominant 7th sharp 11');
  });

  group('Alterations - #11 with parentheses', () {
    expectValid('C7(#11)', 'C dominant 7th (#11) with parens');
    expectValid('D7(#11)', 'D dominant 7th (#11) with parens');
    expectValid('G7(#11)', 'G dominant 7th (#11) with parens');
  });

  // ============================================================================
  // ALTERATIONS - ALTERED 13TH
  // ============================================================================
  group('Alterations - b13 (flat 13th)', () {
    expectValid('C7b13', 'C dominant 7th flat 13');
    expectValid('D7b13', 'D dominant 7th flat 13');
    expectValid('E7b13', 'E dominant 7th flat 13');
    expectValid('F7b13', 'F dominant 7th flat 13');
    expectValid('G7b13', 'G dominant 7th flat 13');
    expectValid('A7b13', 'A dominant 7th flat 13');
    expectValid('Bb7b13', 'B flat dominant 7th flat 13');
  });

  group('Alterations - b13 with parentheses', () {
    expectValid('C7(b13)', 'C dominant 7th (b13) with parens');
    expectValid('A7(b13)', 'A dominant 7th (b13) with parens');
    expectValid('G7(b13)', 'G dominant 7th (b13) with parens');
  });

  // ============================================================================
  // MULTIPLE ALTERATIONS
  // ============================================================================
  group('Multiple Alterations - Two alterations', () {
    expectValid('C7b5b9', 'C7 with flat 5 and flat 9');
    expectValid('C7#5#9', 'C7 with sharp 5 and sharp 9');
    expectValid('C7b5#9', 'C7 with flat 5 and sharp 9');
    expectValid('C7#5b9', 'C7 with sharp 5 and flat 9');
    expectValid('C7b9#11', 'C7 with flat 9 and sharp 11');
    expectValid('C7#9b13', 'C7 with sharp 9 and flat 13');
    expectValid('G7b5b9', 'G7 with flat 5 and flat 9');
    expectValid('G7#5#9', 'G7 with sharp 5 and sharp 9');
  });

  group('Multiple Alterations - With parentheses', () {
    expectValid('C7(b9)(#11)', 'C7 with (b9) and (#11)');
    expectValid('C7(#9)(b13)', 'C7 with (#9) and (b13)');
    expectValid('G7(b9)(#11)', 'G7 with (b9) and (#11)');
    expectValid('A7(b9)(b13)', 'A7 with (b9) and (b13)');
  });

  group('Multiple Alterations - Three alterations', () {
    expectValid('C7b5b9#11', 'C7 with b5, b9, and #11');
    expectValid('C7#5#9b13', 'C7 with #5, #9, and b13');
    expectValid('G7b5b9b13', 'G7 with b5, b9, and b13');
  });

  // ============================================================================
  // SLASH CHORDS - BASS NOTES
  // ============================================================================
  group('Slash Chords - Natural bass notes', () {
    expectValid('C/E', 'C over E bass');
    expectValid('C/G', 'C over G bass');
    expectValid('C/B', 'C over B bass');
    expectValid('D/F', 'D over F bass');
    expectValid('D/A', 'D over A bass');
    expectValid('E/G', 'E over G bass');
    expectValid('E/B', 'E over B bass');
    expectValid('F/A', 'F over A bass');
    expectValid('F/C', 'F over C bass');
    expectValid('G/B', 'G over B bass');
    expectValid('G/D', 'G over D bass');
    expectValid('G/F', 'G over F bass');
    expectValid('A/E', 'A over E bass');
    expectValid('A/C', 'A over C bass');
    expectValid('B/D', 'B over D bass');
    expectValid('B/F', 'B over F bass');
  });

  group('Slash Chords - Sharp bass notes', () {
    expectValid('C/F#', 'C over F sharp bass');
    expectValid('C/G#', 'C over G sharp bass');
    expectValid('D/C#', 'D over C sharp bass');
    expectValid('D/F#', 'D over F sharp bass');
    expectValid('E/D#', 'E over D sharp bass');
    expectValid('G/F#', 'G over F sharp bass');
    expectValid('A/G#', 'A over G sharp bass');
    expectValid('Am/G#', 'A minor over G sharp bass');
    expectValid('Em/D#', 'E minor over D sharp bass');
  });

  group('Slash Chords - Flat bass notes', () {
    expectValid('C/Bb', 'C over B flat bass');
    expectValid('C/Ab', 'C over A flat bass');
    expectValid('D/Bb', 'D over B flat bass');
    expectValid('D/Ab', 'D over A flat bass');
    expectValid('E/Bb', 'E over B flat bass');
    expectValid('G/Eb', 'G over E flat bass');
    expectValid('G/Ab', 'G over A flat bass');
    expectValid('A/Gb', 'A over G flat bass');
    expectValid('Bb/Ab', 'B flat over A flat bass');
    expectValid('Eb/Db', 'E flat over D flat bass');
    expectValid('Ab/Gb', 'A flat over G flat bass');
  });

  group('Slash Chords - Minor chords with bass', () {
    expectValid('Am/E', 'A minor over E bass');
    expectValid('Am/G', 'A minor over G bass');
    expectValid('Am/C', 'A minor over C bass');
    expectValid('Dm/F', 'D minor over F bass');
    expectValid('Dm/A', 'D minor over A bass');
    expectValid('Em/G', 'E minor over G bass');
    expectValid('Em/B', 'E minor over B bass');
    expectValid('Fm/C', 'F minor over C bass');
    expectValid('Gm/Bb', 'G minor over B flat bass');
    expectValid('Gm/D', 'G minor over D bass');
  });

  group('Slash Chords - 7th chords with bass', () {
    expectValid('C7/E', 'C7 over E bass');
    expectValid('C7/G', 'C7 over G bass');
    expectValid('C7/Bb', 'C7 over B flat bass');
    expectValid('D7/F#', 'D7 over F sharp bass');
    expectValid('G7/B', 'G7 over B bass');
    expectValid('G7/F', 'G7 over F bass');
    expectValid('A7/E', 'A7 over E bass');
    expectValid('A7/G', 'A7 over G bass');
    expectValid('Bb7/Ab', 'B flat 7 over A flat bass');
    expectValid('Eb7/Db', 'E flat 7 over D flat bass');
  });

  group('Slash Chords - Major 7th chords with bass', () {
    expectValid('Cmaj7/E', 'C major 7 over E bass');
    expectValid('Cmaj7/G', 'C major 7 over G bass');
    expectValid('Cmaj7/B', 'C major 7 over B bass');
    expectValid('Dmaj7/F#', 'D major 7 over F sharp bass');
    expectValid('Fmaj7/A', 'F major 7 over A bass');
    expectValid('Gmaj7/B', 'G major 7 over B bass');
    expectValid('Bbmaj7/D', 'B flat major 7 over D bass');
    expectValid('Ebmaj7/G', 'E flat major 7 over G bass');
  });

  group('Slash Chords - Minor 7th chords with bass', () {
    expectValid('Am7/E', 'A minor 7 over E bass');
    expectValid('Am7/G', 'A minor 7 over G bass');
    expectValid('Dm7/F', 'D minor 7 over F bass');
    expectValid('Dm7/A', 'D minor 7 over A bass');
    expectValid('Em7/G', 'E minor 7 over G bass');
    expectValid('Em7/B', 'E minor 7 over B bass');
    expectValid('Gm7/Bb', 'G minor 7 over B flat bass');
    expectValid('Cm7/Eb', 'C minor 7 over E flat bass');
  });

  group('Slash Chords - Complex chords with bass', () {
    expectValid('Cmaj9/E', 'C major 9 over E bass');
    expectValid('Dm7b5/F', 'D half-dim over F bass');
    expectValid('G7b9/B', 'G7b9 over B bass');
    expectValid('Ebmmaj7/Gb', 'E flat minor-major 7 over G flat bass');
    expectValid('F#m7b5/A', 'F sharp half-dim over A bass');
    expectValid('Bb7sus4/Ab', 'B flat 7sus4 over A flat bass');
  });

  group('Slash Chords - Invalid bass notes', () {
    expectInvalid('C/H', 'H is not a valid bass note');
    expectInvalid('C/I', 'I is not a valid bass note');
    expectInvalid('C/X', 'X is not a valid bass note');
    expectInvalid('C/Z', 'Z is not a valid bass note');
    expectInvalid('C/', 'empty bass note');
  });

  // ============================================================================
  // NO CHORD
  // ============================================================================
  group('No Chord - Valid', () {
    expectValid('N.C.', 'No Chord standard notation');
  });

  group('No Chord - Invalid variations', () {
    expectInvalid('NC', 'NC without periods');
    expectInvalid('N.C', 'N.C without trailing period');
    expectInvalid('NC.', 'NC. without first period');
    expectInvalid('n.c.', 'lowercase n.c.');
    expectInvalid('N.c.', 'mixed case N.c.');
    expectInvalid('n.C.', 'mixed case n.C.');
    expectInvalid('NO CHORD', 'spelled out NO CHORD');
    expectInvalid('NoChord', 'NoChord camelCase');
  });

  // ============================================================================
  // COMPLEX REAL-WORLD CHORDS
  // ============================================================================
  group('Real-World - Águas de Março (Tom Jobim)', () {
    expectValid('Bb7/Ab', 'Bb7/Ab from Águas de Março');
    expectValid('Gm6', 'Gm6 from Águas de Março');
    expectValid('Ebmmaj7/Gb', 'Ebmmaj7/Gb from Águas de Março');
    expectValid('Bbmaj7', 'Bbmaj7 from Águas de Março');
    expectValid('Ebmaj7', 'Ebmaj7 from Águas de Março');
    expectValid('Ebm6', 'Ebm6 from Águas de Março');
  });

  group('Real-World - Jazz ii-V-I progressions', () {
    expectValid('Dm7', 'ii chord in C major');
    expectValid('G7', 'V chord in C major');
    expectValid('Cmaj7', 'I chord in C major');
    expectValid('Dm7b5', 'ii chord in C minor');
    expectValid('G7b9', 'V chord with b9 in C minor');
    expectValid('Cm7', 'i chord in C minor');
    expectValid('F#m7b5', 'ii chord in E minor');
    expectValid('B7b9', 'V chord in E minor');
    expectValid('Em7', 'i chord in E minor');
  });

  group('Real-World - Altered dominants', () {
    expectValid('G7#5#9', 'altered dominant with #5 #9');
    expectValid('C7b9b13', 'altered dominant with b9 b13');
    expectValid('F7#11', 'lydian dominant with #11');
    expectValid('Bb7b5', 'dominant with b5');
    expectValid('E7#9', 'Hendrix chord (7#9)');
    expectValid('A7b9#11', 'altered dominant with b9 #11');
  });

  group('Real-World - Bossa nova chords', () {
    expectValid('A7(b13)', 'A7 with (b13) bossa style');
    expectValid('D7(b9)', 'D7 with (b9) bossa style');
    expectValid('G7(#11)', 'G7 with (#11) bossa style');
    expectValid('Fmaj7', 'Fmaj7 common in bossa');
    expectValid('Fm6', 'Fm6 common in bossa');
    expectValid('Em7b5', 'Em7b5 common in bossa');
  });

  group('Real-World - Pop/Rock common chords', () {
    expectValid('G', 'G major basic');
    expectValid('C', 'C major basic');
    expectValid('D', 'D major basic');
    expectValid('Em', 'E minor basic');
    expectValid('Am', 'A minor basic');
    expectValid('F', 'F major basic');
    expectValid('Cadd9', 'Cadd9 common in pop');
    expectValid('Dsus4', 'Dsus4 common in pop');
    expectValid('Gsus4', 'Gsus4 common in pop');
    expectValid('Asus2', 'Asus2 common in pop');
  });

  // ============================================================================
  // BRAZILIAN NOTATION - 7M (Major 7th shorthand)
  // ============================================================================
  group('Brazilian - 7M major 7th shorthand', () {
    expectValid('C7M', 'C major 7th (Brazilian 7M)');
    expectValid('A7M', 'A major 7th (Brazilian 7M)');
    expectValid('D7M', 'D major 7th (Brazilian 7M)');
    expectValid('E7M', 'E major 7th (Brazilian 7M)');
    expectValid('F7M', 'F major 7th (Brazilian 7M)');
    expectValid('G7M', 'G major 7th (Brazilian 7M)');
    expectValid('B7M', 'B major 7th (Brazilian 7M)');
    expectValid('F#7M', 'F# major 7th (Brazilian 7M)');
    expectValid('Bb7M', 'Bb major 7th (Brazilian 7M)');
    expectValid('Eb7M', 'Eb major 7th (Brazilian 7M)');
    expectValid('Ab7M', 'Ab major 7th (Brazilian 7M)');
    expectValid('C#7M', 'C# major 7th (Brazilian 7M)');
  });

  group('Brazilian - 7M invalid forms', () {
    expectInvalid('CM', 'standalone M without extension number');
    expectInvalid('CmM', 'mM without number');
  });

  // ============================================================================
  // BRAZILIAN NOTATION - Parenthesized alterations with +/-
  // ============================================================================
  group('Brazilian - Flat alterations with minus sign', () {
    expectValid('C7(5-)', 'C7 flat 5 (Brazilian minus)');
    expectValid('Am7(5-)', 'Am7 flat 5 (Brazilian minus)');
    expectValid('D#m7(5-)', 'D#m7 flat 5 (Brazilian minus)');
    expectValid('C#m7(5-)', 'C#m7 flat 5 (Brazilian minus)');
    expectValid('C7(9-)', 'C7 flat 9 (Brazilian minus)');
    expectValid('C7(11-)', 'C7 flat 11 (Brazilian minus)');
    expectValid('C7(13-)', 'C7 flat 13 (Brazilian minus)');
    expectValid('B7(9-)', 'B7 flat 9 (Brazilian minus)');
    expectValid('A7(13-)', 'A7 flat 13 (Brazilian minus)');
    expectValid('Cm7(5-)', 'Cm7 flat 5 (Brazilian minus)');
    expectValid('Gm7(5-)', 'Gm7 flat 5 (Brazilian minus)');
  });

  group('Brazilian - Sharp alterations with plus sign', () {
    expectValid('C7(5+)', 'C7 sharp 5 (Brazilian plus)');
    expectValid('C7(9+)', 'C7 sharp 9 (Brazilian plus)');
    expectValid('C7(11+)', 'C7 sharp 11 (Brazilian plus)');
    expectValid('C7(13+)', 'C7 sharp 13 (Brazilian plus)');
    expectValid('E7(9+)', 'E7 sharp 9 (Brazilian plus)');
    expectValid('F#7(5+)', 'F#7 sharp 5 (Brazilian plus)');
  });

  // ============================================================================
  // BRAZILIAN NOTATION - Bare numbers in parentheses (add notation)
  // ============================================================================
  group('Brazilian - Bare numbers in parentheses', () {
    expectValid('C(9)', 'C add 9 (Brazilian parens)');
    expectValid('C(11)', 'C add 11 (Brazilian parens)');
    expectValid('C(13)', 'C add 13 (Brazilian parens)');
    expectValid('C(4)', 'C add 4 (Brazilian parens)');
    expectValid('A6(9)', 'A6 add 9 (Brazilian parens)');
    expectValid('Am7(9)', 'Am7 add 9 (Brazilian parens)');
    expectValid('C7(9)', 'C7 add 9 (Brazilian parens)');
    expectValid('C7(13)', 'C7 add 13 (Brazilian parens)');
  });

  group('Brazilian - Invalid bare numbers in parentheses', () {
    expectInvalid('C()', 'empty parentheses');
    expectInvalid('C(2)', '2 not valid in parentheses');
    expectInvalid('C(3)', '3 not valid in parentheses');
    expectInvalid('C(8)', '8 not valid in parentheses');
    expectInvalid('C(10)', '10 not valid in parentheses');
    expectInvalid('C(15)', '15 not valid in parentheses');
  });

  // ============================================================================
  // BRAZILIAN NOTATION - Compound intervals in parentheses
  // ============================================================================
  group('Brazilian - Compound intervals', () {
    expectValid('C(6/9)', 'C 6/9 (Brazilian compound)');
    expectValid('C7M(6/9)', 'C7M 6/9 (Brazilian compound)');
    expectValid('A7M(6/11+)', 'A7M 6/sharp 11 (Brazilian compound)');
    expectValid('C(9/13)', 'C 9/13 (Brazilian compound)');
    expectValid('C7(9/13-)', 'C7 9/flat 13 (Brazilian compound)');
    expectValid('A6(9/11+)', 'A6 9/sharp 11 (Brazilian compound)');
  });

  // ============================================================================
  // BRAZILIAN NOTATION - Multiple parenthesized alterations
  // ============================================================================
  group('Brazilian - Multiple parenthesized alterations', () {
    expectValid('G7(9+)(13-)', 'G7 sharp 9 + flat 13 (Brazilian)');
    expectValid('C7(b9)(#11)', 'C7 flat 9 + sharp 11 (mixed standard)');
    expectValid('C7(b5)', 'C7 flat 5 in parens (standard in Brazilian)');
    expectValid('C7(#9)', 'C7 sharp 9 in parens (standard in Brazilian)');
  });

  // ============================================================================
  // BRAZILIAN NOTATION - Real-world bossa nova & choro chords
  // ============================================================================
  group('Real-World - O Mundo É um Moinho (Cartola)', () {
    expectValid('D#m7(5-)', 'D#m7(5-) from Cartola');
    expectValid('C#m7(5-)', 'C#m7(5-) from Cartola');
    expectValid('A6(9)', 'A6(9) from Cartola');
    expectValid('A7M(6/11+)', 'A7M(6/11+) from Cartola');
  });

  group('Real-World - Common Brazilian jazz chords', () {
    expectValid('C7M', 'C major 7 (cifra brasileira)');
    expectValid('Am7(5-)', 'Am half-diminished (cifra brasileira)');
    expectValid('G7(9-)', 'G7 flat 9 (cifra brasileira)');
    expectValid('F7M', 'F major 7 (cifra brasileira)');
    expectValid('E7(9+)', 'E7 sharp 9 (cifra brasileira)');
    expectValid('D7M(6/9)', 'D major 7 6/9 (cifra brasileira)');
    expectValid('Bb7M', 'Bb major 7 (cifra brasileira)');
    expectValid('Eb7M', 'Eb major 7 (cifra brasileira)');
    expectValid('F#7(5+)', 'F#7 sharp 5 (cifra brasileira)');
    expectValid('B7(9-)', 'B7 flat 9 (cifra brasileira)');
  });

  // ============================================================================
  // EDGE CASES
  // ============================================================================
  group('Edge Cases - Lowercase (invalid)', () {
    expectInvalid('c', 'lowercase root c');
    expectInvalid('d', 'lowercase root d');
    expectInvalid('e', 'lowercase root e');
    expectInvalid('f', 'lowercase root f');
    expectInvalid('g', 'lowercase root g');
    expectInvalid('a', 'lowercase root a');
    expectInvalid('b', 'lowercase root b');
    expectInvalid('cm', 'lowercase cm');
    expectInvalid('am7', 'lowercase am7');
    expectInvalid('gmaj7', 'lowercase gmaj7');
  });

  group('Edge Cases - Uppercase quality (invalid)', () {
    expectInvalid('CMAJ7', 'all uppercase CMAJ7');
    expectInvalid('CMIN', 'all uppercase CMIN');
    expectInvalid('CDIM', 'all uppercase CDIM');
    expectInvalid('CAUG', 'all uppercase CAUG');
    expectInvalid('CMaj7', 'mixed case CMaj7');
    expectInvalid('CMin', 'mixed case CMin');
    expectInvalid('CDim', 'mixed case CDim');
    expectInvalid('CAug', 'mixed case CAug');
  });

  group('Edge Cases - Spaces and full words (invalid)', () {
    expectInvalid('C major', 'C major with space');
    expectInvalid('C minor', 'C minor with space');
    expectInvalid('C maj 7', 'C maj 7 with spaces');
    expectInvalid('Cmajor7', 'Cmajor7 full word');
    expectInvalid('Cminor7', 'Cminor7 full word');
    expectInvalid('C7th', 'C7th informal');
    expectInvalid('Cmaj 7', 'Cmaj 7 with space before 7');
  });

  group('Edge Cases - Invalid suffixes', () {
    expectInvalid('Cx', 'Cx invalid suffix');
    expectInvalid('Cy', 'Cy invalid suffix');
    expectInvalid('Cz', 'Cz invalid suffix');
    expectInvalid('C#x', 'C#x invalid suffix');
    expectInvalid('Cpower', 'Cpower invalid suffix');
    expectInvalid('C5', 'C5 power chord not supported');
  });

  group('Edge Cases - Invalid extensions', () {
    expectInvalid('C1', 'C1 invalid extension');
    expectInvalid('C2', 'C2 invalid extension');
    expectInvalid('C3', 'C3 invalid extension');
    expectInvalid('C4', 'C4 invalid extension');
    expectInvalid('C5', 'C5 invalid extension');
    expectInvalid('C8', 'C8 invalid extension');
    expectInvalid('C10', 'C10 invalid extension');
    expectInvalid('C12', 'C12 invalid extension');
    expectInvalid('C14', 'C14 invalid extension');
    expectInvalid('C15', 'C15 invalid extension');
  });
}
