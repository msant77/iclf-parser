# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Dart package for parsing and validating Inline Chorded Lyrics Format (ICLF) files. ICLF is a plain-text standard for notating song lyrics with inline chords. The parser validates against the official ICLF specification loaded from JSON.

## Build & Test Commands

```bash
# Get dependencies
dart pub get

# Run all tests
dart test

# Run a single test file
dart test test/basic_parsing_test.dart

# Run tests by tag (tags defined in dart_test.yaml: tag1, tag2)
dart test -t tag1

# Analyze code
dart analyze

# Generate mock files (after modifying mocks)
dart run build_runner build
```

## CLI Usage

```bash
# Render an ICLF file as a chord sheet
dart run bin/iclf.dart render song.iclf

# With options
dart run bin/iclf.dart render song.iclf --width 120 --compact
dart run bin/iclf.dart render song.iclf --output rendered.txt
dart run bin/iclf.dart render song.iclf --config test/fixtures/directives.json

# Help
dart run bin/iclf.dart --help
dart run bin/iclf.dart render --help
```

## Architecture

The library follows a clean separation between models, parsing, validation, and CLI:

```
lib/
├── iclf_parser.dart      # Public API - exports all modules
└── src/
    ├── models.dart       # Data classes: Song, Section, Chord, Note, Directive, ParseResult, ParseStatus
    ├── parser.dart       # IclfParser class - core parsing logic
    ├── validator.dart    # Validator class - directive and chord validation
    └── cli/
        ├── renderer.dart     # IclfRenderer - chord sheet formatting
        └── cli_runner.dart   # CLI command parsing and execution

bin/
└── iclf.dart             # CLI entry point
```

### Key Classes

- **IclfParser**: Main entry point. Created with `IclfParser(jsonContent)` or `IclfParser.fromUrl(url)` for async loading from the official ICLF spec URL
- **ParseResult**: Contains `status` (valid/invalid/recoverable), `song`, `errors`, `warnings`, `fixedContent` (auto-corrected content for recoverable errors), `fileHash`
- **Validator**: Validates directives and chords against regex patterns and integer ranges from the spec JSON

### Parsing Flow

1. Parser loads directive/chord rules from JSON configuration
2. `parse(content)` processes line-by-line using regex patterns
3. Directives (`{key: value}`), chords (`[Am:attr,val]lyrics`), and notes (`# comment`) are extracted
4. Validation runs against loaded spec
5. Returns `ParseResult` with status indicating valid/invalid/recoverable

### Test Structure

Tests in `test/` are organized by functionality with fixture data loaded from `test/fixtures/directives_json.dart`. The `from_url_test.dart` uses Mockito to mock HTTP client (mocks generated in `iclf_parser_test.mocks.dart`).

## Quality Standards

See **PROJECT_CONSTITUTION.md** for comprehensive rules on:
- pub.dev requirements and recommendations
- Lint rules and zero-tolerance policy
- Security rules (input validation, network security)
- Testing requirements (95% coverage minimum)
- Git practices and versioning

## Local CI

Run checks locally before committing to save CI tokens:

```bash
./scripts/ci.sh          # Full suite: format, analyze, test, coverage
./scripts/ci.sh quick    # Fast check: format + analyze only
./scripts/ci.sh test     # Run tests with coverage
./scripts/ci.sh help     # Show all commands
```

Setup pre-commit hooks:
```bash
./scripts/setup-hooks.sh
```
