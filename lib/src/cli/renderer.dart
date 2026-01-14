import 'dart:math';
import '../models.dart';

/// Result of rendering a single line of chords with lyrics.
///
/// Contains the chord line (displayed above) and the corresponding
/// lyric line (displayed below) for a segment of the song.
class RenderLineResult {
  /// The chord names positioned above their corresponding lyrics.
  final String chordLine;

  /// The lyrics positioned below their corresponding chords.
  final String lyricLine;

  /// Creates a render result with the given [chordLine] and [lyricLine].
  RenderLineResult(this.chordLine, this.lyricLine);
}

/// Renders ICLF [Song] objects as traditional chord sheets
/// with chords displayed above corresponding lyrics.
///
/// Example output:
/// ```
/// [Verse 1]
/// G       G7         C         G
/// Amazing grace, how sweet the sound,
/// ```
class IclfRenderer {
  /// Maximum line width before wrapping. Defaults to 80 characters.
  final int maxWidth;

  /// Whether to use compact mode (less whitespace). Defaults to false.
  final bool compact;

  /// Creates a renderer with optional [maxWidth] and [compact] settings.
  IclfRenderer({
    this.maxWidth = 80,
    this.compact = false,
  });

  /// Renders a Song to a formatted chord sheet string
  String render(Song song) {
    final buffer = StringBuffer();

    // Title header
    if (!compact) {
      buffer.writeln('=' * maxWidth);
      final title = song.title.toUpperCase();
      final padding = ((maxWidth - title.length) / 2).floor();
      buffer.writeln(' ' * max(0, padding) + title);
      buffer.writeln('=' * maxWidth);
    } else {
      buffer.writeln(song.title.toUpperCase());
    }

    // Metadata line
    final metadata = _buildMetadataLine(song);
    if (metadata.isNotEmpty) {
      buffer.writeln(metadata);
    }

    if (!compact) {
      buffer.writeln('-' * maxWidth);
      buffer.writeln();
    }

    // Global notes
    for (final note in song.globalNotes) {
      buffer.writeln(_formatNote(note));
    }
    if (song.globalNotes.isNotEmpty && !compact) {
      buffer.writeln();
    }

    // Sections
    for (var i = 0; i < song.sections.length; i++) {
      buffer.write(_renderSection(song.sections[i]));
      if (!compact && i < song.sections.length - 1) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  String _buildMetadataLine(Song song) {
    final parts = <String>[];
    parts.add('Key: ${song.key}');

    if (song.globals.containsKey('composer')) {
      parts.add('Composer: ${song.globals['composer']}');
    }
    if (song.globals.containsKey('capo') && song.globals['capo'] != '0') {
      parts.add('Capo: ${song.globals['capo']}');
    }
    if (song.globals.containsKey('tempo')) {
      parts.add('Tempo: ${song.globals['tempo']} BPM');
    }

    return parts.join(' | ');
  }

  String _renderSection(Section section) {
    final buffer = StringBuffer();

    // Section header
    buffer.writeln('[${section.name}]');

    // Section notes
    for (final note in section.notes) {
      buffer.writeln(_formatNote(note));
    }

    if (section.chords.isEmpty) {
      return buffer.toString();
    }

    // Group chords into lines
    final lines = _groupChordsIntoLines(section.chords);

    for (final lineChords in lines) {
      final result = _renderChordLine(lineChords);

      // Only print chord line if there are chords
      if (result.chordLine.trim().isNotEmpty) {
        buffer.writeln(result.chordLine);
      }
      buffer.writeln(result.lyricLine);

      if (!compact) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }

  RenderLineResult _renderChordLine(List<Chord> chords) {
    final chordBuffer = StringBuffer();
    final lyricBuffer = StringBuffer();

    for (final chord in chords) {
      final chordText = _formatChord(chord);
      final lyrics = chord.lyrics;

      // Calculate segment width - ensure at least 1 space between segments
      final chordWidth = chordText.length;
      final lyricWidth = lyrics.length;
      final segmentWidth = max(chordWidth + 1, lyricWidth + 1);

      // Pad chord and lyrics to segment width
      chordBuffer.write(chordText.padRight(segmentWidth));
      lyricBuffer.write(lyrics.padRight(segmentWidth));
    }

    return RenderLineResult(
      chordBuffer.toString().trimRight(),
      lyricBuffer.toString().trimRight(),
    );
  }

  String _formatChord(Chord chord) {
    var result = chord.name;

    // Handle bass attribute - display as slash chord
    if (chord.attributes.containsKey('bass')) {
      final bassNotes = chord.attributes['bass']!;
      // If single bass note, show as slash chord
      if (!bassNotes.contains('-')) {
        result += '/$bassNotes';
      }
    }

    // Handle voicing
    if (chord.attributes.containsKey('voicing')) {
      result += '(${chord.attributes['voicing']})';
    }

    return result;
  }

  List<List<Chord>> _groupChordsIntoLines(List<Chord> chords) {
    final lines = <List<Chord>>[];
    var currentLine = <Chord>[];
    var currentWidth = 0;

    for (final chord in chords) {
      // Plain lyrics (empty chord name) get their own line
      if (chord.name.isEmpty) {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
          currentLine = [];
          currentWidth = 0;
        }
        lines.add([chord]);
        continue;
      }

      final segmentWidth = _calculateSegmentWidth(chord);

      // Check width limit
      if (currentWidth + segmentWidth > maxWidth && currentLine.isNotEmpty) {
        lines.add(currentLine);
        currentLine = [];
        currentWidth = 0;
      }

      currentLine.add(chord);
      currentWidth += segmentWidth;

      // Check for natural line breaks (phrase endings)
      if (_isPhraseBoundary(chord.lyrics)) {
        lines.add(currentLine);
        currentLine = [];
        currentWidth = 0;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines;
  }

  int _calculateSegmentWidth(Chord chord) {
    final chordWidth = _formatChord(chord).length + 1;
    final lyricWidth = chord.lyrics.length + 1;
    return max(chordWidth, lyricWidth);
  }

  bool _isPhraseBoundary(String lyrics) {
    final trimmed = lyrics.trimRight();
    if (trimmed.isEmpty) return false;

    // Check for sentence-ending punctuation
    const endings = ['.', '!', '?', ','];
    final lastChar = trimmed[trimmed.length - 1];
    return endings.contains(lastChar);
  }

  String _formatNote(Note note) {
    if (note.isHashNote) {
      return '  (* ${note.content})';
    } else {
      return '  (${note.content})';
    }
  }
}
