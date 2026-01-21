/// Status of an ICLF parsing operation.
///
/// - [valid]: The file fully conforms to the ICLF specification.
/// - [invalid]: The file has errors that cannot be automatically corrected.
/// - [recoverable]: The file has issues that were auto-corrected (see [ParseResult.fixedContent]).
enum ParseStatus {
  /// File is fully valid according to ICLF specification.
  valid,

  /// File has unrecoverable errors (e.g., missing required directives without defaults).
  invalid,

  /// File had issues that were automatically corrected.
  recoverable,
}

/// A key-value directive in an ICLF file.
///
/// Directives use the syntax `{name: value}` and control song metadata
/// or section-level settings.
///
/// Example:
/// ```
/// {title: Amazing Grace}
/// {key: G}
/// {capo: 2}
/// ```
class Directive {
  /// The directive name (e.g., "title", "key", "composer").
  final String name;

  /// The directive value.
  final String value;

  /// Creates a new directive with the given [name] and [value].
  Directive(this.name, this.value);
}

/// A chord with optional attributes and associated lyrics.
///
/// Chords use the syntax `[ChordName:attr,value]lyrics` where attributes
/// are optional comma-separated key-value pairs.
///
/// Example:
/// ```
/// [Am]Amazing    // Simple chord
/// [G:bass,D]grace  // Chord with bass note attribute
/// [C:inversion,1]how  // Chord with inversion
/// ```
class Chord {
  /// The chord name (e.g., "Am", "G7", "Cmaj7").
  ///
  /// Empty string indicates plain lyrics without a chord.
  final String name;

  /// Optional chord attributes as key-value pairs.
  ///
  /// Common attributes include:
  /// - "bass": Bass note for slash chords (e.g., "D" for G/D)
  /// - "inversion": Chord inversion (0-3)
  /// - "voicing": Specific voicing identifier
  final Map<String, String> attributes;

  /// The lyrics that follow this chord.
  ///
  /// Supports Unicode characters for international lyrics.
  final String lyrics;

  /// Whether this chord is the last one on its input line.
  ///
  /// Used by the renderer to preserve original line breaks.
  final bool isLineEnd;

  /// Creates a chord with the given [name], [attributes], [lyrics],
  /// and optional [isLineEnd] flag.
  Chord(this.name, this.attributes, this.lyrics, {this.isLineEnd = false});
}

/// A note or comment in an ICLF file.
///
/// Notes can be either hash-style (`# comment`) or directive-style
/// for non-reserved directive names.
class Note {
  /// The note content (without the `#` prefix if hash-style).
  final String content;

  /// Whether this note uses hash syntax (`# comment`).
  ///
  /// If false, the note came from an unrecognized directive.
  final bool isHashNote;

  /// Creates a note with the given [content] and style flag.
  Note(this.content, this.isHashNote);
}

/// A section within an ICLF song (e.g., Verse, Chorus, Bridge).
///
/// Sections are defined with `{section: Name}` and contain chords,
/// notes, and section-scoped directives.
class Section {
  /// The section name (e.g., "Verse 1", "Chorus", "Bridge").
  final String name;

  /// Chords within this section, in order of appearance.
  final List<Chord> chords;

  /// Notes/comments within this section.
  final List<Note> notes;

  /// Directives scoped to this section (e.g., `{repeat: 2}`).
  final List<Directive> localDirectives;

  /// Creates a section with the given [name].
  ///
  /// Lists are initialized empty and populated during parsing.
  Section(this.name)
      : chords = [],
        notes = [],
        localDirectives = [];
}

/// A complete song parsed from an ICLF file.
///
/// Contains all metadata, sections, and global notes extracted
/// from the ICLF content.
class Song {
  /// The song title from the `{title: ...}` directive.
  final String title;

  /// The musical key from the `{key: ...}` directive.
  String key;

  /// All global directives as a key-value map.
  ///
  /// Includes title, key, composer, capo, tempo, and other
  /// song-wide settings.
  final Map<String, String> globals;

  /// Sections of the song in order of appearance.
  final List<Section> sections;

  /// Notes that appear before any section declaration.
  final List<Note> globalNotes;

  /// Creates a song with the given [title] and [key].
  ///
  /// Collections are initialized empty and populated during parsing.
  Song(this.title, this.key)
      : globals = {},
        sections = [],
        globalNotes = [];
}

/// The result of parsing an ICLF file.
///
/// Contains the parsed song (if successful), any errors or warnings
/// encountered, and optionally auto-corrected content.
class ParseResult {
  /// The parsing status indicating validity.
  final ParseStatus status;

  /// The parsed song, or null if parsing failed.
  final Song? song;

  /// Error messages for invalid content.
  ///
  /// Empty list if the file is valid or recoverable.
  final List<String> errors;

  /// Warning messages for recoverable issues.
  ///
  /// Examples: duplicate directives, late global directives,
  /// auto-added default values.
  final List<String> warnings;

  /// Auto-corrected content for recoverable files.
  ///
  /// Null if the file was valid or invalid (not recoverable).
  /// Contains the original content with fixes applied
  /// (e.g., added missing `{key: C}` directive).
  final String? fixedContent;

  /// MD5 hash of the original file content.
  ///
  /// Useful for change detection and caching.
  /// Only populated when a file path was provided to [IclfParser.parse].
  final String? fileHash;

  /// Creates a parse result with the given properties.
  ParseResult({
    required this.status,
    this.song,
    this.errors = const [],
    this.warnings = const [],
    this.fixedContent,
    this.fileHash,
  });
}

// ============================================================================
// Rendering Utilities
// ============================================================================

/// Groups a list of chords into lines based on the [Chord.isLineEnd] flag.
///
/// Each sublist represents one line of chord-lyric pairs as they appeared
/// in the original ICLF file. This preserves the original file arrangement.
///
/// Example:
/// ```dart
/// final lines = groupChordsIntoLines(section.chords);
/// for (final line in lines) {
///   // Render each line...
/// }
/// ```
List<List<Chord>> groupChordsIntoLines(List<Chord> chords) {
  if (chords.isEmpty) return [];

  final lines = <List<Chord>>[];
  var currentLine = <Chord>[];

  for (final chord in chords) {
    currentLine.add(chord);

    if (chord.isLineEnd) {
      lines.add(currentLine);
      currentLine = [];
    }
  }

  // Add any remaining chords that didn't end with isLineEnd
  if (currentLine.isNotEmpty) {
    lines.add(currentLine);
  }

  return lines;
}

/// Returns true if the given line contains only chords (lyrics are whitespace).
///
/// Chord-only lines (like intros: `[Em] [A] [F#m] [B]`) should be rendered
/// with proper spacing between chords rather than relying on lyric positioning.
bool isChordOnlyLine(List<Chord> lineChords) {
  final combinedLyrics = lineChords.map((c) => c.lyrics).join();
  return combinedLyrics.trim().isEmpty;
}
