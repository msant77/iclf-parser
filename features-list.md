# ICLF Parser - Feature Roadmap

## Priority 1: CLI Foundation (Completed)

- [x] Add `args` package dependency for CLI argument parsing
- [x] Create `bin/iclf.dart` entry point
- [x] Create `lib/src/cli/` directory structure
- [x] Implement `IclfRenderer` class for chord sheet formatting
- [x] Implement `CliRunner` class for command parsing
- [x] Add `render` subcommand: `iclf render <file.iclf>`
- [x] Add CLI tests in `test/cli/renderer_test.dart`

## Priority 2: Renderer Features (Completed)

- [x] Chord-above-lyrics alignment algorithm
- [x] Section headers with `[Section Name]` format
- [x] Metadata display (Key, Composer, Capo, Tempo)
- [x] Notes/comments rendering with `(* note)` format
- [x] Line wrapping at configurable width (--width flag)
- [x] Compact mode (--compact flag)

## Priority 3: CLI Polish (Completed)

- [x] --output flag for file output
- [x] --config flag for custom directives.json (URL or local file)
- [x] --help and --version flags
- [x] Error messages with clear guidance
- [x] Warning display for recoverable parse issues

## Priority 4: Future Enhancements (Backlog)

- [ ] `validate` subcommand (validation without rendering)
- [ ] Color output with ANSI codes (--color flag)
- [ ] JSON output format (--format json)
- [ ] Transposition support (--transpose +2)
- [ ] Multiple file processing (glob patterns)
- [ ] Stdin input support (pipe mode)
- [ ] Watch mode for live preview during editing
- [ ] HTML export format
- [ ] PDF export format

## Priority 5: Core Parser Improvements (Backlog)

- [ ] Improved error messages with line numbers
- [ ] Partial parsing (return what was parsed even on error)
- [ ] Streaming parser for large files
- [ ] Custom directive registration API

## CLI Usage

```bash
# Render a chord sheet
iclf render song.iclf

# With options
iclf render song.iclf --width 120 --compact
iclf render song.iclf --output rendered.txt
iclf render song.iclf --config path/to/directives.json

# Help
iclf --help
iclf render --help
```

## Example Output

```
================================================================================
                                 AMAZING GRACE
================================================================================
Key: G | Composer: John Newton | Capo: 2
--------------------------------------------------------------------------------

[Verse 1]
  (* Play softly)
G       G7         C         G
Amazing grace, how sweet the sound,

G            Am          D
That saved a wretch like me.
```
