# Repository Guidelines

## Project Structure & Module Organization
Source lives in `lib/`, split across `models/`, `services/`, `pages/`, and reusable `widgets/`. Shared helpers sit in `lib/utils/`, while visual constants stay in `lib/theme/`. Assets, including question JSON and illustrations, are under `assets/` (notably `assets/questions/`). Windows launchers remain in `windows/`, and generated build output should stay out of version control.

## Build, Test, and Development Commands
Use `flutter pub get` whenever dependencies change. Run `flutter run -d windows` for an interactive desktop build, and `flutter build windows` when producing distributables. Profile heavy map flows with `flutter run --profile`. Lint with `flutter analyze`, and format edits using `dart format lib test` before review.

## Coding Style & Naming Conventions
Follow the Flutter lints configured in `analysis_options.yaml`; address warnings rather than suppressing them. Stick to two-space indentation, trailing commas in widget trees, and `snake_case.dart` filenames. Classes, enums, and widgets use PascalCase, while private members receive a leading underscore. Place widget-specific extensions beside their widget under `lib/widgets/`.

## Testing Guidelines
Add unit and widget tests in `test/`, mirroring the `lib/` structure with `_test.dart` suffixes. Use `flutter_test` and prefer fakes over touching persistent storage. Aim for at least 75% line coverage on new logic (check with `flutter test --coverage`). Reserve `integration_test/` for multi-screen scenarios that require end-to-end validation.

## Commit & Pull Request Guidelines
Adopt Conventional Commits such as `feat(gameplay): add bonus drafting` or `fix(ui): align map colors`, keeping subjects under 72 characters. Pull requests should summarize changes, list any commands executed (e.g., `flutter analyze`, `flutter test`), and attach screenshots for UI adjustments like updates to `lib/pages/map_page.dart`. Link to supporting docs, including `assets/questions/QUESTION_FEATURE_README.md`, when relevant.

## Content & Configuration Tips
Document any asset rename in `FILE_RENAME_GUIDE.md` before merging. Update question sets via `assets/questions/questions.json` and regenerate associated images within `assets/questions/images/`. Centralize new country metadata in `lib/models/country_configuration.dart`, and expose user-facing strings through `flutter_localizations` to keep translations manageable.
