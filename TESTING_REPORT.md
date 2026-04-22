# 📋 Lesson Tracker - Yayın Öncesi Test Raporu ve Kalite Güvence Dokümanı

> **Hazırlık Tarihi:** 23 Nisan 2026  
> **Uygulama:** Lesson Tracker  
> **Versiyon:** 1.0.0 (Production)  
> **Platform:** Android (iOS hedefleniyor)  

---

## 📑 İçindekiler

1. [Yayın Öncesi Checklist](#1-yayın-öncesi-checklist)
2. [Test Türleri ve Kapsamı](#2-test-türleri-ve-kapsamı)
3. [Fonksiyonel Testler](#3-fonksiyonel-testler)
4. [Güvenlik Testleri](#4-güvenlik-testleri)
5. [Performans Testleri](#5-performans-testleri)
6. [UI/UX Testleri](#6-uiux-testleri)
7. [Platform-Spesifik Testler](#7-platform-spesifik-testler)
8. [Firebase ve Cloud Entegrasyon Testleri](#8-firebase-ve-cloud-entegrasyon-testleri)
9. [Kullanıcı Kabul Kriterleri (UAT)](#9-kullanıcı-kabul-kriterleri-uat)
10. [Risk Matrisi ve Azaltma Stratejileri](#10-risk-matrisi-ve-azaltma-stratejileri)
11. [Pre-Production Checklist](#11-pre-production-checklist)
12. [Post-Release Monitoring Planı](#12-post-release-monitoring-planı)

---

## 1. Yayın Öncesi Checklist

### 🔴 Kritik Öncelik (Release Blocker)

- [ ] **Database Migration Testi:** Mevcut kullanıcı database'inde v14→v17 upgrade testi
- [ ] **E2E Encryption:** Anahtar oluşturma, şifreleme, şifre çözme workflow testi
- [ ] **Firebase Storage:** Dosya upload/download 404 hatası çözümü (bucket permissions)
- [ ] **Exact Alarm Permission:** Android 14+ bildirim izni handle'ı
- [ ] **Note CRUD:** Create, Read, Update, Delete - tüm note türleri için

### 🟡 Yüksek Öncelik

- [ ] **Moodle Entegrasyonu:** Ders senkronizasyonu, assignment, grades
- [ ] **Offline Mode:** Internet olmadan temel fonksiyonların çalışması
- [ ] **Crash Reporting:** Firebase Crashlytics entegrasyonu doğrulaması

### 🟢 Orta Öncelik

- [ ] **Unit Test Coverage:** %70 üzeri coverage hedefi
- [ ] **Beta Tester Feedback:** 5+ beta tester'dan geri bildirim
- [ ] **App Signing:** Production keystore güvenliği

---

## 2. Test Türleri ve Kapsamı

### 2.1 Test Piramidi

```
        /\
       /  \      E2E / Integration Tests (5%)
      /____\     
     /      \    Integration Tests (15%)
    /________\   
   /          \  Unit Tests (70%)
  /____________\
```

| Test Türü | Sayı | Hedef Coverage |
|-----------|------|----------------|
| Unit Tests | 150+ | %70 |
| Widget Tests | 50+ | Kritik ekranlar |
| Integration Tests | 10+ | E2E flows |
| Manual QA | 20+ senaryo | %100 |

---

## 3. Fonksiyonel Testler

### 3.1 Authentication Flow

| Test ID | Test Senaryosu | Status | Not |
|---------|----------------|--------|-----|
| AUTH-01 | Email/password ile kayıt | ⏳ | Firebase Auth enabled |
| AUTH-02 | Email/password ile giriş | ⏳ | |
| AUTH-03 | Guest mode giriş | ⏳ | |
| AUTH-04 | Şifre sıfırlama | ⏳ | SMTP yapılandırması gerekli |
| AUTH-05 | Email verification | ⏳ | Disabled - SMTP bekleniyor |
| AUTH-06 | Session timeout | ⏳ | 30 dakika inactivity |
| AUTH-07 | Logout flow | ⏳ | |

### 3.2 Course Management

| Test ID | Test Senaryosu | Status | Not |
|---------|----------------|--------|-----|
| COURSE-01 | Yeni ders ekleme (manual) | ⏳ | |
| COURSE-02 | Ders düzenleme | ⏳ | |
| COURSE-03 | Ders silme | ⏳ | |
| COURSE-04 | Moodle'dan ders senkron | ⏳ | |
| COURSE-05 | Çakışma kontrolü (schedule conflict) | ⏳ | |
| COURSE-06 | Ders renklendirme | ⏳ | |
| COURSE-07 |上课时间 validasyonu (end > start) | ✅ | |

### 3.3 Note Operations

| Test ID | Test Senaryosu | Status | Not |
|---------|----------------|--------|-----|
| NOTE-01 | Text note oluşturma | ⏳ | |
| NOTE-02 | OCR note (kamera) | ⏳ | ML Kit dependency |
| NOTE-03 | Image note (galeri) | ⏳ | |
| NOTE-04 | Drawing note | ⏳ | |
| NOTE-05 | Note düzenleme | ⏳ | |
| NOTE-06 | Note silme | ⏳ | |
| NOTE-07 | Note arama (title, content, tag, filePath) | ✅ | Enhanced |
| NOTE-08 | Note yer imi | ⏳ | |
| NOTE-09 | Note filtreleme (type, date) | ⏳ | |
| NOTE-10 | Batch image upload | ⏳ | |

### 3.4 Attendance Tracking

| Test ID | Test Senaryosu | Status | Not |
|---------|----------------|--------|-----|
| ATT-01 | Devamsızlık işaretleme | ⏳ | |
| ATT-02 | Devamsızlık limit kontrolü | ⏳ | |
| ATT-03 | Konum bazlı otomatik devamsızlık | ⏳ | Geolocator |
| ATT-04 | Devamsızlık raporu | ⏳ | |

### 3.5 Grade Management

| Test ID | Test Senaryosu | Status | Not |
|---------|----------------|--------|-----|
| GRADE-01 | Sınav notu ekleme | ⏳ | |
| GRADE-02 | Not güncelleme | ⏳ | |
| GRADE-03 | Ağırlıklı GPA hesaplama | ⏳ | |
| GRADE-04 |Transcript export | ⏳ | Future |

### 3.6 Moodle Integration

| Test ID | Test Senaryosu | Status | Not |
|---------|----------------|--------|-----|
| MOODLE-01 | Moodle account bağlama | ⏳ | |
| MOODLE-02 | Dersleri çekme | ⏳ | |
| MOODLE-03 | Assignments senkron | ⏳ | |
| MOODLE-04 | Grades senkron | ⏳ | |
| MOODLE-05 | Announcement çekme | ⏳ | |
| MOODLE-06 | Offline moodle cache | ⏳ | |

---

## 4. Güvenlik Testleri

### 4.1 Authentication & Authorization

- [ ] SQL injection testleri (search input, note content)
- [ ] XSS prevention (note content rendering)
- [ ] Authentication token expiry handling
- [ ] Unauthorized API call prevention
- [ ] Rate limiting testleri (brute force protection)

### 4.2 Data Protection

- [ ] E2E encryption key generation entropy test
- [ ] Encryption/decryption roundtrip test
- [ ] Key storage in SecureStorage (Android Keystore)
- [ ] Sensitive data in logs kontrolü (debugPrint sanitization)
- [ ] Cloud backup encryption verification

### 4.3 Firebase Security

- [ ] Firestore rules validation (read/write permissions)
- [ ] Storage bucket security rules
- [ ] Firebase Auth anonymous user limits
- [ ] Cloud Functions authentication

### 4.4 Privacy & Consent (KVKK/GDPR)

- [ ] Camera permission consent flow
- [ ] Microphone permission consent flow (kaldırıldı)
- [ ] Location permission consent flow
- [ ] Data retention policy implementation
- [ ] User data deletion capability (right to be forgotten)

---

## 5. Performans Testleri

### 5.1 Startup Performance

| Metric | Hedef | Ölçüm Metodu |
|--------|-------|--------------|
| Cold start | < 3s | Flutter devtools timeline |
| Warm start | < 1s | Hot reload benchmark |
| Time to interactive | < 5s | Manual testing |
| APK size | < 30MB | `flutter build apk --split-per-abi` |

### 5.2 Runtime Performance

| Metric | Hedef | Test Senaryosu |
|--------|-------|----------------|
| Frame rate | 60 FPS | Scrolling, animations |
| Memory usage | < 200MB | Course with 100+ notes |
| Database query | < 100ms | Note search, load |
| Image load | < 500ms | OCR processing |

### 5.3 Load Testing

- [ ] 100+ courses load test
- [ ] 1000+ notes database query
- [ ] Concurrent user sync test
- [ ] Large image upload (10MB+)
- [ ] Stress test: Rapid note creation/deletion

### 5.4 Battery Impact

- [ ] Background location service battery drain
- [ ] Idle battery consumption
- [ ] Active use battery consumption

---

## 6. UI/UX Testleri

### 6.1 Responsive Design

| Cihaz | Ekran Boyutu | Test Durumu |
|-------|--------------|-------------|
| Pixel 7 Pro | 412x915 | ⏳ |
| Pixel 6 | 412x915 | ⏳ |
| Samsung S21 | 360x800 | ⏳ |
| iPhone 14 | 390x844 | ⏳ (future) |
| Tablet 10" | 800x1200 | ⏳ (future) |

### 6.2 Theme Testing

- [ ] Light mode render
- [ ] Dark mode render
- [ ] System theme following
- [ ] Color contrast accessibility (WCAG AA)

### 6.3 Accessibility

- [ ] TalkBack/Braille compatibility
- [ ] Minimum touch target 48dp
- [ ] Screen reader labels
- [ ] Reduced motion support

### 6.4 Localization

| Dil | Kapsam | Test Durumu |
|-----|--------|-------------|
| Turkish (TR) | %100 | ✅ |
| English (EN) | %100 | ⏳ |
| Spanish (ES) | %100 | ⏳ |
| German (DE) | %100 | ⏳ |

---

## 7. Platform-Spesifik Testler

### 7.1 Android

| Test | Hedef | Not |
|------|-------|-----|
| APK installation | Android 10-14 | Play Store compatible |
| Permission handling | Runtime permissions | Exact alarm için EXACT_ALARM permission |
| Notification | Android 14 notification channels | |
| Background service | Workmanager | Attendance check task |
| Biometric auth | Fingerprint/Face | Samsung Knox test |
| Camera | ML Kit OCR | Google Lens interference |
| Storage | Scoped storage | Android 11+ |

### 7.2 iOS (Future)

| Test | Hedef |
|------|-------|
| IPA build | TestFlight compatible |
| App Store validation | Metadata, screenshots |
| Push notifications | APNs configuration |
| Face ID | LocalAuthentication |
| Camera permission | NSCameraUsageDescription |

---

## 8. Firebase ve Cloud Entegrasyon Testleri

### 8.1 Firebase Auth

```
Test Cases:
├── Email/Password Sign-up
├── Email/Password Sign-in  
├── Guest Anonymous Auth
├── Password Reset Email
├── Email Verification (SMTP config required)
├── Session Management
├── Token Refresh
└── Sign-out everywhere
```

### 8.2 Firestore

| Test | Senaryo |
|------|---------|
| Offline capability | airplane mode'da yazma/okuma |
| Sync conflict | concurrent write resolution |
| Batch operations | Bulk note creation |
| Query performance | 1000+ documents pagination |

### 8.3 Firebase Storage

| Test | Senaryo |
|------|---------|
| File upload | Note attached images |
| File download | Offline availability |
| Resumable upload | Large files (>5MB) |
| Security rules | Unauthorized access prevention |
| **Bucket permissions** | **⚠️ 404 hatası çözümü gerekli** |

### 8.4 Cloud Functions

- [ ] Email sending function (SMTP)
- [ ] Weekly report generation
- [ ] Moodle sync trigger
- [ ] E2E key rotation

---

## 9. Kullanıcı Kabul Kriterleri (UAT)

### 9.1 Student Persona

**Scenario:** Ayşe, üniversite 2. sınıf öğrencisi

| Görev | BAŞARI KRİTERİ |
|-------|-----------------|
| Kayıt olma | < 2 dakikada hesap oluşturma |
| Ders ekleme | < 1 dakikada ders ekleme |
| Not alma | < 30 saniyede text note oluşturma |
| OCR kullanma | < 1 dakikada fotoğraftan metin çıkarma |
| Devamsızlık takibi | Anlık konum ile devamsızlık kontrolü |
| Arama | < 500ms'de sonuç bulma |
| Moodle senkron | < 30 saniyede ders senkronu |

### 9.2 Beta Tester Checklist

```
[ ] "Registration flow was smooth"
[ ] "Adding courses feels intuitive"
[ ] "OCR accuracy is acceptable for handwritten notes"
[ ] "Search found my notes by image filename"
[ ] "Dark mode is comfortable for night study"
[ ] "No crashes during 1-hour continuous use"
[ ] "Battery drain is acceptable"
[ ] "Offline mode works as expected"
[ ] "Moodle integration saves time"
```

---

## 10. Risk Matrisi ve Azaltma Stratejileri

### 10.1 Risk Matrix

| Risk | Olasılık | Etki | Risk Skoru | Azaltma |
|------|----------|------|------------|---------|
| E2E encryption key loss | Düşük | Kritik | 🔴 | Backup key to Firebase + user-provided recovery key |
| Database migration failure | Orta | Yüksek | 🟠 | v14→v17 upgrade script + pre-release testing |
| Firebase Storage 404 | Yüksek | Orta | 🟠 | Bucket permission fix + retry logic |
| Notification permission denied | Yüksek | Düşük | 🟡 | Graceful degradation + user education |
| Performance on low-end devices | Orta | Orta | 🟡 | Profiling + optimization |
| OCR accuracy issues | Orta | Düşük | 🟡 | User feedback + ML model improvement |

### 10.2 Rollback Plan

1. **Feature Flag:** Tüm yeni özellikler feature flag ile
2. **Database Versioning:** Her schema değişikliği versiyonlanmış
3. **Gradual Rollout:** %1 → %10 → %50 → %100 staged rollout
4. **Instant Rollback:** Firebase Remote Config ile anlık disable

---

## 11. Pre-Production Checklist

### 11.1 Code Quality

- [ ] `flutter analyze` - 0 errors, < 50 warnings
- [ ] `flutter test` - Tüm testler geçer
- [ ] Code review - Minimum 2 reviewer onayı
- [ ] Security scan - `flutter pub run flutter sec` (future)

### 11.2 Build Artifacts

```bash
# Debug APK (testing)
flutter build apk --debug

# Release APK (Play Store)
flutter build apk --release

# App Bundle (Play Store preferred)
flutter build appbundle --release

# Split APKs (size optimization)
flutter build apk --split-per-abi --release
```

### 11.3 Play Store Preparation

| Item | Status | Not |
|------|--------|-----|
| App icon (1024x1024) | ⏳ | |
| Screenshots (phone + tablet) | ⏳ | |
| Feature graphic (1024x500) | ⏳ | |
| Description (4000 char max) | ⏳ | |
| Privacy policy URL | ⏳ | KVKK compliance |
| Content rating questionnaire | ⏳ | |
| Target audience | ⏳ | 16+ education |
| Region availability | ⏳ | Turkey initially |

### 11.4 Firebase Console

- [ ] Production Firebase project lock
- [ ] Analytics debug view verified
- [ ] Crashlytics symbols uploaded
- [ ] App distribution testers list
- [ ] Remote config sanity checks

---

## 12. Post-Release Monitoring Planı

### 12.1 Crash Monitoring

```
Week 1: Check-in every 2 days
├── Crash-free users > %99.5
├── ANR rate < %0.1
└── Top 3 crashes identified
```

### 12.2 Performance Monitoring

```
Firebase Performance SDK
├── App start time
├── Screen frame rate
├── Network request latency
└── Database query time
```

### 12.3 User Feedback Loop

1. **In-app feedback button** - Direct bug report
2. **Play Store reviews** - Daily monitoring
3. **Beta tester group** - Pre-release validation
4. **Analytics events** - User behavior insight

### 12.4 Iteration Plan

```
Week 1-2: Bug fixes (P0-P1)
Week 3-4: Performance optimization
Week 5-8: Feature enhancements (based on feedback)
Week 12: Major release (iOS + new features)
```

---

## 📊 Test Coverage Summary

| Alan | Coverage | Durum |
|------|----------|-------|
| Authentication | %75 | Geliştirme gerekiyor |
| Course Management | %60 | Temel testler var |
| Note Operations | %70 | DB migration test edilmeli |
| Search | %80 | ✅ Enhanced |
| Attendance | %50 | Konum testleri eksik |
| Grades | %60 | |
| Moodle Integration | %40 | Mock test yeterli |
| E2E Encryption | %30 | Kritik test eksik |
| Storage/Cloud | %40 | 404 hatası çözümü gerekli |

---

## 🚨 Açık Sorunlar (Blocking Release)

1. **[CRITICAL]** Firebase Storage 404 - Bucket permissions düzeltilmeli
2. **[CRITICAL]** Exact alarm permission handle - Android 14+
3. **[HIGH]** E2E encryption roundtrip test edilmeli
4. **[HIGH]** Database v14→v17 migration test edilmeli (production DB)

---

## ✅ Yayın Onay Kriterleri

- [ ] Tüm 🔴 critical sorunlar çözüldü
- [ ] Crash-free rate > %99.5 (1 hafta beta)
- [ ] Beta tester approval > %80
- [ ] Play Store asset submission complete
- [ ] Pre-release checklist %100 tamamlandı

---

*Bu doküman sürekli güncellenecektir. Son güncelleme: 23 Nisan 2026*