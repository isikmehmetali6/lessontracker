# Mobile Audit Report
**Date:** 2026-05-10
**Codebase:** lesson_tracker
**Framework:** Flutter 3.x (Dart ^3.10.4)
**LOC analyzed:** ~56,600 (lib/)

## 1. Executive Summary
This audit covers the `lesson_tracker` Flutter application, a multimodal course-tracking app with Firebase backend, Moodle integration, and end-to-end encryption. The codebase shows intentional security investment (SQLCipher, E2E encryption, flutter_secure_storage) but is undermined by critical operational and accessibility flaws. The `.env` file containing Firebase API keys is both committed to git and bundled as an app asset. The Android release build is signed with debug credentials, guaranteeing Play Store rejection. There are 234+ `debugPrint` statements logging tokens, cloud paths, and encryption metadata. Zero accessibility labels render the app unusable for screen-reader users, and the text scaler is artificially capped at 1.2×. No CI/CD, no crash reporting, and no global error boundary exist. Architecture is a mixed Provider + StatefulWidget pattern with several god-object services exceeding 900 lines. Immediate action is required on secrets rotation, signing configuration, accessibility, and logging hygiene before any store submission.

## 2. Findings Summary Table
| ID | Severity | Phase | Title | File:Line |
|----|----------|-------|-------|-----------|
| F-01 | CRITICAL | Security | `.env` with Firebase secrets committed to git and bundled as app asset | `pubspec.yaml:134`, `app/.env:1-17` |
| F-02 | CRITICAL | Build/Release | Android release build uses debug signing config | `android/app/build.gradle.kts:38-42` |
| F-03 | CRITICAL | UX/Accessibility | TextScaler clamped to 0.8–1.2× prevents system font scaling | `lib/main.dart:160-161` |
| F-04 | HIGH | Security | 234+ debugPrint statements leak sensitive data to system logs | `lib/` (grep) |
| F-05 | HIGH | Security | Sensitive auth/state flags stored in SharedPreferences plaintext | `lib/providers/auth_provider.dart:57`, `lib/main.dart:194-215` |
| F-06 | HIGH | UX/Accessibility | Zero Semantics widgets or accessibility labels across entire UI | `lib/` (grep) |
| F-07 | HIGH | Build/Release | No crash reporting or global error boundary wired | `lib/main.dart:57-129` |
| F-08 | HIGH | Build/Release | No CI/CD pipeline configuration | N/A — missing |
| F-09 | MEDIUM | Security | open_filex opens files without MIME validation or path sanitization | `lib/providers/course_provider.dart:852`, `lib/screens/moodle/moodle_course_detail_screen.dart:654` |
| F-10 | MEDIUM | Architecture | God-object screens and services exceed 1000 lines | `lib/screens/note_detail/note_detail_screen.dart:1189`, `lib/screens/course_detail/course_detail_screen.dart:1075` |
| F-11 | MEDIUM | Performance | 200 setState calls without const optimization or RepaintBoundary | `lib/` (grep) |
| F-12 | MEDIUM | Security | url_launcher used without URL allowlist on external user-provided links | `lib/providers/course_provider.dart:842-843` |
| F-13 | MEDIUM | Networking | Firebase HTTP calls lack timeout configuration | `lib/core/services/sync_service.dart`, `lib/providers/auth_provider.dart` |
| F-14 | MEDIUM | UX/Accessibility | Hardcoded Turkish strings mixed with ARB localization | `lib/core/services/attendance_automation_service.dart:173-199`, `lib/core/services/notification_service.dart:126-127` |
| F-15 | MEDIUM | Build/Release | iOS Podfile strips CODE_SIGN_IDENTITY for all pods | `ios/Podfile:49` |
| F-16 | LOW | Build/Release | flutter_background_service declared but never used | `pubspec.yaml:81` |
| F-17 | LOW | Code Quality | avoid_print lint rule disabled in analysis_options.yaml | `analysis_options.yaml:24` |
| F-18 | LOW | Code Quality | Production code contains inline lint suppressions | `lib/screens/course_detail/course_detail_screen.dart:925`, `lib/screens/study_timer/study_timer_screen.dart:365` |
| F-19 | LOW | Code Quality | Build artifacts (flutter_*.log) committed to repository | `flutter_01.log` — `flutter_05.log` |
| F-20 | INFO | Security | Firestore security rules correctly scope data to authenticated users | `firestore.rules:6-21` |
| F-21 | INFO | Security | Local database encrypted with SQLCipher using per-device key | `lib/core/database/database_helper.dart:58-74` |

