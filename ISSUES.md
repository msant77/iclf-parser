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
