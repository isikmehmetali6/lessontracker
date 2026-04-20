# E2E Encryption Implementation Documentation

## Overview

This document describes the End-to-End (E2E) encryption implementation for the Lesson Tracker app. E2E encryption ensures that user files (photos, audio recordings, documents) are encrypted on the device before being uploaded to Firebase Storage. Only the user can decrypt their files - not even the app owner.

## Architecture

### Key Components

```
┌─────────────────────────────────────────────────────────────────┐
│                      USER'S DEVICE                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    │
│  │ E2EKeyService│    │E2ECryptoSvc  │    │E2EFileService│    │
│  │              │───▶│  (AES-256)   │◀───│              │    │
│  └──────────────┘    └──────────────┘    └──────────────┘    │
│         │                                       │              │
│         ▼                                       ▼              │
│  ┌──────────────┐                      ┌──────────────┐       │
│  │flutter_secure│                      │   Firebase   │       │
│  │  _storage    │                      │   Storage    │       │
│  │  (Keychain)  │                      │  (Cloud)     │       │
│  └──────────────┘                      └──────────────┘       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Encryption Flow

1. User signs up → Device generates random 256-bit KEY
2. KEY is encrypted with user's password-derived key (PBKDF2)
3. Encrypted KEY stored in Firebase Firestore (`users/{uid}/system/e2e_key`)
4. Plain KEY stored in device Keychain (flutter_secure_storage)
5. When uploading files:
   - File is encrypted with the 256-bit KEY (AES-256-CBC)
   - Encrypted file uploaded to Firebase Storage
   - Cloud path saved to Firestore metadata

## New Files Created

### 1. lib/core/services/e2e_crypto_service.dart

AES-256-CBC encryption service.

**Features:**
- `deriveKey(password, salt)` - PBKDF2 key derivation (100,000 iterations)
- `generateKey()` - Generate random 256-bit key
- `generateSalt()` - Generate random 16-byte salt
- `encryptFile(data, key)` - Encrypt data with IV prepended
- `decryptFile(encryptedData, key)` - Decrypt and verify

**Storage Format:**
```
┌─────────────────────┬─────────────────────────────┐
│    IV (16 bytes)    │    Encrypted Data           │
└─────────────────────┴─────────────────────────────┘
```

### 2. lib/core/services/e2e_key_service.dart

KEY lifecycle management.

**Features:**
- `initializeUserKey(password)` - Create new KEY on signup
- `loadKeyFromCloud(password)` - Download and decrypt KEY on new device
- `getLocalKey()` - Get KEY from Keychain (cached)
- `storeKeyLocally(key)` - Save KEY to Keychain
- `changePassword(old, new)` - Re-encrypt KEY with new password
- `deleteKey()` - Remove KEY from cloud and local

**Firebase Structure:**
```
users/{uid}/system/e2e_key/
├── encryptedKey: base64(encrypted KEY)
├── salt: base64(salt)
├── createdAt: timestamp
├── keyVersion: 1
└── lastKeyChange: timestamp
```

### 3. lib/core/services/e2e_file_service.dart

File upload/download with E2E encryption.

**Features:**
- `uploadPhoto(file)` - Upload image with compression
- `uploadAudio(file)` - Upload audio recording
- `uploadDocument(file)` - Upload PDF/document
- `downloadPhoto(cloudPath)` - Download and decrypt photo
- `downloadFile(cloudPath)` - Download and decrypt any file
- `deleteFile(cloudPath)` - Delete from Firebase Storage

**Cloud Path Format:**
```
users/{uid}/photos/{fileId}.enc
users/{uid}/audio/{fileId}.enc
users/{uid}/documents/{fileId}.enc
```

### 4. lib/core/services/e2e_migration_service.dart

Background migration for existing users.

**Features:**
- `migrateLegacyFiles()` - Migrate all legacy files to E2E
- `isMigrationNeeded()` - Check if user has unmigrated files
- Progress reporting via `onProgress` callback

### 5. lib/core/services/biometric_service.dart

FaceID/TouchID integration.

**Features:**
- `isAvailable()` - Check if device supports biometrics
- `authenticate()` - Trigger biometric prompt
- `getAvailableBiometrics()` - List available biometric types

### 6. lib/core/services/image_compressor_service.dart

Image compression before upload.

**Settings:**
- Quality: 80%
- Max dimensions: 1920x1080
- Format: JPEG
- Compression threshold: 5MB

## Updated Files

### pubspec.yaml

Added dependencies:
- `flutter_image_compress: ^2.3.0` - Image compression
- `crypto: ^3.0.6` - PBKDF2 implementation

### lib/core/database/database_helper.dart

**Version Bump:** 16 → 17

**New Migration:**
```sql
CREATE TABLE e2e_metadata (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_key_salt TEXT,
  encrypted_key TEXT,
  security_questions_hash TEXT,
  created_at TEXT NOT NULL,
  key_version INTEGER DEFAULT 1,
  last_key_change TEXT
);

