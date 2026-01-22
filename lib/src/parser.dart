import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'models.dart';
import 'validator.dart';

/// Parser for Inline Chorded Lyrics Format (ICLF) files.
///
/// Parses ICLF content and validates it against the official specification
/// loaded from a JSON configuration file.
///
/// Example usage:
/// ```dart
/// // Load parser with spec from URL
/// final parser = await IclfParser.fromUrl(
///   'https://raw.githubusercontent.com/msant77/iclf-standard/master/directives.json'
/// );
///
/// // Parse content
/// final result = parser.parse(iclfContent);
/// if (result.status == ParseStatus.valid) {
///   print('Title: ${result.song!.title}');
/// }
/// ```
class IclfParser {
  late Map<String, Map<String, dynamic>> _directivesConfig;
  late Map<String, dynamic> _chordsConfig;
  final Validator _validator = Validator();

  /// Creates a parser with the given ICLF specification JSON.
  ///
  /// The [directivesJsonContent] should be the contents of a valid
  /// ICLF directives.json file defining directive and chord rules.
  ///
  /// Throws [FormatException] if the JSON is invalid.
  IclfParser(String directivesJsonContent) {
    final json = jsonDecode(directivesJsonContent) as Map<String, dynamic>;
    final directives = json['directives'] as List<dynamic>;
    _directivesConfig = {
      for (final d in directives)
        (d as Map<String, dynamic>)['name'] as String: d
    };
    _chordsConfig = json['chords'] as Map<String, dynamic>;
  }

