enum ParseStatus { valid, invalid, recoverable }

class Directive {
  final String name;
  final String value;
  Directive(this.name, this.value);
}

class Chord {
  final String name;
  final Map<String, String> attributes;
  final String lyrics; // Unicode-safe
  Chord(this.name, this.attributes, this.lyrics);
}

class Note {
  final String content; // Unicode-safe
  final bool isHashNote;
  Note(this.content, this.isHashNote);
}

class Section {
  final String name;
  final List<Chord> chords;
  final List<Note> notes;
  final List<Directive> localDirectives;
  Section(this.name)
      : chords = [],
        notes = [],
        localDirectives = [];
}

class Song {
  final String title;
  String key;
  final Map<String, String> globals;
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
  final String? fixedContent;
  final String? fileHash;
  ParseResult({
    required this.status,
    this.song,
    this.errors = const [],
    this.warnings = const [],
    this.fixedContent,
    this.fileHash,
  });
}