ALTER TABLE notes ADD COLUMN cloud_path TEXT;
ALTER TABLE notes ADD COLUMN thumbnail_cloud_path TEXT;
ALTER TABLE course_files ADD COLUMN cloud_path TEXT;
```

### lib/models/course_file.dart

Added field:
```dart
String? cloudPath;
```

### lib/providers/auth_provider.dart

**Signup Flow:**
1. Firebase Auth account created
2. User document created in Firestore
3. E2E KEY initialized via `E2EKeyService().initializeUserKey(password)`

**Signin Flow:**
1. Firebase Auth login
2. If no local KEY exists → load from cloud via `loadKeyFromCloud(password)`
3. Trigger background migration if needed

### lib/repositories/note_repository.dart

**New Methods:**
- `insertNoteWithFile(note, attachedFile, thumbnail)` - Insert note with E2E upload
- `downloadNoteFile(cloudPath)` - Download and decrypt file
- `deleteNoteWithFiles(id)` - Delete note and cloud files

### lib/repositories/file_repository.dart

**New Methods:**
- `insertFileWithUpload(file, localFile)` - Insert course file with E2E upload
- `downloadFile(cloudPath)` - Download and decrypt file
- `deleteFileWithCloud(id)` - Delete file and cloud copy

### lib/core/services/sync_service.dart

**Backup Flow (Updated):**
- Notes: E2E files uploaded before metadata backup
- Course files: E2E files uploaded before metadata backup
- `cloudPath` stored in Firestore metadata

**Helper Methods Added:**
- `_uploadNoteFileE2E(file, noteId, e2eService)`
- `_uploadNoteThumbnailE2E(file, thumbId, e2eService)`
- `_uploadCourseFileE2E(file, courseId, fileId, fileType, e2eService)`

## Database Schema (v17)

### e2e_metadata
```sql
CREATE TABLE e2e_metadata (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_key_salt TEXT,
  encrypted_key TEXT,
  security_questions_hash TEXT,
  created_at TEXT NOT NULL,
  key_version INTEGER DEFAULT 1,
  last_key_change TEXT
);
```

### notes (updated)
```sql
ALTER TABLE notes ADD COLUMN cloud_path TEXT;
ALTER TABLE notes ADD COLUMN thumbnail_cloud_path TEXT;
```

### course_files (updated)
```sql
ALTER TABLE course_files ADD COLUMN cloud_path TEXT;
```

## Security Considerations

### Key Storage
- **Local:** flutter_secure_storage (iOS Keychain / Android EncryptedSharedPreferences)
- **Cloud:** Password-derived key encrypted with PBKDF2

### Key Derivation
- Algorithm: PBKDF2
- Iterations: 100,000
- Hash: SHA-256
- Salt: 16 bytes random per user

### File Encryption
- Algorithm: AES-256-CBC
- IV: 16 bytes random per file
- Format: IV || Encrypted Data

### Password Requirements
- Minimum 6 characters (Firebase Auth requirement)
- Key derivation uses password + unique salt
- Password change requires re-encryption of KEY

## Migration Strategy

### For New Users
1. Sign up → KEY generated automatically
2. Files encrypted and uploaded on first use

### For Existing Users
1. Sign in → System detects legacy (unencrypted) files
2. Background migration starts automatically
3. Progress shown to user
4. Files re-uploaded as E2E encrypted

### Migration Check
```dart
if (await E2EKeyService().isE2EEnabled()) {
  final needsMigration = await E2EMigrationService().isMigrationNeeded();
  if (needsMigration) {
    E2EMigrationService().migrateLegacyFiles();
  }
}
```

## Usage Examples

### Upload a Note with Photo
```dart
final note = Note(id: '123', ...);
final photo = File('/path/to/photo.jpg');

