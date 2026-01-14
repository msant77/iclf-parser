import 'package:test/test.dart';

/// Tests to validate the regex patterns in directives.json
/// Run with: dart test test/directives_validation_test.dart
void main() {
  group('Key Pattern Validation', () {
    // Pattern from directives.json
    final keyPattern =
        RegExp(r'^[A-G](?:#|b)?(?:m|maj|min|dim|°|aug|sus2|sus4)?$');

    final validKeys = [
      'C',
      'D',
      'E',
      'F',
      'G',
      'A',
      'B',
      'Am',
      'Bm',
      'Cm',
      'Dm',
      'Em',
      'F#',
      'G#',
      'Bb',
      'Eb',
      'Ab',
      'Db',
      'Gb',
      'F#m',
      'G#m',
      'Bbm',
      'Ebm',
      'Bbmaj',
      'Ddim',
      'Faug',
      'Gsus2',
      'Asus4',
      'C°',
    ];

    final invalidKeys = [
      'H', // Invalid note
      'Csharp', // Should be C#
      'C major', // No spaces
      'Cm7', // Extensions not allowed in key
      '', // Empty
    ];

    for (final key in validKeys) {
      test('accepts valid key: $key', () {
        expect(keyPattern.hasMatch(key), isTrue,
            reason: 'Key "$key" should be valid');
      });
    }

    for (final key in invalidKeys) {
      test('rejects invalid key: "$key"', () {
        expect(keyPattern.hasMatch(key), isFalse,
            reason: 'Key "$key" should be invalid');
      });
    }
  });

  group('Chord Pattern Validation', () {
    // Pattern from directives.json
    final chordPattern = RegExp(
        r'^(?:N\.C\.|[A-G][#b]?(?:m|min)?(?:maj|dim|°|ø|\+|aug)?(?:sus[24])?(?:6|7|9|11|13)?(?:sus[24])?(?:add(?:9|11|13))?(?:(?:\()?[b#](?:5|9|11|13)(?:\))?)*(?:/[A-G][#b]?)?)$');

    final validChords = [
      // Basic triads
      'C', 'D', 'E', 'F', 'G', 'A', 'B',
      'Cm', 'Dm', 'Em', 'Am', 'Bm',
      'C#', 'F#', 'Bb', 'Eb', 'Ab',
      'C#m', 'F#m', 'Bbm', 'Ebm',

      // Seventh chords
      'C7', 'Cmaj7', 'Cm7', 'Cdim7',
      'Am7', 'Amaj7',
      'G7', 'Gmaj7', 'Gm7',
      'Bb7', 'Bbmaj7', 'Bbm7',

      // Extended chords
      'C9', 'Cmaj9', 'Cm9',
      'G11', 'G13',
      'Am9', 'D13',

      // Suspended chords
      'Csus2', 'Csus4',
      'Dsus2', 'Dsus4',
      'G7sus4', 'D7sus4',

      // Add chords
      'Cadd9', 'Gadd9', 'Dadd9',
      'Cadd11', 'Cadd13',

      // Altered chords
      'C7b5', 'C7#5',
      'C7b9', 'C7#9',
      'C7#11', 'C7b13',
      'G7b9', 'G7#5',

      // Slash chords
      'C/E', 'C/G', 'G/B', 'Am/E',
      'Bb7/Ab', 'F/A', 'Dm/F',
      'Ebmmaj7/Gb',

      // Diminished/augmented
      'Cdim', 'Ddim', 'Bdim',
      'Caug', 'Gaug',
      'C°', 'D°',
      'Cø', 'Dø',
      'C+', 'G+',

      // Complex chords from real songs
      'Gm6', 'Am6', 'Dm6',
      'Bbmaj7', 'Ebmaj7', 'Abmaj7',
      'Ebm6', 'Abm6',
      'Cmmaj7', 'Fmmaj7',
      'Dm7b5', 'F#m7b5', 'Bm7b5',

      // No chord
      'N.C.',

      // Chords from Águas de Março
      'Bb7/Ab',
      'Gm6',
      'Ebmmaj7/Gb',
      'Bbmaj7',
      'Ebmaj7',
      'Ebm6',
    ];

    final invalidChords = [
      'H', // Invalid root
      'Cmajor7', // Should be Cmaj7
      'C major', // No spaces
      'Cx', // Invalid suffix
      '', // Empty
      'C/H', // Invalid bass note
    ];

    for (final chord in validChords) {
      test('accepts valid chord: $chord', () {
        expect(chordPattern.hasMatch(chord), isTrue,
            reason: 'Chord "$chord" should be valid');
      });
    }

    for (final chord in invalidChords) {
      test('rejects invalid chord: "$chord"', () {
        expect(chordPattern.hasMatch(chord), isFalse,
            reason: 'Chord "$chord" should be invalid');
      });
    }
  });

  group('Bass Attribute Pattern Validation', () {
    // Pattern from directives.json
    final bassPattern = RegExp(r'^[A-G](?:#|b)?(?:-[A-G](?:#|b)?)*$');

    final validBass = [
      'G',
      'A',
      'Bb',
      'F#',
      'Ab',
      'C#',
      'A-C-E', // Bass run
      'F#-A-C#',
      'Bb-D-F',
      'G-B-D-F',
    ];

    final invalidBass = [
      'H', // Invalid note
      '', // Empty
      'A-', // Trailing dash
      '-A', // Leading dash
      'A--C', // Double dash
    ];

    for (final bass in validBass) {
      test('accepts valid bass: $bass', () {
        expect(bassPattern.hasMatch(bass), isTrue,
            reason: 'Bass "$bass" should be valid');
      });
    }

    for (final bass in invalidBass) {
      test('rejects invalid bass: "$bass"', () {
        expect(bassPattern.hasMatch(bass), isFalse,
            reason: 'Bass "$bass" should be invalid');
      });
    }
  });

  group('Date Pattern Validation', () {
    final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

    final validDates = [
      '2025-01-14',
      '2024-12-31',
      '1999-06-15',
    ];

    final invalidDates = [
      '2025/01/14', // Wrong separator
      '25-01-14', // Short year
      '2025-1-14', // Missing leading zero
      'January 14, 2025', // Wrong format
    ];

    for (final date in validDates) {
      test('accepts valid date: $date', () {
        expect(datePattern.hasMatch(date), isTrue);
      });
    }

    for (final date in invalidDates) {
      test('rejects invalid date: "$date"', () {
        expect(datePattern.hasMatch(date), isFalse);
      });
    }
  });

  group('Strumming Pattern Validation', () {
    final strumPattern = RegExp(r'^[DUR\-]+$');

    final validPatterns = [
      'D-DU-UDU',
      'DDUUDU',
      'D-D-U-U',
      'DDDD',
      'UUUU',
      'R-R-R',
      'D',
    ];

    final invalidPatterns = [
      'DDUUX', // Invalid character
      'ddu', // Lowercase
      '', // Empty
    ];

    for (final pattern in validPatterns) {
      test('accepts valid strumming: $pattern', () {
        expect(strumPattern.hasMatch(pattern), isTrue);
      });
    }

    for (final pattern in invalidPatterns) {
      test('rejects invalid strumming: "$pattern"', () {
        expect(strumPattern.hasMatch(pattern), isFalse);
      });
    }
  });

  group('Repeat Directive Validation', () {
    final repeatPattern = RegExp(r'^\w+,\s*\d+x$');

    final validRepeats = [
      'Chorus, 2x',
      'Verse,3x',
      'Bridge, 1x',
      'Intro,10x',
    ];

    final invalidRepeats = [
      'Chorus 2x', // Missing comma
      'Chorus, 2', // Missing x
      ', 2x', // Missing section
      'Chorus, x', // Missing number
    ];

    for (final repeat in validRepeats) {
      test('accepts valid repeat: $repeat', () {
        expect(repeatPattern.hasMatch(repeat), isTrue);
      });
    }

    for (final repeat in invalidRepeats) {
      test('rejects invalid repeat: "$repeat"', () {
        expect(repeatPattern.hasMatch(repeat), isFalse);
      });
    }
  });
}
