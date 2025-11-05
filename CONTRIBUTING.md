# Contributing to Interact

Thanks for helping improve Interact! This document captures the expectations for
contributors so we can work efficiently together.

## Getting Started

1. **Fork and clone** this repository.
2. Ensure you have a recent Dart SDK installed (`dart --version`).
3. Install dependencies with:
   ```bash
   dart pub get
   ```

## Development Workflow

- Follow the repository structure described in `AGENTS.md`.
- When touching core components under `lib/src/`, keep the entry point
  `lib/interact.dart` updated if new exports are added.
- Keep documentation in sync:
  - Update `docs/components.md` for user-visible changes.
  - Update `CHANGELOG.md` under the appropriate version header.

## Style & Linting

- The project enforces `package:lint` via `analysis_options.yaml`.
- Before committing, run:
  ```bash
  dart format .
  dart analyze
  dart test
  ```
- Ensure CI passes locally, including coverage:
  ```bash
  dart test --coverage=coverage
  ```
  The workflow enforces a minimum of 80% line coverage. Add or update tests as
  needed.

## Commit & PR Guidelines

- Use [Conventional Commits](https://www.conventionalcommits.org/) (e.g.
  `feat: add fuzzy select demo`).
- Keep commit subjects under 72 characters.
- For pull requests, include:
  - A summary of the change
  - Links to relevant issues
  - Validation steps (commands run)
- Update screenshots or asciicasts when terminal UX changes.

## Tests

- Write unit tests under `test/` using `package:test`.
- Use the `FakeContext` utilities where possible to keep tests deterministic.
- When adding regressions, cover them with a focused test.

## Submitting Changes

1. Run all validation commands.
2. Commit using the recommended conventions.
3. Push to your fork and open a pull request.
4. Mention maintainers if you need review attention.

We appreciate your contribution! If you have questions, open an issue or start a
discussion. Happy hacking!