await noteRepository.insertNoteWithFile(note, attachedFile: photo);
```

### Download Encrypted File
```dart
final bytes = await noteRepository.downloadNoteFile('users/uid/photos/abc.enc');
if (bytes != null) {
  // Display image
}
```

### Change Password
```dart
await E2EKeyService().changePassword(oldPassword, newPassword);
```

## Dependencies

```yaml
dependencies:
  flutter_secure_storage: ^10.0.0  # Already existed
  encrypt: ^5.0.3                  # Already existed
  flutter_image_compress: ^2.3.0    # Added
  crypto: ^3.0.6                    # Added
  local_auth: ^2.3.0               # Already existed (biometric)
```

## Rollback Plan

If issues occur:

1. **Feature Flag:** Set `e2e_enabled` to `false` in secure storage
2. **Database:** Version 17 → 16 downgrade (remove new columns)
3. **Services:** Disable E2E services, use existing sync logic
4. **Data:** Local files remain, cloud files inaccessible (can be deleted manually)

## Completed UI Features

### Password Recovery Screen
**File:** `lib/screens/auth/password_recovery_screen.dart`

Features:
- Email verification step
- Security questions verification step
- New password setup step
- Firebase Auth password reset integration

### Settings E2E Section
**File:** `lib/screens/settings/widgets/settings_e2e_section.dart`

Features:
- E2E encryption status indicator (Active/Inactive badge)
- Biometric toggle (FaceID/TouchID)
- Security questions setup
- Migration progress UI with progress bar

### Password Change Integration
**File:** `lib/screens/settings/widgets/settings_profile_section.dart`

Updated:
- `_changePassword()` method now also re-encrypts E2E key when password changes

## Files Modified/Created Summary

| File | Type | Description |
|------|------|-------------|
| `lib/core/services/e2e_crypto_service.dart` | **NEW** | AES-256 encryption |
| `lib/core/services/e2e_key_service.dart` | **NEW** | KEY management |
| `lib/core/services/e2e_file_service.dart` | **NEW** | File upload/download |
| `lib/core/services/e2e_migration_service.dart` | **NEW** | Legacy migration |
| `lib/core/services/biometric_service.dart` | **NEW** | FaceID/TouchID |
| `lib/core/services/image_compressor_service.dart` | **NEW** | Image compression |
| `lib/core/database/database_helper.dart` | **MODIFIED** | v17 migration |
| `lib/models/course_file.dart` | **MODIFIED** | Added cloudPath |
| `lib/providers/auth_provider.dart` | **MODIFIED** | E2E init on auth |
| `lib/repositories/note_repository.dart` | **MODIFIED** | E2E upload methods |
| `lib/repositories/file_repository.dart` | **MODIFIED** | E2E upload methods |
| `lib/core/services/sync_service.dart` | **MODIFIED** | E2E backup |
| `lib/screens/auth/password_recovery_screen.dart` | **NEW** | Password recovery with security questions |
| `lib/screens/settings/widgets/settings_e2e_section.dart` | **NEW** | E2E settings UI |
| `lib/screens/settings/settings_screen.dart` | **MODIFIED** | Added E2E section |
| `lib/screens/settings/widgets/settings_profile_section.dart` | **MODIFIED** | E2E key re-encryption on password change |
| `lib/screens/auth/login_screen.dart` | **MODIFIED** | Navigate to password recovery |
| `pubspec.yaml` | **MODIFIED** | New dependencies |

---

# Firebase Setup Guide

This guide covers all Firebase configuration steps required to enable E2E encryption and cloud backup features.

## Prerequisites

- Firebase account (free tier sufficient for development)
- Flutter SDK installed
- Android Studio / Xcode for platform builds

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `lesson-tracker`
4. Disable Google Analytics (optional) or enable - click Create
5. Wait for project creation to complete

## Step 2: Enable Firebase Services

### Authentication
1. In Firebase Console → **Authentication** → **Get started**
2. Enable **Email/Password** provider:
   - Click "Email/Password"
   - Toggle "Enable" to ON
   - Click Save

### Firestore Database
1. Go to **Firestore Database** → **Create database**
2. Choose location closest to your users
3. Start in **test mode** (for development)
4. Click Enable

### Storage
1. Go to **Storage** → **Get started**
2. Start in **test mode** (for development)
3. Choose location
4. Click Done

## Step 3: Register Apps

### Android
1. Go to **Project Settings** → **Add app** → **Android**
2. Enter Android package name: `com.lessontracker.lessonTracker`
3. (Optional) Enter debug signing SHA-1
4. Click Register app

### iOS
1. Go to **Project Settings** → **Add app** → **iOS**
2. Enter iOS bundle ID: `com.lessontracker.lessonTracker`
3. App Store ID: (optional)
4. Click Register app

### Web
1. Go to **Project Settings** → **Add app** → **Web**
2. Enter nickname: `Lesson Tracker Web`
3. Click Register app

## Step 4: Download Configuration Files

### Android
1. Download `google-services.json`
2. Place in: `app/android/app/google-services.json`

### iOS
1. Download `GoogleService-Info.plist`
2. Place in: `app/ios/Runner/GoogleService-Info.plist`
3. In Xcode: Right-click Runner → **Add files to "Runner"** → select the plist

### Web
1. Copy the `firebaseConfig` object values from the console
2. These will go into your `.env` file (see Step 5)

## Step 5: Configure Environment Variables

Create `app/.env` file with values from Firebase Console:

```env
# Web
FIREBASE_WEB_API_KEY=your_web_api_key
FIREBASE_WEB_APP_ID=your_web_app_id
FIREBASE_WEB_MEASUREMENT_ID=your_measurement_id

