# Lesson Tracker — Kod Kalite Raporu

- **Tarih:** 17 Temmuz 2026
- **Toplam Dart dosyası:** 165
- **Toplam satır:** ~19.600
- **Yöntem:** Statik okuma + dosya:satır kanıtları
- **Durum:** Arşivde. Maddelerin küçük bir kısmı bu oturumda uygulandı; büyük refactor önerileri ayrı oturumlara bırakıldı.

> Bu rapor uygulamayı çalıştırmadan, yalnızca statik incelemeyle yazılmıştır. Aynı gün yazılan `AUDIT_REPORT_2026-07-17.md` ile birlikte okunmalıdır; o rapor uygulamayı gerçekten çalıştırarak doğrulama yaptı.

---

## 1. Gereksiz / Ölü Kod

| Dosya | Satır | Sorun | Bu oturumda |
|---|---|---|---|
| `lib/main.dart` | 275-278 | Email verification kodu tamamen comment'e alınmış, askıda | ⏸ Bırakıldı (aktif TODO — bilinçli olarak) |
| `lib/core/utils/error_handler.dart` | 44-45 | Production error mesajı comment'e alınmış | ✅ Silindi |
| `lib/core/services/notification_service.dart` | 52 | `print()` kullanılmış, `debugPrint()` olmalıydı | ✅ `debugPrint`'e çevrildi |

