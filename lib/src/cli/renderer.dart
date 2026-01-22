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
      buffer.write(_renderSection(song.sections[i], song.sections.sublist(0, i)));
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

  String _renderSection(Section section, List<Section> previousSections) {
    final buffer = StringBuffer();

    // Section header
    buffer.writeln('[${section.name}]');

    // Section notes
    for (final note in section.notes) {
      buffer.writeln(_formatNote(note));
    }

    // Determine which chords to render
    var chordsToRender = section.chords;

    // If section is empty, look for a previous section with the same name
    if (chordsToRender.isEmpty) {
      for (final prev in previousSections) {
        if (prev.name == section.name && prev.chords.isNotEmpty) {
          chordsToRender = prev.chords;
          break;
        }
      }
    }

    if (chordsToRender.isEmpty) {
      return buffer.toString();
    }

    // Group chords into lines
    final lines = _groupChordsIntoLines(chordsToRender);

    for (final lineChords in lines) {
      // Output blank lines preserved from the original content
      if (lineChords.isNotEmpty && lineChords.first.blankLinesBefore > 0) {
        for (var i = 0; i < lineChords.first.blankLinesBefore; i++) {
          buffer.writeln();
        }
      }

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
    // Build complete lyrics string and track chord positions
    final lyricBuffer = StringBuffer();
    final chordPositions = <(int, String)>[]; // (position, chordText)

    for (final chord in chords) {
      final chordText = _formatChord(chord);
      final lyrics = chord.lyrics;

      // Record chord position before adding lyrics (only for non-empty chords)
      if (chordText.isNotEmpty) {
        chordPositions.add((lyricBuffer.length, chordText));
      }

      lyricBuffer.write(lyrics);
    }

    final lyricLine = lyricBuffer.toString();

    // Check if this is a chord-only line (lyrics are just whitespace)
    if (isChordOnlyLine(chords)) {
      // For chord-only lines, render chords with single space between them
      final chordLine = chordPositions.map((p) => p.$2).join(' ');
      return RenderLineResult(chordLine, '');
    }

    // Build chord line by placing chords at their positions
    final chordLine = StringBuffer();
    var currentPos = 0;

    for (var i = 0; i < chordPositions.length; i++) {
      final (position, chordText) = chordPositions[i];

      // Add spaces to reach the chord position
      if (position > currentPos) {
        chordLine.write(' ' * (position - currentPos));
        currentPos = position;
      } else if (i > 0) {
        // Previous chord extends past this chord's position - add one space
        // Rule: all chords must be separated by at least one space
        chordLine.write(' ');
        currentPos++;
      }

      // Write the chord
      chordLine.write(chordText);
      currentPos += chordText.length;
    }

    return RenderLineResult(
      chordLine.toString().trimRight(),
      lyricLine.trimRight(),
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
    // Start with the shared grouping logic that respects isLineEnd
    final baseLines = groupChordsIntoLines(chords);
    final lines = <List<Chord>>[];

    // Apply width-based wrapping on top of the base grouping
    for (final baseLine in baseLines) {
      var currentLine = <Chord>[];
      var currentWidth = 0;

      for (final chord in baseLine) {
        // Plain lyrics (empty chord name) get their own line
        if (chord.name.isEmpty && baseLine.length == 1) {
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
      }

      if (currentLine.isNotEmpty) {
        lines.add(currentLine);
      }
    }

    return lines;
  }

  int _calculateSegmentWidth(Chord chord) {
    final chordWidth = _formatChord(chord).length + 1;
    final lyricWidth = chord.lyrics.length + 1;
    return max(chordWidth, lyricWidth);
  }

  String _formatNote(Note note) {
    if (note.isHashNote) {
      return '  (* ${note.content})';
    } else {
      return '  (${note.content})';
    }
  }
}
