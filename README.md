# iclf_parser

A Dart package for parsing and validating Inline Chorded Lyrics Format (ICLF) files. ICLF is a plain-text standard for notating song lyrics with inline chords, designed for readability and musical accuracy. This library provides robust parsing, validation against the official ICLF specification, and support for recoverable errors, making it ideal for apps like Chordo that manage and display chorded lyrics.

## Features

-   **Parsing**: Breaks down ICLF content into structured models (e.g., Song, Section, Chord, Note).
-   **Validation**: Checks directives, chords, and attributes against the rules defined in the official directives.json.
-   **Classification**: Categorizes files as valid, invalid, or recoverable (with automatic fixes like adding a default key).
-   **Dynamic Spec Loading**: Loads the latest ICLF specification from the official GitHub repo via URL, ensuring compatibility with updates without package changes.
-   **Fallback Support**: Optional local JSON loading for offline or custom specs.
-   **Hashing**: Computes MD5 hash of file content for change detection.
-   **Extensibility**: Handles non-reserved directives as notes for forward compatibility.

## Installation

Add this to your pubspec.yaml:

YAML

```
dependencies:  iclf_parser: ^1.0.0
```

Then run dart pub get.

## Usage

### Basic Parsing

Dart

```
import 'package:iclf_parser/iclf_parser.dart';Future<void> main() async {  // Load parser with latest spec from URL  final parser = await IclfParser.fromUrl('https://raw.githubusercontent.com/msant77/iclf-standard/master/directives.json');  const iclfContent = '''{title: Parla Più Piano}{key: Am}[Am]Parla più [Dm]pia-[Am]no# Strum gently''';  final result = parser.parse(iclfContent);  if (result.status == ParseStatus.valid) {    print('Song Title: ${result.song!.title}');  } else if (result.status == ParseStatus.recoverable) {    print('Warnings: ${result.warnings}');    // Optionally save result.fixedContent to a temp file  } else {    print('Errors: ${result.errors}');  }}
```

### Loading from Local JSON

If you prefer offline use or a custom spec:

Dart

```
final localJson = // Read from assets or filefinal parser = IclfParser(localJson);
```

### Handling Temp Files

For recoverable files:

Dart

```
if (result.status == ParseStatus.recoverable) {  final tempPath = parser.getTempFilePath('original.iclf');  // await File(tempPath).writeAsString(result.fixedContent!);}
```

### Models Overview

-   **ParseResult**: Contains status, song, errors, warnings, fixedContent, fileHash.
-   **Song**: Holds title, key, globals, sections, globalNotes.
-   **Section**: Includes name, chords, notes, localDirectives.
-   **Chord**: Has name, attributes, lyrics.
-   **Note**: Stores content and isHashNote (for # vs. custom {key: value}).
-   **Directive**: Simple name and value pair.

## ICLF Standard Reference

This library adheres to the Inline Chorded Lyrics Format (ICLF) v1.0 specification, defined in the official repository: [msant77/iclf-standard](https://github.com/msant77/iclf-standard?referrer=grok.com).

The core rules are loaded from [directives.json](https://raw.githubusercontent.com/msant77/iclf-standard/master/directives.json?referrer=grok.com), which includes:

-   **Version**: 1.0
-   **Directives**: Reserved {key: value} pairs like title (required), key (required, default "C"), composer, etc., with scopes (global/section), uniqueness, and validation (e.g., regex for musical keys).
-   **Chords**: Syntax [Chord[:Attribute, Value]], with validation for chord names and attributes like inversion (0-3), bass (note runs).
-   **Notes**: # Comment or non-reserved {key: value}.

The parser dynamically fetches this JSON to validate:

-   Required elements (e.g., missing title → invalid).
-   Duplicates (keep first for uniques, warn).
-   Malformed syntax (e.g., invalid chord → invalid).
-   Recoverable issues (e.g., missing key → add default, warn).

For full spec details, see the [ICLF README](https://github.com/msant77/iclf-standard/blob/master/README.md?referrer=grok.com).

## Contributing

Contributions are welcome! Please open issues or PRs on the [iclf_parser repo](https://github.com/yourusername/iclf_parser?referrer=grok.com) (replace with your repo). Ensure tests pass and follow Dart style guidelines.

## License

MIT License. See LICENSE for details.

## Pub.dev Notes

This package is designed for high pub points:

-   Null safety enabled.
-   No analysis issues (via analysis_options.yaml).
-   Comprehensive tests in test/.
-   Example in example/.

For questions, contact the maintainer.