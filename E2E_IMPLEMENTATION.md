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
