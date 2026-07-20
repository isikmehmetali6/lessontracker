# LessonTracker - TAKIM QA DENETİM RAPORU

**Rapor Tarihi:** 7 Nisan 2026  
**Takım Üyeleri:** QA Test Lead, Security Auditor, UI/UX Tester, Integration Tester, Performance Auditor  
**Uygulama Versiyonu:** LessonTracker (Flutter)  
**Genel Risk Seviyesi:** ⚠️ KRITIK

---

## YÖNETİCİ ÖZETİ

| Kategori | Kritik | Yüksek | Orta | Düşük | Toplam |
|----------|--------|--------|------|-------|--------|
| Authentication & Auth | 1 | 1 | 1 | 1 | 4 |
| KVKK & Güvenlik | 4 | 3 | 3 | 1 | 11 |
| Course Management | 2 | 2 | 2 | 1 | 7 |
| UI/UX | 1 | 4 | 8 | 6 | 19 |
| Moodle & Sync | 3 | 2 | 3 | 1 | 9 |
| Performance | 2 | 4 | 3 | 2 | 11 |
| **TOPLAM** | **13** | **16** | **20** | **12** | **61** |

**Sonuç:** Uygulama yayınlanmaya HAZIR DEĞİL. 13 kritik sorun derhal düzeltilmelidir.

---

## KRITIK BULGULAR (Hemen Düzeltilmeli)

### K1: KVKK - Veli Onayı Simüle Ediliyor ⚠️ KRITIK
**Kategori:** KVKK & Yasal Uyumluluk  
**Risk:** Yasal yaptırım, App Store reddi  
**Dosya:** `app/lib/screens/auth/veli_consent_screen.dart:358-364`

```dart
Future.delayed(const Duration(seconds: 1), () {
  if (mounted) {
    widget.onConsentGiven();  // Onay SIMÜLE EDİLİYOR!
  }
});
```

**Sorun:** 18 yaş altı kullanıcılar için veli onayı gerçekte GÖNDERİLMİYOR. Sadece 1 saniye bekleyip geçiliyor.

**Gereken:**
- Gerçek e-posta doğrulaması (onay linki)
- Veli kimlik doğrulama mekanizması
- Onay timestamp + veli IP loglanmalı

---

### K2: SQLite Veritabanı Şifrelenmemiş ⚠️ KRITIK
**Kategori:** Data Privacy  
**Risk:** Cihaz çalınırsa veya rootlanırsa tüm veriler açık  
**Dosya:** `app/lib/core/database/database_helper.dart:51-59`

```dart
return await openDatabase(
  path,
  version: 15,
  onConfigure: (db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  },
  // NO encryption parameter!
);
```

**Şifrelenmemiş Veriler:** isimler, not içerikleri, notlar, e-postalar, konum bilgisi

---

### K3: Bulut Yedeği Şifreleme Anahtarı Kullanılmıyor ⚠️ KRITIK
**Kategori:** Data Privacy  
**Risk:** Firebase'e şifrelenmemiş veri yükleniyor  
**Dosya:** `app/lib/core/services/sync_service.dart:61-350`

```dart
Future<void> _ensureEncryptionKeyExists() async {
  final generatedKey = encrypt.Key.fromSecureRandom(32);  // Anahtar ÜRETİLİYOR
  await _secureStorage.write(key: _keyEncryptionKey, value: generatedKey.base64);
}
// AMA backupData() FONKSIYONUNDA KULLANILMIYOR!
await _firestore.collection('users').doc(uid).collection('courses').doc(course.id).set(course.toMap());
// Şifrelenmeden direkt yükleniyor!
```

---

### K4: Moodle Şifresi URL Query Parameter'da Gönderiliyor ⚠️ KRITIK
**Kategori:** Security  
**Risk:** Şifre server log'larında, browser history'de görünür  
**Dosya:** `app/lib/services/moodle/moodle_api_service.dart:429-437`

```dart
Uri _buildLoginUri(String baseUrl, String username, String password) {
  return Uri.parse('...').replace(
    queryParameters: {
      'username': username,
      'password': password,  // ⚠️ URL'DE GİDİYOR!
    },
  );
}
```

**Çözüm:** POST request kullanılmalı, şifre body'de gönderilmeli.

---

### K5: Offline Eklenen Veri Cloud'a Gönderilmiyor ⚠️ KRITIK
**Kategori:** Data Loss  
**Dosya:** `app/lib/core/services/auto_sync_service.dart`

