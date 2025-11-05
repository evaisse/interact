# Contributing to Interact

Thanks for helping improve Interact! Please follow these guidelines so changes
integrate smoothly with the existing codebase.

## Repository Expectations

- **Read `AGENTS.md` first.** It summarizes the project layout, naming rules,
  and how code is organised under `lib/src`.
- Keep `lib/interact.dart` in sync when you add or remove public exports.
- Add or refresh usage notes in `docs/components.md` whenever API behaviour
  changes.
- Record user-visible changes in `CHANGELOG.md`, bumping the version when
  appropriate.

## Setup

1. Fork and clone this repository.
2. Install a recent Dart SDK (`dart --version`).
3. Fetch packages:
   ```bash
   dart pub get
   ```

## Coding Standards

- Dart style with two-space indentation and trailing commas on multiline
  literals.
- Prefer `final` for values that are not reassigned.
- Annotate public APIs with doc comments and code samples.
- Every component must have:
  - A dedicated example under `example/<component>.dart`
  - An entry in `example/kitchen_sink.dart` so it appears in the unified demo
- Keep interactive demos under `example/` lightweight.

## Quality Checks

Run these commands before every commit:

```bash
dart format .
dart analyze
dart test
dart test --coverage=coverage
dart run coverage:format_coverage \
  --lcov \
  --in=coverage \
  --out=coverage/lcov.info \
  --packages=.dart_tool/package_config.json \
  --report-on=lib
dart run tool/coverage_summary.dart --min 80
```

The CI workflow enforces an 80 % line coverage minimum, formatting, and linting.

## Testing Guidelines

- Place specs under `test/` using `package:test`.
- Use `test/helpers/fake_context.dart` to simulate terminal input and output
  without touching the real console.
- When fixing a bug, add a regression test that proves the fix.

## Commit & PR Process

- Use [Conventional Commits](https://www.conventionalcommits.org/) (e.g.
  `feat: add fuzzy multi-select demo`).
- Keep commit subjects under 72 characters.
- PRs should include:
  - Summary of the change
  - Linked issues (if any)
  - Validation steps (commands you ran)
  - Screenshots or recordings when terminal UX changes

## Submitting Changes

1. Ensure all validation commands succeed locally.
2. Commit with an appropriate Conventional Commit message.
3. Push to your fork and open a pull request against `main`.
4. Address review feedback promptly.

If anything is unclear, open an issue or start a discussion. Thanks again for
your contributions!
