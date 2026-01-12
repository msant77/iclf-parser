import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'models.dart';

class IclfParser {
  late Map<String, dynamic> _directivesConfig;
  late Map<String, dynamic> _chordsConfig;

  IclfParser(String directivesJsonContent) {
    final json = jsonDecode(directivesJsonContent);
    _directivesConfig = {for (var d in json['directives']) d['name']: d};
    _chordsConfig = json['chords'];
  }

  static Future<IclfParser> fromUrl(String url,
      {http.Client? httpClient}) async {
    final client = httpClient ?? http.Client();
    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return IclfParser(response.body);
      } else {
        throw Exception(
            'Failed to load directives.json: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching directives.json: $e');
    }
  }

  ParseResult parse(String content, {String? filePath}) {
    final lines = content.split('\n');
    final errors = <String>[];
    final warnings = <String>[];
    final globalDirectives = <String, String>{};
    final seenGlobals = <String, int>{}; // Track duplicates
    final notes = <Note>[];
    final sections = <Section>[];
    Section? currentSection;
    bool hasTitle = false;
    bool hasKey = false;
    bool malformed = false;

    // Regex patterns
    final directiveRegex = RegExp(r'^\{([^:]+):\s*(.+)\}$');
    final chordRegex = RegExp(r'\[([^\]:]+)(?::([^\]]+))?\]([^\[]+)');
    final noteRegex = RegExp(r'^# (.+)');
    final chordPattern =
        RegExp(_chordsConfig['validation']['chord']['pattern']);

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      final directiveMatch = directiveRegex.firstMatch(line);
      if (directiveMatch != null) {
        final key = directiveMatch.group(1)!.trim();
        final value = directiveMatch.group(2)!.trim();
        if (_directivesConfig.containsKey(key)) {
          final config = _directivesConfig[key];
          if (!_validateDirective(config, value, errors)) {
            malformed = true;
          }
          if (config['scope'].contains('global')) {
            if (seenGlobals.containsKey(key)) {
              warnings.add(
                  'Duplicate global directive {$key: $value}; keeping first.');
              continue;
            }
            seenGlobals[key] = 1;
            globalDirectives[key] = value;
            if (key == 'title') hasTitle = true;
            if (key == 'key') hasKey = true;
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

      final chordMatches = chordRegex.allMatches(line);
      if (chordMatches.isNotEmpty) {
        if (currentSection == null) {
          currentSection = Section('Intro');
          sections.add(currentSection);
        }
        for (var match in chordMatches) {
          final chordName = match.group(1)!.trim();
          final attrStr = match.group(2);
          final lyrics = match.group(3)!.trim();
          final attributes = <String, String>{};
          if (attrStr != null) {
            final attrPairs = attrStr.split(RegExp(r'(?<!,)\s*,\s*(?![^,]*$)'));
            for (var pair in attrPairs) {
              final parts = pair.split(':');
              if (parts.length == 2) {
                attributes[parts[0].trim()] = parts[1].trim();
              } else {
                errors.add('Malformed chord attribute: $pair');
                malformed = true;
              }
            }
          }
          if (!chordPattern.hasMatch(chordName)) {
            errors.add('Invalid chord: $chordName');
            malformed = true;
          }
          for (var entry in attributes.entries) {
            final attrConfig = _chordsConfig['attributes'].firstWhere(
              (a) => a['name'] == entry.key,
              orElse: () => null,
            );
            if (attrConfig == null) {
              errors.add('Unknown chord attribute: ${entry.key}');
              malformed = true;
            } else if (!_validateAttribute(
                attrConfig['validation'], entry.value, errors)) {
              malformed = true;
            }
          }
          currentSection.chords.add(Chord(chordName, attributes, lyrics));
        }
        continue;
      }

      errors.add('Malformed line: $line');
      malformed = true;
    }

    String? fixedContent;
    ParseStatus status = ParseStatus.valid;
    if (!hasTitle || malformed) {
      status = ParseStatus.invalid;
      errors.add(!hasTitle
          ? 'Missing required {title: ...}'
          : 'Malformed syntax or invalid elements.');
    } else if (!hasKey || warnings.isNotEmpty) {
      status = ParseStatus.recoverable;
      if (!hasKey) {
        fixedContent = '{key: C}\n' + content;
        warnings.add('Added missing {key: C}');
      } else {
        fixedContent = content;
      }
    }

    Song? song;
    if (status != ParseStatus.invalid) {
      song =
          Song(globalDirectives['title'] ?? '', globalDirectives['key'] ?? 'C');
      song.globals.addAll(globalDirectives);
      song.globalNotes.addAll(notes);
      song.sections.addAll(sections);
      for (var sec in sections) {
        for (var dir in sec.localDirectives) {
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
      fixedContent: fixedContent,
      fileHash: hash,
    );
  }

  bool _validateDirective(
      Map<String, dynamic> config, String value, List<String> errors) {
    final val = config['validation'];
    if (val == null) return true;
    if (val['type'] == 'string') {
      if (val['pattern'] != null && !RegExp(val['pattern']).hasMatch(value)) {
        errors.add(
            'Invalid value for ${config['name']}: $value (${val['description']})');
        return false;
      }
    } else if (val['type'] == 'integer') {
      final intVal = int.tryParse(value);
      if (intVal == null ||
          intVal < val['minimum'] ||
          intVal > val['maximum']) {
        errors.add(
            'Invalid integer for ${config['name']}: $value (${val['description']})');
        return false;
      }
    }
    return true;
  }

  bool _validateAttribute(
      Map<String, dynamic> val, String value, List<String> errors) {
    if (val['type'] == 'string') {
      if (val['pattern'] != null && !RegExp(val['pattern']).hasMatch(value)) {
        errors.add('Invalid attribute value: $value (${val['description']})');
        return false;
      }
    } else if (val['type'] == 'integer') {
      final intVal = int.tryParse(value);
      if (intVal == null ||
          intVal < val['minimum'] ||
          intVal > val['maximum']) {
        errors.add('Invalid attribute integer: $value (${val['description']})');
        return false;
      }
    }
    return true;
  }

  String getTempFilePath(String originalPath) {
    return p.setExtension(originalPath, '.iclf.temp');
  }
}
