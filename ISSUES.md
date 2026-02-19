# iclf-parser - Planned Issues

This file tracks intended GitHub issues before creation. Once approved, issues will be created in the repository.

**Process:**
1. Draft issues here with labels and acceptance criteria
2. Review and approve
3. Create in GitHub with `gh issue create`
4. Mark `[GH: #123]` with issue number once created
5. Update status as work progresses

**Legend:**
- `[GH: -]` = Not yet created in GitHub
- `[GH: #123]` = Created, issue number 123

---

## Infrastructure

### ~~Consolidate directives.json to single source~~ `[GH: -]`
- **Status:** Done
- **Labels:** `infrastructure`, `cleanup`
- **Description:** Remove `test/fixtures/directives.json` copy and reference `../iclf-standard/directives.json` instead
- **Acceptance Criteria:**
  - [x] Update `test/fixtures/directives_json.dart` to load from `../iclf-standard/directives.json`
  - [x] Delete `test/fixtures/directives.json`
  - [x] Verify all tests pass
  - [x] Update CLAUDE.md CLI examples if needed

### ~~Consolidate samples to single source~~ `[GH: -]`
- **Status:** Done
- **Labels:** `infrastructure`, `cleanup`
- **Description:** Remove `Samples/` folder and reference `../iclf-standard/samples/` instead
- **Acceptance Criteria:**
  - [x] Sync any unique samples (maracatu-eta.iclf) to iclf-standard
  - [x] Resolve sample differences (aroma.iclf) - kept iclf-standard version
  - [x] Update all references to Samples/ in code and docs
  - [x] Delete `Samples/` folder
  - [x] Verify CLI and examples work with new path

---

## Enhancements

### ~~Repeat content for empty sections with same name~~ `[GH: #1 ✓]`
- **Status:** Done
- **Labels:** `feature`, `cli`
- **Description:** When an empty section has the same name as a previous section with content, render the original section's content. This provides implicit repetition without requiring the `{repeat: ...}` directive.
- **Example:**
  ```
  {section: Chorus}
  [G]Hello [C]world

  {section: Verse}
  [Am]Some verse

  {section: Chorus}
  ```
  The second `{section: Chorus}` is empty but should render the content from the first Chorus.
- **Acceptance Criteria:**
  - [x] Renderer looks up first section with matching name when current section is empty
  - [x] If found with content, render that content under the current section header
  - [x] If no match found or original also empty, render just the header (current behavior)
  - [x] Add tests for repeated empty sections
  - [x] Works with `face.iclf` sample (has `{section: part one}` repeated empty)

### ~~Extract bass note from slash chords during parsing~~ `[GH: #2 ✓]`
- **Status:** Done
- **Labels:** `feature`, `enhancement`
- **Description:** Slash chords like A7/D should have their bass note extracted into the attributes map, allowing the chord name to be just 'A7' while preserving the bass note information.
- **Acceptance Criteria:**
  - [x] Parsing 'A7/D' creates Chord with name='A7' and attributes['bass']='D'
  - [x] Added `bassNote` getter to Chord class
  - [x] Added `symbol` property that reconstructs full slash chord notation
  - [x] Regular chords unaffected (`chord.symbol` == `chord.name`)
  - [x] All tests pass

### ~~Add Brazilian chord notation tests and parser fix~~ `[GH: #3 ✓]`
- **Status:** Done ✅
- **Labels:** `feature`, `enhancement`
- **Description:** Add comprehensive tests for Brazilian chord notation conventions used in bossa nova and choro, including `7M` (major 7), parenthesized alterations with `+`/`-`, bare numbers in parentheses, and compound intervals. Also fix the parser to preserve `/` inside parentheses.
- **Acceptance Criteria:**
  - [x] Fix parser: skip `/` inside parentheses when extracting bass note
  - [x] Test `7M` as major 7 shorthand
  - [x] Test minus for flat: `(5-)`, `(9-)`, `(11-)`, `(13-)`
  - [x] Test plus for sharp: `(5+)`, `(9+)`, `(11+)`, `(13+)`
  - [x] Test bare numbers in parentheses: `(9)`, `(11)`, `(13)`, `(4)`
  - [x] Test compound intervals: `(6/9)`, `(6/11+)`, `(9/13)`
  - [x] Test real-world Brazilian chords from bossa nova standards
  - [x] Test invalid forms: `CM`, `CmM`, empty parens, invalid intervals
  - [x] All 885 tests pass

### ✅ Parse chord_voicing directives into Song.preferredVoicings `[GH: #5]`
- **Status:** Done
- **Labels:** `feature`, `parsing`
- **Description:** Added `preferredVoicings` map to Song model and parsing support for `{chord_voicing: ChordName, FretString}` directive.
- **Acceptance Criteria:**
  - [x] Song.preferredVoicings populated from chord_voicing directives
  - [x] Multiple chord_voicing directives supported
  - [x] Last voicing wins when same chord specified multiple times
  - [x] Tests added for voicing parsing

### ✅ Support Brazilian 7+ and bare compound interval chord notation `[GH: #4]`
- **Status:** Done
- **Labels:** `feature`, `chord-parsing`
- **Description:** Updated parser to handle `7+` (Brazilian maj7) and bare compound intervals (`D7/9`). Bass note extraction now skips `/digit` sequences (compound intervals).
- **Acceptance Criteria:**
  - [x] Parser handles 7+ chords correctly
  - [x] Parser handles bare compound intervals (D7/9, C7/13)
  - [x] Bass note extraction skips compound intervals
  - [x] Tests added for all new patterns
  - [x] Existing 657 tests still pass

---

## Sprint C: New Features ✅

### [Feature] ✅ Add ChordMatcher for chord validation across parser ecosystem `[GH: #6]`
- **Status:** Done
- **Labels:** `feature`
- **Description:** Added `ChordMatcher` class for consistent chord validation across the ICLF ecosystem. Supports Brazilian notation (7+, 7M, parenthesized alterations), slash chords, compound intervals. Exported from `iclf_parser.dart`. The directive insertion utility (`IclfTextMapper`) was implemented in chordo (#173) since it operates on app-level content.
- **Related:** chordo GH #173, chordo GH #168
- **Acceptance Criteria:**
  - [x] `ChordMatcher` class with `isValidChord()` and `extractChordInfo()`
  - [x] Supports Brazilian notation: 7+, 7M, (5-), (9+), (6/9), etc.
  - [x] Handles slash chords and compound intervals
  - [x] Exported from `iclf_parser.dart` public API
  - [x] 292-line test suite with comprehensive coverage

---

## Issue Template

```markdown
### Issue title `[GH: -]`
- **Status:** Planned | In Progress | Done
- **Labels:** `category`
- **Description:** Brief description of the work
- **Acceptance Criteria:**
  - [ ] Criterion 1
  - [ ] Criterion 2
```

---

## Label Definitions

| Label | Description |
|-------|-------------|
| `infrastructure` | Build, CI, project structure |
| `cleanup` | Removing duplication, tech debt |
| `feature` | New functionality |
| `bug` | Something broken |
| `docs` | Documentation |
| `cli` | Command-line interface |