```dart
Future<void> _performBackup() async {
  if (!hasConnection) {
    _hasPendingBackup = true;  // ← Sadece flag, veri KAYBOLUYOR
    return;                     // ← Burada BIRAKIYOR
  }
  // Uygulama kapatılırsa pending backup kaybolur
}
```

**Risk:** Kullanıcı offline iken eklediği ders/veri cloud'a ASLA senkronize olmaz.

---

### K6: Attendance Otomasyonu Yoklama Kaydı Oluşturmuyor ⚠️ KRITIK
**Kategori:** Logic Bug  
**Dosya:** `app/lib/core/services/attendance_automation_service.dart:76-90`

```dart
if (!isAtUni) continue;  // Kampüste DEĞİLSE devam et
await prefs.setBool(checkKey, true);  // SADECE flag, yoklama YOK
```

**Sorun:** Sistem otomatik olarak devamsızlık GIRMIYOR ama YOKLAMA KAYDI da OLUŞTURMUYOR. Veri tutarsızlığı.

---

### K7: Rıza Alınmadan Uygulamaya Devam Edilebiliyor ⚠️ KRITIK
**Kategori:** KVKK  
**Dosya:** `app/lib/screens/onboarding/acik_riza_screen.dart:240`

```dart
// "Rıza Vermeden Devam Et" butonu var!
```

**Sorun:** KVKK Madde 5/1'e göre açık rıza zorunlu. Rıza reddedilirse işleme devam edilemez.

---

### K8: Gecmiş Deadline'lar Kırmızı Değil Gri Gösteriliyor ⚠️ KRITIK
**Kategori:** UI Bug  
**Dosya:** `app/lib/screens/deadlines/deadline_screen.dart:176-178`

```dart
if (daysLeft < 0) {
  statusColor = Colors.grey;  // ⚠️ KIRMIZI DEĞİL!
}
```

**Risk:** Kullanıcı geçmiş deadline'ları fark etmeyebilir.

---

### K9: N+1 Query Problemi - Course Load ⚠️ KRITIK
**Kategori:** Performance  
**Dosya:** `app/lib/providers/course_provider.dart:256-259`

```dart
for (int i = 0; i < _courses.length; i++) {
  final absences = await _absenceRepo.getAbsencesByCourse(_courses[i].id);
  // 100 ders = 1 + 100 = 101 sorgu!
}
```

**Çözüm:** Tek sorgu ile tüm absences çekilmeli.

---

### K10: Empty Catch Blocks - Silent Fail ⚠️ KRITIK
**Kategori:** Code Quality  
**Dosya:** Birçok yerde

```dart
} catch (_) {}  // ✗ Hata kayboluyor
```

**Risk:** Hatalar sessizce başarısız oluyor, debugging imkansız.

---

### K11: Weight > 100% Durumunda Yanlış Ortalama ⚠️ KRITIK
**Kategori:** Logic Bug  
**Dosya:** `app/lib/providers/course_provider.dart:628-645`

**Örnek:** 2 grade, herbiri weight=75 (toplam 150)
- 100/100 ağırlık=75, 50/100 ağırlık=75
- `totalWeightedScore = 100*75 + 50*75 = 11250`
- `totalWeight = 150`
- `result = 11250/150 = 75` (YANLIŞ! Olması gereken: (75+50)/2 = 62.5)

---

### K12: Cascade Delete Cloud Hata Yönetimi Yok ⚠️ KRITIK
**Kategori:** Data Integrity  
**Dosya:** `app/lib/providers/course_provider.dart:437-441`

**Senaryo:** Course siliniyor → Local DB başarılı → Cloud başarısız = VERİ TUTARSIZLIĞI

---

### K13: Web Platformunda Silinen Kurs Memory'den Silinmiyor ⚠️ KRITIK
**Kategori:** Bug  
**Dosya:** `app/lib/repositories/course_repository.dart:98-100`

```dart
if (_dbHelper.isWeb) {
  _coursesInMemory.removeWhere((c) => c.id == id);
  return;  // ← erken return, cloud sync atlanıyor
}
```

---

## TAKIM BULGULARI ÖZETİ

### 1. QA TEST LEAD - Authentication & Core

