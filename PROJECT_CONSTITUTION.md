# Project Constitution for iclf_parser

Foundational rules governing development decisions for this Dart package. These ensure quality, security, and pub.dev compliance. **Non-negotiable unless explicitly amended.**

---

## 1. pub.dev Requirements & Recommendations

### 1.1 Required Elements (Must Have)
- [ ] Valid `pubspec.yaml` with semantic versioning (MAJOR.MINOR.PATCH)
- [ ] `LICENSE` file (MIT) - **DONE**
- [ ] `README.md` with installation, usage examples, and API overview - **DONE**
- [ ] `CHANGELOG.md` following [Keep a Changelog](https://keepachangelog.com/) format
- [ ] Null safety enabled (Dart 3.x) - **DONE**
- [ ] No analyzer errors or warnings
- [ ] At least one example in `example/` directory - **DONE**

### 1.2 Recommendations (Should Have for High Pub Points)
- [ ] API documentation (dartdoc comments) on all public classes, methods, parameters
- [ ] Topics in `pubspec.yaml` (e.g., `topics: [parser, music, lyrics, chords]`)
- [ ] Screenshots or GIFs in README for CLI output
- [ ] Funding links if applicable
- [ ] Verified publisher on pub.dev
- [ ] Multi-platform support declaration
- [ ] `homepage` field in pubspec.yaml

### 1.3 Pub Points Scoring Areas
| Area | Weight | Our Strategy |
|------|--------|--------------|
| Follow Dart conventions | 30 | Strict linting, dartfmt |
| Provide documentation | 20 | Dartdoc on all public API |
| Platform support | 20 | Pure Dart, all platforms |
| Pass static analysis | 20 | Zero warnings policy |
| Support up-to-date dependencies | 10 | Regular updates |

---

## 2. Lint Rules

### 2.1 Current Configuration
We use `package:lints/recommended.yaml` as base with additional rules.

### 2.2 Mandatory Lint Rules

See `analysis_options.yaml` for the complete configuration. Key categories:

| Category | Rules | Purpose |
|----------|-------|---------|
| **Type Safety** | `strict-casts`, `strict-raw-types`, `avoid_dynamic_calls` | Catch type errors at compile time |
| **Error Prevention** | `cancel_subscriptions`, `close_sinks`, `throw_in_finally` | Prevent resource leaks and bugs |
| **Style** | `prefer_const_*`, `prefer_final_*`, `prefer_single_quotes` | Consistent, readable code |
| **Documentation** | `public_member_api_docs` | Required for pub.dev points |
| **Async** | `await_only_futures`, `unawaited_futures` | Catch async/await mistakes |

**Note**: `avoid_print` is globally ignored since this package includes a CLI tool where print is expected.

### 2.3 Zero Tolerance Policy
- **No warnings in CI** - all warnings treated as errors
- **No `// ignore:` comments** without documented justification
- **No `dynamic` types** unless absolutely necessary with comment explaining why

---

## 3. Security Rules

### 3.1 Input Validation
- [ ] **All external input must be validated** before processing
- [ ] **URL validation**: Only allow HTTPS URLs for `fromUrl()` constructor
- [ ] **Content size limits**: Reject files larger than 1MB to prevent memory exhaustion
- [ ] **Regex timeout/limits**: Guard against ReDoS attacks in user-provided patterns

### 3.2 Safe Defaults
- [ ] **No arbitrary code execution**: Never use `eval` or similar constructs
- [ ] **Fail closed**: On validation failure, reject rather than allow
- [ ] **Sanitize outputs**: Escape special characters when rendering to terminal

### 3.3 Network Security
- [ ] **HTTPS only**: Reject HTTP URLs in `fromUrl()`
- [ ] **Timeout on HTTP requests**: Maximum 30 seconds
- [ ] **Certificate validation**: Never disable SSL verification
- [ ] **User-Agent identification**: Identify as `iclf_parser/VERSION`

### 3.4 Dependency Security
- [ ] **Minimal dependencies**: Only add packages that are essential
- [ ] **Audit dependencies**: Review before adding new packages
- [ ] **Lock versions**: Use version constraints, not `any`
- [ ] **Regular updates**: Check for security advisories monthly

### 3.5 Data Handling
- [ ] **No PII storage**: Parser should be stateless
- [ ] **No telemetry**: Never phone home without explicit consent
- [ ] **Temp files**: Use secure temp directories, clean up after use

---

## 4. Best Practices

### 4.1 API Design
- **Immutable models**: All model classes should be immutable (final fields)
- **Named constructors**: Use factory constructors for alternative creation paths
- **Clear error messages**: Include context (line number, expected vs actual)
- **Null safety**: Prefer non-nullable types; use `?` only when absence is meaningful

### 4.2 Testing Requirements
- [ ] **Minimum 95% code coverage** (enforced in CI)
- [ ] **Unit tests**: Every public method
- [ ] **Integration tests**: Full parsing flows
- [ ] **Edge cases**: Empty files, malformed input, huge files
- [ ] **Regression tests**: Add test for every bug fix

### 4.3 Versioning (Semantic Versioning)
- **MAJOR** (1.x.x → 2.0.0): Breaking API changes
- **MINOR** (1.0.x → 1.1.0): New features, backward compatible
- **PATCH** (1.0.0 → 1.0.1): Bug fixes only

### 4.4 Git Practices
- **Branch naming**: `feature/`, `fix/`, `docs/`, `chore/`
- **Commit messages**: Imperative mood ("Add feature" not "Added feature")
- **No force push to main**
- **Squash merge for features**

### 4.5 Documentation Standards
- Every public class: One-sentence summary + usage example
- Every public method: What it does, parameters, return value, exceptions
- Complex logic: Inline comments explaining "why", not "what"

### 4.6 Performance
- **Lazy parsing**: Don't parse what isn't needed
- **Stream large files**: Don't load entire file into memory for huge files
- **Cache regex**: Compile patterns once, reuse

---

## 5. CI/CD Pipeline

### 5.1 Local CI (Run Before Commits)
```bash
# Run all checks locally to save CI tokens
./scripts/ci.sh

# Or individual checks
./scripts/ci.sh format    # Check formatting only
./scripts/ci.sh analyze   # Run analyzer only
./scripts/ci.sh test      # Run tests with coverage
./scripts/ci.sh coverage  # Check coverage threshold (95%)
./scripts/ci.sh all       # Full suite (default)
```

### 5.2 GitHub Actions Checklist
```yaml
# .github/workflows/ci.yml should include:
- [ ] Run `dart analyze` (zero warnings)
- [ ] Run `dart format --set-exit-if-changed`
- [ ] Run `dart test` with coverage
- [ ] Enforce 95% coverage threshold
- [ ] Run on multiple Dart versions (stable, beta)
```

### 5.3 Pre-Commit Hooks (Recommended)
```bash
# Install pre-commit hooks for automatic checks
./scripts/setup-hooks.sh
```
This runs `./scripts/ci.sh quick` (format + analyze) before every commit.

---

## 6. Pre-Release Checklist

Before any pub.dev release:

- [ ] All tests pass
- [ ] Zero analyzer warnings
- [ ] CHANGELOG.md updated
- [ ] Version bumped in pubspec.yaml
- [ ] README examples tested and working
- [ ] `dart pub publish --dry-run` succeeds
- [ ] Breaking changes documented (if any)
- [ ] Dependencies up to date

---

## 7. Review Checklist (For PRs)

- [ ] Does it follow the lint rules?
- [ ] Is it tested?
- [ ] Is it documented?
- [ ] Does it handle errors gracefully?
- [ ] Are there security implications?
- [ ] Is it backward compatible (or is breaking change documented)?

---

*Last updated: 2025-01-14*
*Version: 1.0*