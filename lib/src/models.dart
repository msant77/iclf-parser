// Enums and Models
enum ParseStatus { valid, invalid, recoverable }

class Directive {
  final String name;
  final String value;
  Directive(this.name, this.value);
}

class Chord {
  final String name;
  final Map<String, String> attributes;
  final String lyrics;
  Chord(this.name, this.attributes, this.lyrics);
}

class Note {
  final String content;
  final bool isHashNote; // true for #, false for custom {key: value}
  Note(this.content, this.isHashNote);
}

class Section {
  final String name;
  final List<Chord> chords;
  final List<Note> notes;
  final List<Directive>
      localDirectives; // e.g., section-specific key or strumming
  Section(this.name)
      : chords = [],
        notes = [],
        localDirectives = [];
}

class Song {
  final String title;
  String key; // Can be overridden per section
  final Map<String, String> globals; // Other global directives
  final List<Section> sections;
  final List<Note> globalNotes;
  Song(this.title, this.key)
      : globals = {},
        sections = [],
        globalNotes = [];
}

class ParseResult {
  final ParseStatus status;
  final Song? song;
  final List<String> errors;
  final List<String> warnings;
  final String? fixedContent; // For recoverable; app can save to temp
  final String? fileHash; // MD5 hash of original content
  ParseResult({
    required this.status,
    this.song,
    this.errors = const [],
    this.warnings = const [],
    this.fixedContent,
    this.fileHash,
  });
}