**Doğrulama:**
- `print()` sayısı `lib/`: 2 → 1 (yalnız `moodle_file_download_service.dart:135` kaldı)
- `debugPrint()` sayısı `lib/`: 228 (değişmedi; release'de no-op olduğu için öncelik düşük)

---

## 2. Tekrarlayan (Duplicate) Kod

- **Try-catch pattern** — 5 provider'da (auth, course, note, sync, moodle) tekrar eden `_error = null → try → _error = e.toString() → notifyListeners()` kalıbı
- **Loading state** — 5 provider'da tekrar eden `_isLoading = true → notifyListeners() → finally { _isLoading = false; notifyListeners(); }` kalıbı
- `course_provider.dart` içinde aynı sort kodu 3 kez (satır 529, 568, 596)
- `addAbsence()` ve `addAbsenceAt()` neredeyse identik — `addAbsence` `DateTime.now()` ile çağrılan ince sarmalayıcı olarak korunabilir, ya da tek metoda default parametre eklenebilir

**Doğrulama:**
- `_isLoading = true` sayısı: 13 (5 provider)
- `_error = null` sayısı: 33 (5 provider)

**Önerilen çözüm (MVP+1):** `BaseProvider` mixin sınıfı: `loadingStart()`, `loadingEnd()`, `runWithError(String action, Future<T> Function() body)`. Bu oturumda uygulanmadı (kapsam dışı, mimari refactor gerektiriyor).

---

## 3. Mimari Sorunlar

### Dev dosyalar çok büyük (Single Responsibility ihlali)

| Dosya | Satır | Problem |
|---|---|---|
| `note_detail_screen.dart` | 1302 | Çizim, PDF, ses, metadata, paylaşım hepsi aynı dosyada |
| `course_detail_screen.dart` | 1075 | 4 tab + header + data yükleme |
| `settings_e2e_section.dart` | 849 | Şifreleme UI, dialog'lar, async işlemler karışık |
| `storage_screen.dart` | 801 | Backup/restore + progress UI |

### CourseProvider çok şey yapıyor (1000+ satır)
- CRUD işlemleri
- Devamsızlık yönetimi
- Not yönetimi
- Dosya işlemleri
- Bildirim planlama
- Çakışma tespiti

### Repository'ler dependency injection olmadan direkt örnekleniyor
Her provider kendi repository'lerini `new` ile oluşturuyor — test yazımını zorlaştırıyor.

**Bu oturumda:** Uygulanmadı (günler süren mimari refactor, regression riski yüksek).

---

## 4. Eksik / Yarım Kalan Özellikler

| Özellik | Durum |
|---|---|
| Email doğrulama | Devre dışı (SMTP kurulmamış) |
| Offline-first sync recovery | Yarım — pending changes kaydediliyor ama kurtarma mantığı eksik |
| Moodle dosya önizleme | Bu oturumda kısmen çözüldü — Plan #11 ile PDF nota eklenebilir hale geldi (`AUDIT_REPORT_2026-07-17.md` §11) |
| Bulk işlemler | Toplu silme, etiketleme, not içe aktarma yok |
| Sosyal login | Sadece email/şifre var, OAuth yok |

**Not:** "Yarım kalmış özellik" kararları ürün sahibinin onayını gerektirir; bu oturumda sadece Moodle dosya önizleme bağlantısı kısmen iyileştirildi.

---

## 5. Test Eksiklikleri

| Alan | Durum |
|---|---|
| Provider testleri | ✅ 6 dosya mevcut |
| Screen testleri | ✅ 3 dosya mevcut |
| Widget testleri | ✅ 5 dosya mevcut |
| Service testleri | ❌ Hiç yok |
| Repository testleri | ❌ Hiç yok |
| E2E şifreleme testleri | ❌ Hiç yok |
| SyncService testleri | ❌ Hiç yok |

**Bu oturumdaki gelişme:** `test/test_helpers.dart` SqlCipher mock'u düzeltildi, **%46 → %92 test geçişi** sağlandı (`AUDIT_REPORT_2026-07-17.md` §03). Service/repository testleri ayrı oturum gerektirir.

`NotificationService` mock için `testOpenDatabaseOverride` benzeri hacky yöntemler yerine DI tabanlı `ServiceLocator` veya `get_it` paketi önerilir.

---

## 6. Bağımlılık (Package) Sorunları

| Paket | Sorun | Bu oturumda |
|---|---|---|
| `pdfx` + `syncfusion_flutter_pdfviewer` | İkisi birden var — biri fazla | ⏸ Karar gerekli (hangi kullanıldığını kontrol et, diğerini sil) |
| `cached_network_image` | Sadece Moodle thumbnail'leri için, ağır bir bağımlılık | ⏸ Kullanım taraması gerekli |
| `flutter_typeahead` | Çok az yerde kullanılıyor | ⏸ Kullanım taraması gerekli |
| `http` (yerine `dio`) | Timeout yönetimi ve interceptor eksik | ⏸ Kütüphane değişikliği — geniş etki |
| Sentry/Logging | Sadece Firebase Crashlytics var | ⏸ Ürün kararı |

**Bu oturumda:** `flutter_background_service` ve `vibration` ölü paketleri kaldırıldı (`AUDIT_REPORT_2026-07-17.md` §08). Kalan paket kararları sizin onayınızı bekliyor.

---

## 7. Potansiyel Bug'lar

| Dosya | Risk | Açıklama | Bu oturumda |
|---|---|---|---|
| `note_detail_screen.dart` | YÜKSEK | 1302 satır, karmaşık state — mutation bug'ları kaçınılmaz. Bu oturumda çok sayfalı çizim bug'ı düzeltildi (`AUDIT_REPORT_2026-07-17.md` §07). | ✅ Kısmi |
| `sync_service.dart:49-64` | ORTA | Retry backoff — ağ sorunlarında süresiz bekleyebilir | ⏸ |
| `moodle_provider.dart` | ORTA | Aggregated getter'larda limit yok — büyük hesaplarda memory sızıntısı | ⏸ |
| `course_provider.dart:594` | DÜŞÜK | `dateStr as DateTime` — yanlış tipte runtime crash riski | ⏸ |
| `database_helper.dart:92-100` | DÜŞÜK | SQLCipher key doğrulaması yok | ⏸ |

---

## Öncelik Sırası (Orijinal Raporun Önerisi)

### Hemen Yapılmalı
1. Base provider class oluştur
2. `note_detail_screen.dart` parçala
3. İki PDF viewer'dan birini sil
4. Service + Repository testleri yaz

### Yakın Süreçte
5. `CourseProvider`'ı parçala
6. `MoodleProvider`'ı ikiye böl
7. Tüm text input'lara validasyon ekle
8. Offline sync recovery mantığını tamamla

**Bu oturumda uygulanan:** Sadece §1 (3 öğeden 2'si). Diğerleri mimari refactor veya ürün kararı gerektiriyor; ayrı oturumlarda ele alınmalı.

---

## Bu Rapor Hakkında Not

Bu rapor, uygulamayı çalıştırmadan yazılmış bir statik incelemedir. Aynı gün yazılan `AUDIT_REPORT_2026-07-17.md` (bkz. `../AUDIT_REPORT_2026-07-17.md`) tarafından kısmen doğrulandı:
- §1 "Gereksiz kod" iddiaları — doğrulandı ve 2/3'ü uygulandı
- §2 "Duplicate kod" iddiaları — sayılar abartılı (8 değil 5 provider, 13+33 pattern tekrarı)
- §3 "Dev dosyalar büyük" iddiaları — doğru; bu oturumda `note_detail_screen.dart` §7 ile kısmen iyileştirildi
- §5 "Test eksiklikleri" — doğru; bu oturumda %46→%92 iyileşme sağlandı
- §6 "Paket sorunları" — `flutter_background_service`/`vibration` ölü paketleri bu oturumda kaldırıldı

---

*Bu rapor 17 Temmuz 2026 tarihinde, uygulama çalıştırılmadan hazırlanmış, aynı gün yapılan oturumda kısmen uygulanmıştır. Mimari refactor önerileri (§2, §3, §5) bağımsız oturumlar gerektirir.*