# Android
FIREBASE_ANDROID_API_KEY=your_android_api_key
FIREBASE_ANDROID_APP_ID=your_android_app_id

# iOS
FIREBASE_IOS_API_KEY=your_ios_api_key
FIREBASE_IOS_APP_ID=your_ios_app_id

# macOS
FIREBASE_MACOS_API_KEY=your_macos_api_key
FIREBASE_MACOS_APP_ID=your_macos_app_id

# Shared
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=lesson-tracker
FIREBASE_STORAGE_BUCKET=lesson-tracker.appspot.com
FIREBASE_AUTH_DOMAIN=lesson-tracker.firebaseapp.com
```

### Finding these values:

1. Go to **Project Settings** → **General** → **Your apps** → **Web** (or Android/iOS)
2. Copy the config values

## Step 6: Set Firestore Security Rules

### Production Rules

Go to **Firestore Database** → **Rules** and replace with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // User document and subcollections
    match /users/{userId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
      
      // System subcollection (e2e_key, security_questions)
      match /system/{document=**} {
        allow read, write: if isOwner(userId);
      }
      
      // User data subcollections
      match /{collection=**} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

## Step 7: Set Storage Security Rules

Go to **Storage** → **Rules** and replace with:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // User files
    match /users/{userId}/{allPaths=**} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
  }
}
```

## Step 8: Enable App Check (Optional but Recommended)

1. Go to **App Check** → **Get started**
2. For development, you can skip this
3. For production, register **reCAPTCHA** for web, **Play Integrity** for Android

## Step 9: Android-Specific Setup

### SHA-1 Fingerprint (for Auth)

If using Firebase Auth with Android:

1. Open terminal in `app/android/`
2. Run:
   ```bash
   ./gradlew signingReport
   ```
3. Copy the SHA-1 from `release` variant
4. Go to Firebase Console → **Project Settings** → **Your apps** → **Android** → **Add fingerprint**
5. Paste SHA-1 and save

### ProGuard Rules

Add to `app/android/app/proguard-rules.pro`:

