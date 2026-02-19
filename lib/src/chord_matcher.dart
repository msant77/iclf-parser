import 'dart:convert';

/// A lightweight utility for matching chords and annotations against the
/// ICLF specification regex.
///
/// Use the default constructor for zero-cost construction with the hardcoded
/// spec pattern, or [ChordMatcher.fromJson] to extract the pattern from a
/// `directives.json` string (useful for guaranteed spec-sync in tests).
///
/// ```dart
/// final matcher = ChordMatcher();
/// print(matcher.isChord('Am7'));       // true
/// print(matcher.isChord('A7+'));       // true  (Brazilian major 7th)
/// print(matcher.isChord('hello'));     // false
/// print(matcher.isChordOnlyLine('Am7  D7/9  (intro 3x)')); // true
/// ```
class ChordMatcher {
  /// Creates a [ChordMatcher] with the hardcoded ICLF spec pattern.
  ChordMatcher() : _chordPattern = RegExp(defaultPattern);

  /// Creates a [ChordMatcher] by extracting the chord pattern from a
  /// `directives.json` content string.
  factory ChordMatcher.fromJson(String directivesJsonContent) {
    final json = jsonDecode(directivesJsonContent) as Map<String, dynamic>;
    final chords = json['chords'] as Map<String, dynamic>;
    final validation = chords['validation'] as Map<String, dynamic>;
    final chord = validation['chord'] as Map<String, dynamic>;
    final pattern = chord['pattern'] as String;
    return ChordMatcher._(RegExp(pattern));
  }

  ChordMatcher._(this._chordPattern);

  final RegExp _chordPattern;

  /// The default chord pattern from the ICLF spec.
  ///
  /// Matches: N.C., or root (A-G) with optional accidental, quality,
  /// suspension, extension, alterations (standard and Brazilian),
  /// compound intervals, and bass notes.
  static const String defaultPattern =
      r'^(?:N\.C\.|[A-G][#b]?(?:m|min)?(?:maj|dim|°|˚|º|ø|\+|aug)?(?:sus[24])?(?:6|7[M+]?|9|11|13)?(?:sus[24])?(?:add(?:9|11|13))?(?:(?:\()[b#]?(?:4|5|6|7|9|11|13)[+\-]?(?:/[b#]?(?:4|5|6|7|9|11|13)[+\-]?)*\)|\(?[b#](?:5|9|11|13)\)?)*(?:/(?:4|5|6|9|11|13))*(?:/[A-G][#b]?)?)$';

  /// Pattern for performance annotations like `(intro)`, `(2x)`,
  /// `(solo 3x)`, `(intro 3x)`, etc.
  ///
  /// Only matches known performance keywords and repeat patterns.
  /// Rejects chord alterations like `(5-)` or `(b9)`.
  static final RegExp _annotationPattern = RegExp(
    r'^\((?:intro|outro|solo|riff|break|interlude|bridge|verse|chorus|fade\s*out|[0-9]+x|[\w\s]+\s+\d+x)\)$',
    caseSensitive: false,
  );

  /// Inline pattern for finding annotations embedded in a line.
  /// Unlike [_annotationPattern], this is not anchored to line boundaries.
  static final RegExp _inlineAnnotationPattern = RegExp(
    r'\((?:intro|outro|solo|riff|break|interlude|bridge|verse|chorus|fade\s*out|[0-9]+x|[\w\s]+\s+\d+x)\)',
    caseSensitive: false,
  );

  /// Returns `true` if [text] is a valid ICLF chord name.
  ///
  /// Examples: `C`, `Am7`, `A7+`, `Dm7(5-)`, `D7/9`, `N.C.`
  bool isChord(String text) => _chordPattern.hasMatch(text);

  /// Returns `true` if [text] is a performance annotation.
  ///
  /// Examples: `(intro)`, `(2x)`, `(solo 3x)`, `(intro 3x)`
  bool isAnnotation(String text) => _annotationPattern.hasMatch(text);

  /// Returns `true` if [text] is either a valid chord or an annotation.
  bool isChordOrAnnotation(String text) => isChord(text) || isAnnotation(text);

  /// Returns `true` if [line] contains only chords (and optionally
  /// annotations) separated by whitespace.
  ///
  /// Also handles parenthesized chord lines like `( C#m7(5-)  F#7 )`.
  /// Requires at least one chord to be present.
  bool isChordOnlyLine(String line) {
    var trimmed = line.trim();
    if (trimmed.isEmpty) return false;

    // Strip surrounding parentheses: `( C#m7  F#7 )` → `C#m7  F#7`
    if (trimmed.startsWith('(') && trimmed.endsWith(')')) {
      trimmed = trimmed.substring(1, trimmed.length - 1).trim();
      if (trimmed.isEmpty) return false;
    }

    // Remove inline annotations (which may contain spaces) before splitting.
    // e.g. `(intro 3x) A7+ D7/9` → `A7+ D7/9`
    final stripped = trimmed.replaceAll(_inlineAnnotationPattern, '').trim();
    if (stripped.isEmpty) return false;

    final parts = stripped.split(RegExp(r'\s+'));
    if (parts.isEmpty) return false;

    int chordCount = 0;
    for (final part in parts) {
      if (part.isEmpty) continue;
      if (isChord(part)) {
        chordCount++;
      } else {
        return false;
      }
    }

    return chordCount > 0;
  }

  /// Extracts chords with their column positions from a [line].
  ///
  /// Annotations are skipped. Returns a list of records with
  /// `chord` (the chord text) and `column` (0-based column position).
  List<({String chord, int column})> extractChords(String line) {
    final chords = <({String chord, int column})>[];
    final parts = RegExp(r'\S+').allMatches(line);

    for (final match in parts) {
      final text = match.group(0)!;
      if (isChord(text)) {
        chords.add((chord: text, column: match.start));
      }
      // Annotations and non-chords are silently skipped
    }

    return chords;
  }
}
