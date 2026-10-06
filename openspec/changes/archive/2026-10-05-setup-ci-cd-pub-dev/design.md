## Context

The `custom_data_table` package is a Flutter data table library supporting synchronized bi-directional scrolling, date/month filtering, column sorting, record selection, and customizable themes.

To establish the package as a top-tier open-source library on [pub.dev](https://pub.dev), the project requires:
- An official open-source license.
- Complete, validated package metadata in `pubspec.yaml`.
- Comprehensive public documentation with usage snippets in `README.md` and `CHANGELOG.md`.
- Automated test coverage in `test/`.
- A high-speed Continuous Integration (CI) pipeline with caching to validate Pull Requests and branch pushes.

## Goals / Non-Goals

**Goals:**
- Prepare all package files and metadata to comply with pub.dev guidelines and achieve the maximum score on the Pana analyzer (160/160).
- Design and implement a GitHub Actions workflow (`ci.yml`) featuring dual-layer caching (Flutter SDK 3.38.7 and Pub cache).
- Incorporate `flutter pub publish --dry-run` into CI to ensure release-readiness without publishing prematurely.
- Implement an automated test suite utilizing `testWidgets` and unit tests.
- Configure `.pubignore` to exclude development tooling, IDE metadata, and build caches from the package archive.

**Non-Goals:**
- **Compiling APKs, AABs, or Split-ABI binaries**: The project is a pure Dart/Flutter library, not an executable mobile application.
- **Configuring Android NDK, Gradle, or Keystore signing keys**: Not applicable to Flutter package lifecycles.

## Decisions

### 1. MIT License
- **Decision**: Adopt the standard **MIT License** with copyright attributed to `Elias Alfaro (2026)`.
- **Rationale**: Universal open-source adoption, maximum permissiveness, and full compliance with pub.dev licensing criteria.

### 2. Environment Alignment: Flutter 3.38.7 and Dart 3.10.7
- **Decision**: Pin `flutter-version: '3.38.7'` in `subosito/flutter-action@v2`.
- **Rationale**: Exactly mirrors the local development environment, eliminating discrepancies in compiler or analyzer behavior.

### 3. High-Performance Caching in CI
- **Flutter SDK Cache**: Use `cache: true` in `subosito/flutter-action@v2` keyed on OS, channel, and version.
- **Pub Cache**: Use `actions/cache@v4` on `~/.pub-cache` keyed on `pubspec.lock` hash.
- **Rationale**: Reduces CI execution time from ~4 minutes to under 45 seconds per run.

### 4. Strict Validation Pipeline in CI
The pipeline executes sequentially:
1. `dart format --output=none --set-exit-if-changed .`
2. `flutter analyze --fatal-infos`
3. `flutter test`
4. `flutter pub publish --dry-run`
5. Example application analysis (`cd example && flutter pub get && flutter analyze --no-fatal-infos --no-fatal-warnings`).

### 5. Semantic Versioning and Release Candidate
- The current git history has tag `3.0.5`.
- To bundle all metadata, documentation, license, test, and CI enhancements cleanly, the package is prepared as version `3.0.6`.

## Risks / Trade-offs

- **[Risk] Formatting discrepancies in codebase** → *Mitigation*: Run `dart format` prior to committing so that `--set-exit-if-changed` passes consistently in CI.
- **[Risk] Incompatible dependencies in `example/`** → *Mitigation*: Ensure `example/pubspec.yaml` points to the local parent package via `path: ../`.
- **[Risk] Extraneous files bundled in pub package** → *Mitigation*: `.pubignore` filters out `.agent/`, `openspec/`, IDE configs, and build caches.

## Implementation Steps

1. Update `.gitignore` and configure `.pubignore` to exclude development artifacts.
2. Create and update `LICENSE`, `pubspec.yaml`, `README.md`, `CHANGELOG.md`, and `test/`.
3. Create GitHub Actions CI workflow in `.github/workflows/ci.yml`.
4. Execute local validation checks (`format`, `analyze`, `test`, `dry-run`).
5. Confirm successful CI execution on GitHub Actions.