## 3. Detailed Findings

### F-01 — `.env` with Firebase secrets committed to git and bundled as app asset `[CRITICAL]`
- **Location:** `app/pubspec.yaml:130-134`, `app/.env:1-17`
- **What:** The `.env` file containing Firebase API keys, project ID, auth domain, and storage bucket is tracked in git and explicitly listed as an app asset.
- **Why it matters:** API keys are trivial to extract from the app bundle via unzip/strings. More critically, the git history permanently retains these secrets. Even if rotated, history retains them. This is an exploitable information-disclosure flaw and an App Store rejection risk (secrets in binaries).
- **Evidence:**
```yaml
# pubspec.yaml:130-134
assets:
  - assets/images/
  - assets/icons/
  - assets/models/
  - .env
```
```ini
# .env:1-2
FIREBASE_WEB_API_KEY=AIzaSyCyglEW9d8aJvlO9gGi4wNT_e8l4mBoriM
FIREBASE_ANDROID_API_KEY=AIzaSyCMkQjW8-2kDqVgIz-u0fRREIVJmxkM1Y0
```
- **Fix:**
  1. Purge `.env` from git history using `git filter-repo --path .env --invert-paths` (or BFG Repo-Cleaner).
  2. Remove `.env` from `pubspec.yaml` assets.
  3. Rotate all Firebase API keys via Firebase Console.
  4. Load secrets at CI build time using `--dart-define` or a type-safe generator such as `envied`.
  5. Run `git rm --cached .env` and verify `.gitignore` blocks the file.
- **Effort:** L

### F-02 — Android release build uses debug signing config `[CRITICAL]`
- **Location:** `android/app/build.gradle.kts:38-42`
- **What:** The `release` build type points to the debug signing configuration.
- **Why it matters:** Google Play Protect will flag the APK, and the Play Store will reject it because the debug certificate is publicly known and not owned by the developer. This is a guaranteed store-submission blocker.
- **Evidence:**
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
    }
}
```
- **Fix:**
  1. Generate a release keystore and store it in a secret manager (e.g., GitHub Actions secrets).
  2. Configure a `release` signing config in `build.gradle.kts` reading passwords from environment variables.
  3. Never commit the keystore to version control.
- **Effort:** M

### F-03 — TextScaler clamped to 0.8–1.2× prevents system font scaling `[CRITICAL]`
- **Location:** `lib/main.dart:160-161`
- **What:** The app overrides `MediaQuery.textScaler` and clamps the user’s system setting to a maximum of 1.2×.
- **Why it matters:** This violates WCAG 1.4.4 (resize text up to 200%), Apple’s Human Interface Guidelines, and Android accessibility guidelines. Users with low vision cannot read the UI. It is an App Store rejection blocker.
- **Evidence:**
```dart
builder: (context, child) {
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(
        MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
      ),
    ),
    child: child!,
  );
},
```
- **Fix:** Remove the clamp entirely. If layout breakage is a concern, audit individual screens for overflow and fix them with `Expanded`, `FittedBox`, or scrollable layouts. Never override the user's accessibility choice.
- **Effort:** M

### F-04 — 234+ debugPrint statements leak sensitive data to system logs `[HIGH]`
- **Location:** `lib/` (234 occurrences)
- **What:** The codebase is saturated with `debugPrint` calls that log tokens, E2E keys, cloud paths, user emails, and file system paths.
- **Why it matters:** On Android, `debugPrint` output is visible in `logcat` even in release builds to users with ADB access. On iOS, logs are captured in sysdiagnose. PII and encryption metadata are exposed.
- **Evidence:**
```dart
// lib/core/services/e2e_key_service.dart:189
debugPrint('No local E2E key found, loading from cloud...');
// lib/repositories/note_repository.dart:153
debugPrint('Note file uploaded to cloud: $cloudPath');
// lib/core/services/sync_service.dart:61
debugPrint('Retry $attempt/$maxAttempts after ${delay.inSeconds}s: $e');
```
- **Fix:**
  1. Enable `avoid_print: true` in `analysis_options.yaml`.
  2. Replace all `debugPrint` with a conditional logger stripped in release:
     ```dart
     void log(String message, {bool sensitive = false}) {
       if (kDebugMode && !sensitive) debugPrint(message);
     }
     ```
  3. Mark any line containing tokens, paths, or user data as `sensitive: true` so it is suppressed even in debug builds, or delete it.
- **Effort:** M

### F-05 — Sensitive auth/state flags stored in SharedPreferences plaintext `[HIGH]`
- **Location:** `lib/providers/auth_provider.dart:57`, `lib/main.dart:194-215`, `lib/core/services/attendance_automation_service.dart:53`, `lib/core/services/kvkk_consent_service.dart:22-76`
- **What:** Guest authentication status, KVKK consent timestamps, onboarding completion, smart-attendance enablement, and biometric preferences are stored in `SharedPreferences`.
- **Why it matters:** SharedPreferences is unencrypted plaintext on both platforms. On rooted/jailbroken devices, these flags can be tampered with to bypass consent flows or impersonate guest users.
- **Evidence:**
```dart
// lib/providers/auth_provider.dart:57-58
final prefs = await SharedPreferences.getInstance();
if (prefs.getBool(_keyIsGuest) == true) { _isGuest = true; }