| ID | Bulgu | Risk | Durum |
|----|-------|------|--------|
| AUTH-01.2 | Email validasyonu TLD sınırı 4 karakter | Kritik | Düzeltilmeli |
| AUTH-01.1 | `+` alias desteklenmiyor | Bilgi | Kabul edilebilir |
| COURSE-03.1 | Edit modunda ek schedule item için çakışma kontrolü yok | Orta | Düzeltilmeli |
| COURSE-04.2 | Web'de cascade delete eksik | Kritik | K12 |
| ABS-01.1 | Yeni kurslarda tahmin uyarısı çalışmıyor | Orta | İyileştirme |
| GRADE-WEIGHT | 100%+ ağırlıkta yanlış hesaplama | Kritik | K11 |

### 2. SECURITY AUDITOR - KVKK & Data

| ID | Bulgu | Risk |
|----|-------|------|
| KVKK-01 | Veli onayı simüle ediliyor | ⚠️ KRITIK (K1) |
| KVKK-02 | SQLite şifrelenmemiş | ⚠️ KRITIK (K2) |
| KVKK-03 | Bulut yedeği şifrelenmemiş | ⚠️ KRITIK (K3) |
| KVKK-04 | Rıza alınmadan devam var | ⚠️ KRITIK (K7) |
| AUTH-SEC | Moodle şifresi URL'de | ⚠️ KRITIK (K4) |
| SEC-05 | Şifre min 6 karakter çok zayıf | Yüksek |
| SEC-06 | Rate limiting yok | Orta |
| SEC-07 | Token expiry yönetimi yok | Yüksek |
| SEC-08 | Konum SharedPreferences'da şifrelenmemiş | Orta |
| SEC-09 | Watermark'da PII (kullanıcı adı) | Orta |

### 3. UI/UX TESTER - All Screens

| ID | Bulgu | Öncelik |
|----|-------|---------|
| UI-11 | Gecmiş deadline gri gösteriliyor | ⚠️ KRITIK (K8) |
| UI-05 | Bottom toolbar koyu modda beyaz arka plan | Yüksek |
| UI-02 | PriorityCourseCard beyaz metin koyu modda | Yüksek |
| UI-18 | Koyu modda alpha değerleri düşük | Orta |
| UI-03 | Progress mesajları localize edilmemiş | Düşük |
| UI-07 | Add Course form'da gereksiz 120px boşluk | Düşük |
| UI-09 | Course name için maxLength yok | Orta |
| UI-13 | Gecmiş deadline'lar listelenmiyor | Orta |
| UI-15 | formattedDuration null kontrolü yetersiz | Orta |

### 4. INTEGRATION TESTER - Moodle & Sync

| ID | Bulgu | Risk |
|----|-------|------|
| INT-05 | Offline data loss | ⚠️ KRITIK (K5) |
| INT-08 | Attendance yoklama kaydı yok | ⚠️ KRITIK (K6) |
| INT-02 | Sequential announcement fetch (10dk = 10sn) | Yüksek |
| INT-04 | Course restore eksik kalabilir | Yüksek |
| INT-07 | Bildirim mute mekanizması yok | Orta |
| INT-01 | Token expiry yönetimi yok | Orta |
| INT-03 | Cache boyut sınırı yok | Orta |
| INT-06 | Yeniden başlatma sonrası bildirim yeniden schedule yok | Orta |
| INT-09 | Çift GPS çağrısı | Düşük |

### 5. PERFORMANCE & ARCHITECTURE AUDITOR

| ID | Bulgu | Risk |
|----|-------|------|
| PERF-01 | N+1 query problemi | ⚠️ KRITIK (K9) |
| PERF-02 | Empty catch blocks | ⚠️ KRITIK (K10) |
| PERF-03 | Memory leak (DeadlineProvider, MoodleProvider) | Yüksek |
| PERF-04 | Pagination eksik (tüm veri çekiliyor) | Yüksek |
| PERF-05 | Widget rebuild optimizasyonu yok | Yüksek |
| PERF-06 | Const constructor eksik | Orta |
| PERF-07 | Magic numbers constants'a çıkarılmamış | Orta |
| PERF-08 | RepaintBoundary yok | Orta |
| PERF-09 | v11 DB migration main thread'i bloke edebilir | Orta |

---

## YAYIN ÖNCESİ DÜZELTME LİSTESİ

### FASE 1: KRITIK Düzeltmeler (1-2 gün)

