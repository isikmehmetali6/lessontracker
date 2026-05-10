# Audit Metrics
**Date:** 2026-05-10
**Codebase:** lesson_tracker (Flutter)

## File Counts by Type
| Type | Count | Notes |
|------|-------|-------|
| Dart files (lib/) | 183 | 7 generated (freezed, l10n) |
| Dart source files (human-written) | 176 | — |
| Unit / widget test files | 16 | — |
| Integration test files | 1 | `integration_test/app_test.dart` |
| CI/CD workflow files | 0 | — |
| Native iOS config files | 2 | `Info.plist`, `Podfile` |
| Native Android config files | 2 | `build.gradle.kts`, `AndroidManifest.xml` |

## Size Metrics
| Metric | Value |
|--------|-------|
| Total lines in lib/ | ~56,600 |
| Average lines per source file | ~320 |
| Largest source file | `note_detail_screen.dart` (1,189) |
| Files >500 lines | 6 |
| Files >900 lines | 4 |

## Dependency Metrics
| Metric | Value |
|--------|-------|
| Production dependencies | 46 |
| Dev dependencies | 11 |
| Outdated dependencies | Not computed (static analysis only) |
| Dead dependencies (unused) | 1 (`flutter_background_service`) |

## Test Metrics
| Metric | Value |
|--------|-------|
| Test files | 17 (16 unit/widget + 1 integration) |
| Estimated coverage | Very low (<15% by file count) |
| Mocks framework | `mocktail` (dev dependency) |
| Real Firebase calls in tests | Present (no `firebase_auth` / `cloud_firestore` mocking observed) |

## Code Quality Metrics
| Metric | Value |
|--------|-------|
| `TODO` / `FIXME` / `HACK` count | 1 (`lib/main.dart:275`) |
| `// ignore:` / `// ignore_for_file:` suppressions | 105 |
| `debugPrint` / `print` occurrences | 234+ |
| `setState` occurrences | 200 |
| `RepaintBoundary` occurrences | 0 |
| `Semantics` / `accessibilityLabel` occurrences | 0 |
| `const` constructor opportunities | Hundreds (many widgets lack `const`) |
| Inline lint suppressions in production code | 3 |

## Security Metrics
| Metric | Value |
|--------|-------|
| Hardcoded secrets in repo | Yes (`.env` with 6 Firebase keys) |
| Secure storage usage | Yes (`flutter_secure_storage` for DB key, E2E key, Moodle tokens) |
| Plaintext preference usage | Extensive (50+ `SharedPreferences.getInstance()` calls) |
| SQLCipher encryption | Yes (version 17 schema) |
| Crash reporting integration | 0 |
| Global error boundary | 0 |

## Platform Metrics
| Metric | Value |
|--------|-------|
| iOS minimum deployment target | 16.0 |
| Android minSdk | `flutter.minSdkVersion` (default ~21) |
| Android targetSdk | `flutter.targetSdkVersion` (default ~34) |
| Android release signing | Debug config (insecure) |
| Background modes declared (iOS) | location, fetch, processing |
| Background permissions (Android) | `ACCESS_BACKGROUND_LOCATION`, `FOREGROUND_SERVICE_LOCATION` |

## Accessibility Metrics
| Metric | Value |
|--------|-------|
| TextScaler clamp | 0.8–1.2× (violates WCAG) |
| Semantics labels | 0 |
| Dynamic Type support | Broken (clamped) |
| Color contrast audit | Not performed |
| Touch target audit | Not performed |
