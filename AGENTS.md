# Repository Guidelines

## Project Structure & Module Organization
The library entry point lives in `lib/interact.dart`, which re-exports interactive components from `lib/src/`. Component internals are grouped by responsibility (`lib/src/theme/` for styling, `lib/src/framework/` for shared console utilities). Usage samples and smoke tests sit in `example/`, including `example/main.dart` for a quick showcase and focused snippets such as `example/select.dart`. Keep new assets lightweight and store any documentation artefacts under `docs/` if added. `analysis_options.yaml` pulls in the shared lint package, and `CHANGELOG.md` records release notes—update both when behaviour shifts.

## Build, Test, and Development Commands
- `dart pub get` – install or update dependencies before any build.
- `dart format .` – run the formatter prior to commits; CI expects canonical Dart formatting.
- `dart analyze` – invoke static analysis with the repository lint rules.
- `dart test` – execute the unit test suite once new `test/` files are added.
- `dart run example/select.dart` – exercise interactive flows manually; swap the path for other demos.

## Coding Style & Naming Conventions
Dart defaults apply: two-space indentation, trailing commas on multiline collections, and `final` for values that never reassign. Follow the Conventional Lints enforced by `package:lint`; prefer explicit imports and null-aware operators to guard terminal interactions. Avoid `dynamic` in favour of `Object?`, validating concrete types at the boundaries where results surface. Public APIs exposed via `lib/interact.dart` should use PascalCase classes and camelCase methods; files should mirror class names (`progress.dart`, `multi_spinner.dart`). Run the formatter before pushing to ensure consistent whitespace and ordering.

## Testing Guidelines
Use `package:test` for new coverage, placing specs under `test/` with names ending in `_test.dart` (for example, `progress_test.dart`). Aim to isolate terminal I/O with fakes from `lib/src/framework/` so assertions remain deterministic. Add regression tests whenever you touch parsing, selection logic, or progress updates. High-value changes should include scenario-focused tests plus an example update where feasible; wire them into `dart test` locally before opening a PR.

## Commit & Pull Request Guidelines
Recent history adopts Conventional Commit prefixes (`refactor:`, `chore:`, `fix:`). Keep subject lines under 72 characters and expand context in the body when behaviour changes. Each pull request should summarise the impact, reference related issues, and list validation steps (`dart analyze`, `dart test`, demo commands). Attach terminal screenshots or asciicasts when UX output changes. Update `CHANGELOG.md` in the same PR for user-visible adjustments and ensure reviewers can follow reproduction steps quickly.