| # | Düzeltme | Dosya | Sorumlu |
|---|----------|-------|---------|
| 1 | Veli onayı gerçek e-posta doğrulaması ekle | veli_consent_screen.dart | Backend + Auth |
| 2 | SQLite encryption ekle (sqflite_sqlcipher veya Hive) | database_helper.dart | Security |
| 3 | Bulut yedeği gerçek şifreleme uygula | sync_service.dart | Backend |
| 4 | Moodle POST request yap, şifreyi body'de gönder | moodle_api_service.dart | Security |
| 5 | Offline pending changes için `pending_changes` tablosu ekle | auto_sync_service.dart | Backend |
| 6 | Attendance otomasyonu düzelt, yoklama kaydı oluştur | attendance_automation_service.dart | Backend |
| 7 | "Rıza Vermeden Devam Et" butonunu kaldır veya işlemi engelle | acik_riza_screen.dart | UX |
| 8 | Gecmiş deadline'ları kırmızı göster | deadline_screen.dart | UI |

### FASE 2: YÜKSEK Öncelikli (3-5 gün)

| # | Düzeltme | Dosya | Sorumlu |
|---|----------|-------|---------|
| 9 | N+1 query çöz, tek sorgu ile absences çek | course_provider.dart | Backend |
| 10 | Empty catch block'lara hata loglaması ekle | * (global) | Code Quality |
| 11 | 100%+ ağırlık durumunda normalize et veya uyarı engel yap | course_provider.dart | Logic |
| 12 | Cascade delete cloud hata yönetimi ekle | course_provider.dart | Backend |
| 13 | Web platformunda silme düzelt | course_repository.dart | Web Bug |
| 14 | Memory leak - DeadlineProvider, MoodleProvider dispose() | deadline_provider.dart | Memory |
| 15 | Bottom toolbar dark mode contrast düzelt | course_bottom_toolbar.dart | UI |
| 16 | PriorityCourseCard dark mode text color düzelt | home_widgets.dart | UI |

### FASE 3: ORTA Öncelikli (1-2 hafta)

| # | Düzeltme | Dosya |
|---|----------|-------|
| 17 | Pagination ekle (getAllNotes, getAllCourses) | Repository'ler |
| 18 | Token expiry yönetimi ekle | Moodle |
| 19 | Cache boyut sınırı ekle | moodle_cache_repository |
| 20 | Bildirim mute mekanizması ekle | notification_service |
| 21 | Yeniden başlatma sonrası bildirim yeniden schedule | notification_service |
| 22 | Moodle announcement paralel fetch (Future.wait) | moodle_api_service |
| 23 | HomeStatsSummary Selector ile optimize et | home_widgets.dart |
| 24 | Course name maxLength validator ekle | add_course_form |
| 25 | v11 migration background thread'e taşı | database_helper.dart |

---

## TEST SONRASI DURUM DEĞERLENDİRMESİ

| Modül | Önceki Durum | Yeni Bulgu | Yayın Durumu |
|-------|-------------|------------|--------------|
| Authentication | ✅ İyi | 4 yeni | ⚠️ Dikkat |
| KVKK Uyumluluğu | ❌ Kötü | 4 kritik | ❌ Yayınlanmaz |
| Course Management | ✅ İyi | 2 kritik | ⚠️ Dikkat |
| UI/UX | ⚠️ Orta | 4 yüksek | ⚠️ Düzeltilmeli |
| Moodle & Sync | ⚠️ Orta | 3 kritik | ❌ Düzeltilmeli |
| Performance | ⚠️ Orta | 2 kritik | ⚠️ Düzeltilmeli |

---

## SONUÇ

**YAYIN DURUMU: ⚠️ HAZIR DEĞİL**

LessonTracker uygulaması **13 kritik sorun** içermektedir. Bu sorunlar yayınlanmadan ÖNCE düzeltilmelidir.

**Zorunlu Düzeltmeler (Yayın Öncesi):**
1. ✅ KVKK veli onayı mekanizması
2. ✅ SQLite veritabanı şifreleme
3. ✅ Bulut yedeği şifreleme
4. ✅ Moodle güvenli kimlik doğrulama
5. ✅ Offline veri kaybı önleme
6. ✅ Gecmiş deadline UI düzeltmesi

**Tahmini Düzeltme Süresi:** 1-2 hafta (tam ekip)

**Alternatif:** Eğer zaman kısıtlıysa, KVKK uyumsuzluğu giderilmeden App Store/Play Store yayını YASAL sorumluluk doğuracaktır. Mutlaka düzeltilmelidir.

---

*Raporda mutabık kalan takım:*  
- QA Test Lead  
- Security Auditor  
- UI/UX Tester  
- Integration Tester  
- Performance Auditor  

*Tarih:* 7 Nisan 2026