// lib/main.dart:194-195
final prefs = await SharedPreferences.getInstance();
final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
```
- **Fix:** Migrate all security-sensitive and privacy-critical flags to `flutter_secure_storage` with `encryptedSharedPreferences: true`. Keep only UI-trivial flags (e.g., theme mode) in SharedPreferences.
- **Effort:** M

### F-06 — Zero Semantics widgets or accessibility labels across entire UI `[HIGH]`
- **Location:** `lib/` (0 occurrences)
- **What:** A grep for `Semantics(`, `accessibilityLabel`, or `contentDescription` returned zero matches across 183 Dart files.
- **Why it matters:** Screen readers (TalkBack, VoiceOver) cannot describe any interactive element. The app is unusable for blind or low-vision users. Apple and Google increasingly reject apps that fail accessibility audits.
- **Evidence:**
```bash
$ grep -r "Semantics(\|accessibilityLabel\|contentDescription" lib/
# No output
```
- **Fix:**
  1. Wrap every interactive widget (`IconButton`, `GestureDetector`, `InkWell`, custom cards) with `Semantics(label: '...', button: true, child: ...)`.
  2. Add `tooltip` to `IconButton`s as a quick win (Flutter automatically creates a semantics label from tooltip).
  3. Run `flutter build ios` and audit with Xcode Accessibility Inspector / Android Accessibility Scanner.
- **Effort:** L

### F-07 — No crash reporting or global error boundary wired `[HIGH]`
- **Location:** `lib/main.dart:57-129`
- **What:** `main()` runs the app without registering `FlutterError.onError`, `PlatformDispatcher.instance.onError`, or a custom `ErrorWidget.builder`.
- **Why it matters:** Every unhandled exception in widget builds, async gaps, or isolate errors will crash the app silently in production. No stack traces or breadcrumbs are collected. Debugging production issues is impossible.
- **Evidence:**
```dart
// lib/main.dart:112-129
runApp(
  MultiProvider(
    providers: [ ... ],
    child: const LessonTrackerApp(),
  ),
);
```
No `FlutterError.onError = ...` or `ErrorWidget.builder = ...` anywhere.
- **Fix:**
  1. Add `firebase_crashlytics` to `pubspec.yaml`.
  2. In `main.dart`:
     ```dart
     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
     PlatformDispatcher.instance.onError = (error, stack) {
       FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
       return true;
     };
     ```
  3. Scrub PII from Crashlytics logs before sending (emails, file paths).
- **Effort:** S

### F-08 — No CI/CD pipeline configuration `[HIGH]`
- **Location:** N/A — missing
- **What:** No `.github/workflows`, `.gitlab-ci.yml`, `bitrise.yml`, or `fastlane/` directory exists.
- **Why it matters:** Every release is a manual build. No automated lint, test, or signing gates. Risk of shipping unsigned/debug builds, untested code, or leaked secrets to production.
- **Evidence:**
```bash
$ find . -type f \( -name ".github" -o -name ".gitlab-ci.yml" -o -name "bitrise.yml" -o -name "fastlane" \)
# No output
```
- **Fix:**
  1. Add `.github/workflows/ci.yml` running `flutter analyze`, `flutter test`, and `flutter build apk/ios`.
  2. Add a separate release workflow that signs with GitHub secrets and uploads to Play Store / App Store Connect via `fastlane`.
  3. Gate PRs on CI green status.
- **Effort:** M

### F-09 — open_filex opens files without MIME validation or path sanitization `[MEDIUM]`
- **Location:** `lib/providers/course_provider.dart:852`, `lib/screens/moodle/moodle_course_detail_screen.dart:654`
- **What:** `OpenFilex.open(resolvedPath)` and `OpenFilex.open(_localPath!)` are called without verifying the file extension or MIME type.
- **Why it matters:** If a malicious Moodle server returns a filename containing executable content (e.g., `.apk`, `.exe` disguised as `.pdf`), the OS may execute it. Path traversal (`../`) in Moodle filenames could write/read outside the app sandbox.
- **Evidence:**
```dart
// lib/providers/course_provider.dart:851-852
if (resolvedPath != null) {
  await OpenFilex.open(resolvedPath);
}

// lib/screens/moodle/moodle_course_detail_screen.dart:652-654
if (_isDownloaded && _localPath != null) {
  OpenFilex.open(_localPath!);
}
```
- **Fix:**
  1. Validate file extensions against an allowlist before opening:
     ```dart
     final allowedExts = {'.pdf', '.png', '.jpg', '.jpeg', '.mp3', '.m4a'};
     if (!allowedExts.contains(path.extension(resolvedPath))) {
       throw Exception('Unsupported file type');
     }
     ```
  2. Sanitize `fileName` from Moodle API: strip `..`, `/`, `\`.
  3. Prefer `open_filex` with explicit `type` parameter derived from MIME type detection.
- **Effort:** S

### F-10 — God-object screens and services exceed 1000 lines `[MEDIUM]`
- **Location:** `lib/screens/note_detail/note_detail_screen.dart` (1189), `lib/screens/course_detail/course_detail_screen.dart` (1075), `lib/core/services/sync_service.dart` (971), `lib/providers/course_provider.dart` (945)
- **What:** Multiple files far exceed the 500-line threshold, mixing UI, business logic, and data orchestration.
- **Why it matters:** Impossible to unit test in isolation. Merge conflicts compound. New developers cannot reason about side effects. The `sync_service.dart` alone handles encryption, Firestore batching, file uploads, and pending-change reconciliation.
- **Evidence:**
```bash
$ wc -l lib/screens/note_detail/note_detail_screen.dart
1189
$ wc -l lib/core/services/sync_service.dart
971
```
- **Fix:**
  1. Extract widgets from screens into standalone files (e.g., `_buildSliverAppBar` → `NoteDetailAppBar`).
  2. Split `SyncService` into `CloudBackupService`, `EncryptionService`, `PendingChangeProcessor`, and `BatchUploadService`.
  3. Enforce a 300-line soft limit via custom lint or CODEOWNERS.
- **Effort:** L

### F-11 — 200 setState calls without const optimization or RepaintBoundary `[MEDIUM]`
- **Location:** `lib/` (200 occurrences)
- **What:** `setState` is used extensively in large StatefulWidgets. There is zero use of `RepaintBoundary` around expensive subtrees like PDF viewers, charts, or handwriting canvases.
- **Why it matters:** Every `setState` rebuilds the entire widget subtree. Without `RepaintBoundary`, rasterization of complex canvases is replayed on every frame, causing jank on mid-range devices.
- **Evidence:**
```dart
// lib/screens/handwriting_canvas_screen.dart:477
setState(() => _currentPageStrokes = newStrokes);

// lib/screens/course_detail/course_detail_screen.dart:82
setState(() => _isLoadingGrades = true);
```
And `grep -r "RepaintBoundary" lib/` returns no results.
- **Fix:**
  1. Wrap `PdfDocument.openFile` widget and `CustomPainter` canvases with `RepaintBoundary()`.
  2. Replace local `setState` in large screens with `ValueNotifier` + `ValueListenableBuilder` for localized rebuilds.
  3. Add `const` constructors to all immutable widget subtrees.
- **Effort:** M

### F-12 — url_launcher used without URL allowlist on external user-provided links `[MEDIUM]`
- **Location:** `lib/providers/course_provider.dart:842-843`
- **What:** `launchUrl(uri, mode: LaunchMode.externalApplication)` is called on URLs from user input or Moodle APIs without validation.
- **Why it matters:** An attacker controlling a Moodle URL module or a professor's contact URL could open `tel:`, `sms:`, or malicious deep-link schemes.
- **Evidence:**
```dart
// lib/providers/course_provider.dart:840-843
final uri = Uri.tryParse(urlStr);
if (uri != null) {
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
```
- **Fix:**
  1. Whitelist schemes: `if (!['http', 'https'].contains(uri.scheme)) return;`
  2. For professor contact links, validate host against known university domains.
  3. Use `launchUrl` with `LaunchMode.inAppWebView` only for trusted domains; external browser for all others.
- **Effort:** S

### F-13 — Firebase HTTP calls lack timeout configuration `[MEDIUM]`
- **Location:** `lib/core/services/sync_service.dart`, `lib/providers/auth_provider.dart:160-256`
- **What:** Firestore reads/writes, Firebase Auth calls, and Storage uploads use default SDK timeouts (often 30–60s) with no application-level timeout or cancellation.
- **Why it matters:** On flaky networks, async operations hang indefinitely, blocking UI or background tasks. `SyncProvider` may appear frozen.
- **Evidence:**
```dart
// lib/providers/auth_provider.dart:171
await _auth!.signInWithEmailAndPassword(email: email, password: password);
// No timeout, no .timeout(Duration(...))
```
- **Fix:**
  1. Wrap all Firebase calls in `Future.any([operation, Future.delayed(timeout)])` or use a `CancelToken` pattern.
  2. For background sync, cap total execution time with a `Zone` timeout.
  3. Surface timeout errors in the UI with a retry action.
- **Effort:** M

### F-14 — Hardcoded Turkish strings mixed with ARB localization `[MEDIUM]`
- **Location:** `lib/core/services/attendance_automation_service.dart:173-199`, `lib/core/services/notification_service.dart:126-127`, `lib/core/services/notification_service.dart:218-220`, `lib/core/services/notification_service.dart:258-276`
- **What:** Notification titles, bodies, and service-layer error messages are hardcoded in Turkish while the app supports EN/TR/DE/ES via ARB.
- **Why it matters:** Non-Turkish users receive Turkish push notifications and background service toasts. Violates the app's stated multilingual goals.
- **Evidence:**
```dart
// lib/core/services/attendance_automation_service.dart:173-176
title: 'Yoklama Onaylandı ✔️',
body: '$courseName dersi için okulda olduğunuz tespit edildi. '
    'Devamsızlık girilmedi. ...'

// lib/core/services/notification_service.dart:126-127
title: 'Upcoming Class: $courseName',
body: 'Starts in $timeText${location != null ? ' at $location' : ''}',
```
- **Fix:**
  1. Move all service-layer strings to ARB files with fallback.
  2. For background notifications where `BuildContext` is unavailable, pre-load localized strings via `AppLocalizations` or store them in `SharedPreferences` on locale change.
- **Effort:** M

### F-15 — iOS Podfile strips CODE_SIGN_IDENTITY for all pods `[MEDIUM]`
- **Location:** `app/ios/Podfile:48-50`
- **What:** `post_install` sets `CODE_SIGN_IDENTITY = ''` for every CocoaPods target.
- **Why it matters:** While this may work for simulator builds, it can cause App Store submission failures ("Code signing is required") or Enterprise distribution issues. Xcode 15+ may reject pods with no signing identity.
- **Evidence:**
```ruby
installer.pods_project.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_IDENTITY'] = ''
end
```
- **Fix:**
  1. Remove the global `CODE_SIGN_IDENTITY = ''` line.
  2. If needed for local development, gate it behind an environment variable:
     ```ruby
     if ENV['DISABLE_CODE_SIGNING'] == '1'
       config.build_settings['CODE_SIGN_IDENTITY'] = ''
     end
     ```
- **Effort:** S

### F-16 — flutter_background_service declared but never used `[LOW]`
- **Location:** `app/pubspec.yaml:81`
- **What:** `flutter_background_service: ^5.1.0` is in dependencies but grep finds zero imports/usages.
- **Why it matters:** Dead dependency increases APK/IPA size and attack surface. The package requires extra Android manifest entries and notification permissions that confuse maintainers.
- **Evidence:**
```yaml
# pubspec.yaml:81
flutter_background_service: ^5.1.0
```
```bash
$ grep -r "flutter_background_service\|FlutterBackgroundService" lib/
# No output
```
- **Fix:** Remove the dependency from `pubspec.yaml` and run `flutter pub get`.
- **Effort:** XS

### F-17 — avoid_print lint rule disabled in analysis_options.yaml `[LOW]`
- **Location:** `app/analysis_options.yaml:24`
- **What:** The `avoid_print` rule is explicitly commented out.
- **Why it matters:** Permits developers to leave `print` in production code, contributing to the 234 logging findings.
- **Evidence:**
```yaml
# analysis_options.yaml:24
# avoid_print: false  # Uncomment to disable the `avoid_print` rule
```
- **Fix:** Uncomment and set to `true`, or remove the comment so the default (enabled) from `flutter_lints` takes effect.
```yaml
linter:
  rules:
    avoid_print: true
```
- **Effort:** XS

### F-18 — Production code contains inline lint suppressions `[LOW]`
- **Location:** `lib/screens/course_detail/course_detail_screen.dart:925`, `lib/screens/study_timer/study_timer_screen.dart:365`
- **What:** `// ignore: use_build_context_synchronously` and `// ignore: deprecated_member_use` suppress real issues.
- **Why it matters:** Using `BuildContext` across async gaps without mounted checks causes `Looking up a deactivated widget's ancestor` crashes.
- **Evidence:**
```dart
// lib/screens/course_detail/course_detail_screen.dart:925-928
// ignore: use_build_context_synchronously
if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```
- **Fix:** Remove the `// ignore:` and properly guard with `if (!mounted) return;` immediately after the `await`.
- **Effort:** S

### F-19 — Build artifacts (flutter_*.log) committed to repository `[LOW]`
- **Location:** `flutter_01.log` — `flutter_05.log` (project root)
- **What:** Five Flutter build logs totaling ~17 KB are tracked in git.
- **Why it matters:** Repository bloat. These files may contain local paths, environment details, or temporary error messages.
- **Evidence:**
```bash
$ ls flutter_*.log
flutter_01.log flutter_02.log flutter_03.log flutter_04.log flutter_05.log
```
- **Fix:** `git rm flutter_*.log && echo "*.log" >> .gitignore && git commit -m "Remove build logs"`
- **Effort:** XS

### F-20 — Firestore security rules correctly scope data to authenticated users `[INFO]`
- **Location:** `app/firestore.rules:6-21`
- **What:** Rules enforce `request.auth.uid` matches document `userId`.
- **Why it matters:** Prevents horizontal privilege escalation between users.
- **Evidence:**
```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```
- **Fix:** None. Maintain these rules and add unit tests with the Firestore rules emulator.
- **Effort:** N/A

### F-21 — Local database encrypted with SQLCipher using per-device key `[INFO]`
- **Location:** `lib/core/database/database_helper.dart:58-74`
- **What:** Database uses `sqflite_sqlcipher` with a 32-byte key stored in `flutter_secure_storage`.
- **Why it matters:** Protects local data at rest if the device is lost or forensically examined.
- **Evidence:**
```dart
String? encryptionKey = await _secureStorage.read(key: _keyDbEncryptionKey);
if (encryptionKey == null) {
  final key = encrypt.Key.fromSecureRandom(32);
  await _secureStorage.write(key: _keyDbEncryptionKey, value: key.base64);
  encryptionKey = key.base64;
}
return await sqlcipher.openDatabase(path, version: 17, password: encryptionKey, ...);
```
- **Fix:** None. Consider adding a key-rotation policy for long-lived installs.
- **Effort:** N/A

## 4. Architecture Assessment
The app follows a Provider-based layered architecture with `models`, `providers`, `repositories`, `services`, and `screens`. This is coherent at a high level. The use of `ChangeNotifierProvider` at the root (`main.dart:113-129`) creates a global service locator pattern where every provider is alive for the app's lifetime. This is acceptable for a small app but will break as the app grows: all providers consume memory even when their features are not on screen, and `notifyListeners()` on heavy providers like `SyncProvider` or `CourseProvider` can trigger rebuilds of the entire widget tree if not carefully scoped.

The repository pattern is present but leaky: `AuthProvider` directly imports `DatabaseHelper` and `Firestore` (line 7, 14, 176-182), violating Clean Architecture's dependency rule. `SyncService` is a 971-line god object that orchestrates encryption, batching, file uploads, and pending-change reconciliation. It should be decomposed.

State management is inconsistent: large StatefulWidgets (`note_detail_screen.dart`, `handwriting_canvas_screen.dart`) mix UI with local business logic via `setState`, while global state lives in Providers. There is no middle layer (e.g., ViewModels or BLoCs) to bridge the two. This makes testing difficult: widget tests must mount entire screens to test logic.

The networking layer is split between Firebase SDK (no timeout) and a custom `http` client for Moodle (30s timeout). There is no central HTTP client configuration, no interceptor for auth tokens, and no retry logic for Firebase calls.

Data layer is a mixed bag: local DB uses SQLCipher (good), but `SharedPreferences` is overused for sensitive flags (bad). Cloud backup uses a custom AES-CBC encryption with per-device keys stored in secure storage (good), but the IV is also stored in secure storage alongside the key, which reduces the separation of concerns slightly.

Overall: The architecture works for the current feature set, but it will not scale. The lack of dependency injection, the oversized service classes, and the absence of feature-level state scoping will cause exponential complexity as new features are added.

## 5. Top 10 Prioritized Actions (do these first, in order)
1. **Rotate Firebase secrets and purge `.env` from git history** (F-01). This is an active security breach.
2. **Fix Android release signing to use a production keystore** (F-02). Without this, Play Store submission is impossible.
3. **Remove the TextScaler clamp to respect system accessibility settings** (F-03). App Store rejection risk.
4. **Wire Firebase Crashlytics and global error boundaries** (F-07). You cannot ship without knowing what crashes in production.
5. **Strip or gate all 234 debugPrint statements, especially those logging PII** (F-04). Reduces attack surface and log noise.
6. **Migrate sensitive flags from SharedPreferences to flutter_secure_storage** (F-05). Prevents trivial tampering on rooted devices.
7. **Add CI/CD pipeline with lint, test, and build gates** (F-08). Prevents shipping debug builds or breaking changes.
8. **Add Semantics labels to all interactive widgets** (F-06). Required for accessibility compliance and store acceptance.
9. **Decompose SyncService and oversized screens into testable units** (F-10). Unblocks unit testing and reduces merge conflicts.
10. **Add timeouts and cancellation to all Firebase network calls** (F-13). Prevents hung UI on flaky networks.

## 6. What Was NOT Audited
- The actual Firebase project configuration (API key restrictions, authorized domains, App Check).
- Backend Cloud Functions source code (only `EMAIL_CLOUD_FUNCTIONS.md` was present; no source reviewed).
- Moodle server configurations or TLS certificate validity.
- Native iOS/Android code beyond `Info.plist`, `AndroidManifest.xml`, and `build.gradle.kts`.
- Third-party dependency source code (only pubspec versions were checked).
- Runtime performance profiling (no build or execution was performed).
- The `.env` file may have additional secrets in the parent directory `.env` (not audited in depth).
- Binary asset files (images, fonts) for malware or copyright issues.
- App Store / Play Store listing metadata, privacy policy, or KVKK compliance documentation.
