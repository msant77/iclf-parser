import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'models.dart';
import 'validator.dart';

class IclfParser {
  late Map<String, dynamic> _directivesConfig;
  late Map<String, dynamic> _chordsConfig;
  final Validator _validator = Validator();

  IclfParser(String directivesJsonContent) {
    final json = jsonDecode(directivesJsonContent);
    _directivesConfig = {for (var d in json['directives']) d['name']: d};
    _chordsConfig = json['chords'];
  }

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
        RegExp(r'\[([^\]:]+)(?::([^\]]+))?\]([^\[]+)'); // Unicode-safe
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
        if (key == 'section') {
          currentSection = Section(value);
          sections.add(currentSection);
          continue;
        }
        if (_directivesConfig.containsKey(key)) {
          final config = _directivesConfig[key];
          if (!_validator.validateDirective(config, value, errors)) {
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
            final attrParts = attrStr.split(',');
            for (int i = 0; i < attrParts.length; i += 2) {
              if (i + 1 < attrParts.length) {
                final attrKey = attrParts[i].trim();
                final attrValue = attrParts[i + 1].trim();
                attributes[attrKey] = attrValue;
              } else {
                errors.add('Malformed chord attribute: unpaired key at end');
                malformed = true;
              }
            }
          }
          if (!_validator.validateChord(chordName, chordPattern, errors)) {
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
            } else if (!_validator.validateAttribute(
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

    String? fixedContent = content;
    ParseStatus status = ParseStatus.valid;
    List<String> missingRequired = [];

    for (var configEntry in _directivesConfig.entries) {
      var config = configEntry.value;
      if (config['required'] == true &&
          config['scope'].contains('global') &&
          !globalDirectives.containsKey(configEntry.key)) {
        if (config.containsKey('default')) {
          final defaultValue = config['default'] as String;
          fixedContent =
              '{${configEntry.key}: $defaultValue}\n' + fixedContent!;
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
      fixedContent: fixedContent == content ? null : fixedContent,
      fileHash: hash,
    );
  }

  String getTempFilePath(String originalPath) {
    return p.setExtension(originalPath, '.iclf.temp');
  }
}