  /// Creates a parser by fetching the ICLF specification from a URL.
  ///
  /// Loads the directives.json from [url] and initializes the parser.
  /// An optional [httpClient] can be provided for testing.
  ///
  /// Throws [Exception] if the HTTP request fails.
  ///
  /// Example:
  /// ```dart
  /// final parser = await IclfParser.fromUrl(
  ///   'https://raw.githubusercontent.com/msant77/iclf-standard/master/directives.json'
  /// );
  /// ```
  static Future<IclfParser> fromUrl(String url,
      {http.Client? httpClient}) async {
    final client = httpClient ?? http.Client();
    final response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return IclfParser(response.body);
    } else {
      throw Exception('Failed to load directives.json: ${response.statusCode}');
    }
  }

  /// Parses ICLF content and returns a [ParseResult].
  ///
  /// The [content] is the raw ICLF file content to parse.
  /// Optionally provide [filePath] to enable file hash computation.
  ///
  /// Returns a [ParseResult] containing:
  /// - [ParseResult.status]: Whether the file is valid, invalid, or recoverable
  /// - [ParseResult.song]: The parsed song (null if invalid)
  /// - [ParseResult.errors]: List of error messages
  /// - [ParseResult.warnings]: List of warning messages
  /// - [ParseResult.fixedContent]: Auto-corrected content (for recoverable files)
  /// - [ParseResult.fileHash]: MD5 hash of content (if filePath provided)
  ParseResult parse(String content, {String? filePath}) {
    final lines = content.split('\n');
    final errors = <String>[];
    final warnings = <String>[];
    final globalDirectives = <String, String>{};
    final seenGlobals = <String, int>{};
    final notes = <Note>[];
    final sections = <Section>[];
    Section? currentSection;
    bool malformed = false;

    final directiveRegex = RegExp(r'^\{([^:]+):\s*(.+)\}$');
    final chordRegex =
        RegExp(r'\[([^\]:]+)(?::([^\]]+))?\]([^\[]*)'); // Unicode-safe, allows empty lyrics
    final noteRegex = RegExp(r'^# (.+)');
    final validation = _chordsConfig['validation'] as Map<String, dynamic>;
    final chordValidation = validation['chord'] as Map<String, dynamic>;
    final chordPattern = RegExp(chordValidation['pattern'] as String);

    // Track blank lines between content (not at section boundaries)
    int pendingBlankLines = 0;
    bool sectionHasContent = false;

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        // Only count blank lines after section has content
        if (sectionHasContent) {
          pendingBlankLines++;
        }
        continue;
      }

      final directiveMatch = directiveRegex.firstMatch(line);
      if (directiveMatch != null) {
        final key = directiveMatch.group(1)!.trim();
        final value = directiveMatch.group(2)!.trim();
        if (key == 'section') {
          currentSection = Section(value);
          sections.add(currentSection);
          // Reset blank line tracking for new section
          pendingBlankLines = 0;
          sectionHasContent = false;
          continue;
        }
        if (_directivesConfig.containsKey(key)) {
          final config = _directivesConfig[key]!;
          if (!_validator.validateDirective(config, value, errors)) {
            malformed = true;
          }
          final scope = config['scope'] as String;
          if (scope.contains('global')) {
            if (seenGlobals.containsKey(key)) {
              warnings.add(
                  'Duplicate global directive {$key: $value}; keeping first.');
              continue;
            }
            seenGlobals[key] = 1;
            globalDirectives[key] = value;
            if (sections.isNotEmpty) {
              warnings.add(
                  'Late global directive {$key: $value}; applied song-wide.');
            }
          } else if (currentSection != null) {
            currentSection.localDirectives.add(Directive(key, value));
          } else {
            errors.add(
                'Section-scoped directive {$key: $value} outside section.');
            malformed = true;
          }
        } else {
          notes.add(Note(line, false));
        }
        continue;
      }

      final noteMatch = noteRegex.firstMatch(line);
      if (noteMatch != null) {
        final noteContent = noteMatch.group(1)!.trim();
        (currentSection?.notes ?? notes).add(Note(noteContent, true));
        continue;
      }

      final chordMatches = chordRegex.allMatches(line).toList();
      if (chordMatches.isNotEmpty) {
        if (currentSection == null) {
          currentSection = Section('Intro');
          sections.add(currentSection);
          pendingBlankLines = 0;
          sectionHasContent = false;
        }

        // Track blank lines for the first chord of this line
        final lineBlankLines = pendingBlankLines;
        pendingBlankLines = 0;
        sectionHasContent = true;
        bool isFirstChordOfLine = true;

        // Capture leading text before the first chord
        final firstMatchStart = chordMatches.first.start;
        if (firstMatchStart > 0) {
          final leadingText = line.substring(0, firstMatchStart);
          currentSection.chords.add(Chord('', {}, leadingText,
              blankLinesBefore: lineBlankLines));
          isFirstChordOfLine = false;
        }

        for (var i = 0; i < chordMatches.length; i++) {
          final match = chordMatches[i];
          final isLast = i == chordMatches.length - 1;
          final chordName = match.group(1)!.trim();
          final attrStr = match.group(2);
          final lyrics = match.group(3) ?? '';
          final attributes = <String, String>{};
          if (attrStr != null) {
            final attrParts = attrStr.split(',');
            for (int j = 0; j < attrParts.length; j += 2) {
              if (j + 1 < attrParts.length) {
                final attrKey = attrParts[j].trim();
                final attrValue = attrParts[j + 1].trim();
                attributes[attrKey] = attrValue;
              } else {
                errors.add('Malformed chord attribute: unpaired key at end');
                malformed = true;
              }
            }
          }
          // Skip validation for empty chord names (plain lyrics)
          if (chordName.isNotEmpty &&
              !_validator.validateChord(chordName, chordPattern, errors)) {
            malformed = true;
          }
          final chordAttributes = _chordsConfig['attributes'] as List<dynamic>;
          for (final entry in attributes.entries) {
            Map<String, dynamic>? attrConfig;
            for (final a in chordAttributes) {
              final attr = a as Map<String, dynamic>;
              if (attr['name'] == entry.key) {
                attrConfig = attr;
                break;
              }
            }
            if (attrConfig == null) {
              errors.add('Unknown chord attribute: ${entry.key}');
              malformed = true;
            } else {
              final attrValidation =
                  attrConfig['validation'] as Map<String, dynamic>;
              if (!_validator.validateAttribute(
                  attrValidation, entry.value, errors)) {
                malformed = true;
              }
            }
          }
          currentSection.chords.add(Chord(
            chordName,
            attributes,
            lyrics,
            isLineEnd: isLast,
            blankLinesBefore: isFirstChordOfLine ? lineBlankLines : 0,
          ));
          isFirstChordOfLine = false;
        }
        continue;
      }

      // Line doesn't match directive, note, or chord patterns
      // Treat as plain lyrics (continuation line)
      if (currentSection == null) {
        currentSection = Section('Intro');
        sections.add(currentSection);
        pendingBlankLines = 0;
        sectionHasContent = false;
      }
      // Add as a chord with empty name to represent plain lyrics
      final lineBlankLines = pendingBlankLines;
      pendingBlankLines = 0;
      sectionHasContent = true;
      currentSection.chords.add(Chord('', {}, line,
          isLineEnd: true, blankLinesBefore: lineBlankLines));
    }

    String? fixedContent = content;
    ParseStatus status = ParseStatus.valid;
    final missingRequired = <String>[];

    for (final configEntry in _directivesConfig.entries) {
      final config = configEntry.value;
      final isRequired = config['required'] as bool? ?? false;
      final configScope = config['scope'] as String;
      if (isRequired &&
          configScope.contains('global') &&
          !globalDirectives.containsKey(configEntry.key)) {
        if (config.containsKey('default')) {
          final defaultValue = config['default'] as String;
          fixedContent =
              '{${configEntry.key}: $defaultValue}\n$fixedContent';
          warnings.add('Added missing {${configEntry.key}: $defaultValue}');
          globalDirectives[configEntry.key] = defaultValue;
          if (status == ParseStatus.valid) status = ParseStatus.recoverable;
        } else {
          missingRequired.add(configEntry.key);
        }
      }
    }

    if (missingRequired.isNotEmpty || malformed) {
      status = ParseStatus.invalid;
      if (missingRequired.isNotEmpty) {
        errors.add(
            'Missing required directives: ${missingRequired.map((k) => '{$k: ...}').join(', ')}');
      }
      if (malformed) {
        errors.add('Malformed syntax or invalid elements.');
      }
    } else if (warnings.isNotEmpty) {
      status = ParseStatus.recoverable;
    }

    Song? song;
    if (status != ParseStatus.invalid) {
      song =
          Song(globalDirectives['title'] ?? '', globalDirectives['key'] ?? 'C');
      song.globals.addAll(globalDirectives);
      song.globalNotes.addAll(notes);
      song.sections.addAll(sections);
      for (final sec in sections) {
        for (final dir in sec.localDirectives) {
          if (dir.name == 'repeat') {
            warnings.add(
                'Repeat directive noted for section ${sec.name}: ${dir.value}');
          }
        }
      }
    }

    String? hash;
    if (filePath != null) {
      final bytes = utf8.encode(content);
      hash = md5.convert(bytes).toString();
    }

    return ParseResult(
      status: status,
      song: song,
      errors: errors,
      warnings: warnings,
      fixedContent: fixedContent == content ? null : fixedContent,
      fileHash: hash,
    );
  }

  /// Generates a temporary file path for storing auto-corrected content.
  ///
  /// Given an [originalPath] like "song.iclf", returns "song.iclf.temp".
  /// Use this to save [ParseResult.fixedContent] for recoverable files.
  String getTempFilePath(String originalPath) {
    return p.setExtension(originalPath, '.iclf.temp');
  }
}