```proguard
# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter Secure Storage
-keep class io.flutter_secure_storage.** { *; }

# Encrypt package
-keep class encrypt.** { *; }
```

## Step 10: iOS-Specific Setup

### In Xcode:

1. Open `app/ios/Runner.xcworkspace`
2. Select Runner → **Signing & Capabilities**
3. Enable **Push Notifications** (for FCM)
4. Set Team and Provisioning Profile

### Info.plist additions:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Use Face ID to unlock the app</string>
```

## Step 11: Verify Configuration

### Test Authentication
1. Run the app
2. Try signing up with email/password
3. Check Firebase Console → **Authentication** → **Users** to verify

### Test Firestore
1. Sign in to the app
2. Create a course
3. Check Firebase Console → **Firestore** → **Users/{uid}/courses**

### Test Storage
1. Sign in to the app
2. Add a note with a photo
3. Check Firebase Console → **Storage** → **users/{uid}/**

## Troubleshooting

### "DefaultFirebaseOptions have not been configured"
- Ensure `.env` file exists in `app/` directory
- Ensure all environment variables are set
- Run `flutter clean` and rebuild

### "Firebase Auth not available"
- Check that Email/Password provider is enabled in Firebase Console
- Verify the correct `google-services.json` / `GoogleService-Info.plist` is in place

### "Permission denied" errors
- Check Firestore and Storage rules
- Ensure user is authenticated before data operations
- Check that `request.auth.uid` matches the document path

### Keychain errors on iOS
- For development, the app may show keychain errors
- Ensure Xcode signing is properly configured
- On simulator, keychain errors can be ignored during development

## Firebase Console Checklist

- [ ] Project created
- [ ] Authentication → Email/Password enabled
- [ ] Firestore database created
- [ ] Storage bucket created
- [ ] Android app registered with SHA-1
- [ ] iOS app registered
- [ ] Web app registered
- [ ] Firestore rules updated
- [ ] Storage rules updated
- [ ] `.env` file created with all credentials

## Environment Variable Reference

| Variable | Description | Where to find |
|----------|-------------|---------------|
| `FIREBASE_WEB_API_KEY` | Web API key | Project Settings → Your apps → Web → Config |
| `FIREBASE_WEB_APP_ID` | Web App ID | Project Settings → Your apps → Web → Config |
| `FIREBASE_WEB_MEASUREMENT_ID` | GA4 Measurement ID (optional) | Project Settings → Your apps → Web → Config |
| `FIREBASE_ANDROID_API_KEY` | Android API key | Project Settings → Your apps → Android → Config |
| `FIREBASE_ANDROID_APP_ID` | Android App ID | Project Settings → Your apps → Android → Config |
| `FIREBASE_IOS_API_KEY` | iOS API key | Project Settings → Your apps → iOS → Config |
| `FIREBASE_IOS_APP_ID` | iOS App ID | Project Settings → Your apps → iOS → Config |
| `FIREBASE_MACOS_API_KEY` | macOS API key | Project Settings → Your apps → macOS → Config |
| `FIREBASE_MACOS_APP_ID` | macOS App ID | Project Settings → Your apps → macOS → Config |
| `FIREBASE_MESSAGING_SENDER_ID` | Cloud Messaging Sender ID | Project Settings → General → Your apps |
| `FIREBASE_PROJECT_ID` | Firebase project ID | Project Settings → General |
| `FIREBASE_STORAGE_BUCKET` | Storage bucket URL | Storage → Settings |
| `FIREBASE_AUTH_DOMAIN` | Auth domain | Project Settings → General → Your apps → Web → Config |

## Production Deployment Notes

Before releasing to production:

1. **Enable App Check** - Protects against abuse
2. **Set up Analytics** - Optional but recommended
3. **Configure Rate Limiting** - Firebase has built-in quotas
4. **Enable 2-factor authentication** in Firebase Auth settings
5. **Review all Security Rules** - Ensure they follow principle of least privilege
6. **Set up Monitoring** - Use Firebase Crashlytics and Performance Monitoring
7. **Configure Billing** - Set up billing alerts for unexpected usage
