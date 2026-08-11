# LessonTracker — Proje Analizi & Refactoring Yol Haritası

- **Tarih:** 1 Ağustos 2026
- **Detaylandırma:** 1 Ağustos 2026 (akşam) — §04–§07 uygulama kartları, PR dilimi, DI kararı; §J boş dosya/yapı; **§08 Uygulama Kılavuzu**
- **Hedef:** LessonTracker Kod Tabanı Mevcut Durum Tespiti & Adım Adım Refactoring Yol Haritası
- **Kapsam:** `app/lib/` (~56.900 satır, ~165 Dart dosyası), Bağımlılıklar, Mimari, Testler ve Ürün Özellikleri
- **Durum:** 🚧 Devam Ediyor — *nasıl uygulanır → [§08](#-08--uygulama-kılavuzu-how-to-execute)*
- **DI kararı:** Constructor injection + mevcut `provider` paketi (get_it / Riverpod yok)
- **Faz 4 ayrımı:** 4a teknik borç · 4b ürün kararı backlog (refactor zorunluluğu değil)
- **Doğrulama:** İlk metrikler 01.08.2026'da `flutter analyze` + `flutter test` + dosya taraması ile çıkarıldı.
- **Yeniden doğrulama:** 01.08.2026 akşamı §A–§I maddeleri kod tabanında tek tek arandı; her alt başlığa "Doğrulama notu" eklendi. Özet: A (blokörler) çoğunlukla hâlâ geçerli; B/C monolit+DI hâlâ geçerli; D büyük ölçüde düzelmiş; E'de stylus kısmen gerçek, program üretici yok; F 69 issue + 27 async gap hâlâ; G auth_flow kırık; H TextScaler kalkmış / Moodle nota ekle kısmi; I listesi genişletildi.

---

## 📌 01 — Yönetici Özeti (Executive Summary)

LessonTracker; **Multimodal Not Alma (OCR, Ses, Çizim, PDF), Moodle Entegrasyonu, Devamsızlık Takibi, Biyometrik Kilit ve Firebase Senkronizasyonu** gibi zengin işlevlere sahip geniş kapsamlı bir Flutter mobil uygulamasıdır.

Projeye başlarken **Repository Pattern**, **Provider State Management** ve **Encrypted SQLite (SQLCipher)** gibi doğru mimari kararlar alınmış olsa da, zamanla biriken **teknik borçlar (technical debt)**, monolitik sınıflar, durum tutarsızlıkları (state desynchronization) ve tamamlanmamış uç özellikler nedeniyle kod tabanı bakım yapması zor bir seviyeye gelmiştir.

**Özet durum tablosu (01.08.2026 ölçümleri):**

| Metrik | Değer |
|---|---|
| Toplam Dart dosyası | ~165 (lib) + 18 test dosyası |
| Toplam satır | 56.908 |
| `flutter analyze` | **69 sorun** (0 error, 11 warning, 58 info) |
| `flutter test` | 72 test → **66 geçer / 6-11 başarısız (koşudan koşuya değişiyor = flaky)** |
| Kırık font dosyası | 5/5 (Lexend — HTML içerikli `.ttf`) |
| Boş asset klasörü | `assets/images/`, `assets/icons/` (yalnızca `.gitkeep`) |
| Git'te olmaması gereken | `.kilo/` (node_modules dahil), `app/lib/l10n/app_localizations.dart.bak` |
| print/debugPrint | 229 çağrı (`avoid_print` kuralı kapalı) |
| Freezed kullanılan model | 2 / ~15 (yalnızca `course`, `note`) |
| CI | Yok |

Bu doküman, refactoring sürecinin referans rehberidir ve tüm adımlar aşama aşama bu plan üzerinden yürütülecektir.

---

## 🟢 02 — Projenin Güçlü Yönleri (Strengths)

1. **Zengin ve Yenilikçi Özellik Kapsamı (Multimodal Capabilities):**
   - Tek bir uygulamada Moodle senkronizasyonu, OCR metin okuma, sesli not kaydı, PDF üzeri çizim/not alma ve otomatik devamsızlık takibi gibi öğrenci odaklı güçlü özellikler bir araya getirilmiştir.
   - GPS tabanlı otomatik devamsızlık kaydı (`AttendanceAutomationService`) ve Workmanager arka plan görevleri başarıyla kurgulanmıştır.

2. **Güvenlik ve Çevrimdışı (Offline-First) Mimari:**
   - Hassas veriler yerelde `sqflite_sqlcipher` ile şifreli SQLite veritabanında saklanmaktadır.
   - Biyometrik kilit (`local_auth` / `AppLockService`) ve KVKK uyumluluk akışları entegre edilmiştir.
   - Moodle verileri için çevrimdışı önbellekleme mekanizması (`MoodleCacheRepository`) kurulmuştur.
   - E2E şifreleme katmanı, network hata sınıflandırması + üstel geri çekilme (retry) mevcuttur.

3. **Katmanlı Klasör Yapısı Niyeti:**
   - Proje klasör yapısı `core`, `models`, `providers`, `repositories`, `screens`, `widgets` şeklinde katmanlara ayrılmıştır. Bu yapı refactor işlemi için çok uygun bir temel sunmaktadır.
   - 78 ekran dosyasından 70'i `AppLocalizations.of(context)` kullanıyor — yerelleştirme kapsamı iyi (4 dil: tr/en/de/es).
   - DB şema yönetimi migration tabanlı (v17), FK'lar açık, test override hook'u tasarlanmış.

---

## 🔴 03 — Zayıf Yönler, Teknik Borçlar & Kritik Eleştiriler (Weaknesses & Technical Debt)

### 🔥 A. Yayın Blokörleri (Release Blockers) — Önce BUNLAR Çözülmeli

> **Uygulama:** → [Faz 0](#-faz-0-yayın-blokörleri-release-blockers--12-gün)

> **Doğrulama notu (01.08.2026 yeniden tarama):** Aşağıdaki maddeler kod tabanında tek tek kontrol edildi.

1. **Lexend Fontları 5/5 Kırık (Kritik):** ✅ **DOĞRULANDI**
   - `app/assets/fonts/Lexend-*.ttf` dosyalarının **tamamı HTML dokümanıdır** (GitHub sayfa kaynağı, `<!DOCTYPE html>`). `file` komutu "HTML document text" doğrulamaktadır.
   - Aynı bozuk kopyalar `app/fonts/Lexend-*.ttf` altında da var; `pubspec.yaml` **`fonts/Lexend-*.ttf`** yolunu kullanıyor (ikisi de HTML).
   - Hex başlık: `<!DOCTYPE` — gerçek TTF magic (`00 01 00 00` / `OTTO`) yok.
   - Tüm marka tipografisi sistem yedek fontuna düşüyor. Temmuz 2026 denetiminde tespit edildi, **hâlâ düzeltilmedi**.

2. **Uygulama İkonu & Splash Görselleri Yok (Kritik):** ✅ **DOĞRULANDI**
   - `assets/images/` ve `assets/icons/` tamamen boş (yalnızca `.gitkeep`).
   - Eksik dosyalar: `app_icon.png`, `splash_logo.png`, `splash_logo_dark.png`.
   - `pubspec.yaml` `flutter_launcher_icons` ve `flutter_native_splash` yapılandırmaları bu klasördeki dosyaları referans alıyor — araçlar çalıştırılırsa hata verir, mağaza yapısı varsayılan ikonla derlenir.

3. **`.kilo/` Klasörü Git'te (node_modules Dahil):** ✅ **DOĞRULANDI (nüanslı)**
   - `git ls-files` içinde **6 dosya** izleniyor: `.kilo/kilo.json`, `.kilo/plans/*`, `.kilo/skills/*`.
   - Diskte `.kilo/node_modules/` **var**, ancak **git'te izlenmiyor** (planın "node_modules dahil" ifadesi abartılı; klasörün kendisi yine de depoya girmemeli).
   - `app/lib/l10n/app_localizations.dart.bak` diskte **var**, **untracked** (izlenmiyor).
   - Kök `.gitignore` içinde `.kilo/` ve `*.bak` kuralı **yok**.

4. **`.env` Asset Olarak Paketleniyor + Dosya Fiziksel Olarak Yok:** ⚠️ **KISMEN GÜNCEL DEĞİL**
   - `pubspec.yaml:127` `.env`'i asset listesine almış → derlenmiş APK/IPA içine gömülür (unzip ile çıkarılabilir). **Hâlâ geçerli.**
   - `dotenv.load(fileName: ".env")` — `isOptional: true` **yok**. **Hâlâ geçerli.**
   - ~~`app/.env` fiziksel olarak yok~~ → **01.08.2026:** `app/.env` **mevcut** (744 B, Firebase anahtarları; gitignore'da). Kök `.env` boş (0 B).
   - `.env.example` zaten var: `app/.env.example`. Faz 0.4'teki "örnek oluştur" adımı kısmen tamamlanmış; asıl kalan iş asset listesinden çıkarmak + optional load.

---

### ⚠️ B. Monolitik Canavarlar ve Spagetti Kod (Tight Coupling & Monoliths)

> **Uygulama:** → [Faz 2.1](#21-courseprovider--notemoodle-bölme) · [Faz 3.1](#31-ekran-bölme-haritası)

> **Doğrulama notu (01.08.2026 yeniden tarama):** Satır sayıları `wc -l` ile yeniden ölçüldü; metot envanteri `rg` ile çıkarıldı. **Tüm iddialar doğrulandı.**

- **Aşırı Yüklü Provider'lar:** ✅ **DOĞRULANDI**
  | Dosya | Satır | Sorumluluk karışımı (kanıt) |
  |---|---:|---|
  | `CourseProvider` | **982** | Course CRUD + absence + grade + file/link + bildirim planlama + mute + sample data; 4 repo inline (`CourseRepository`, `AbsenceRepository`, `GradeRepository`, `FileRepository`) + `NotificationService`/`FileService`/`SyncService` çağrıları |
  | `NoteProvider` | **543** | text/PDF/OCR/image note CRUD + ses kayıt/oynatma/seek + drawing save + search/bookmark; `NoteRepository` + `OcrService` + `FileService` + `AudioService` inline |
  | `MoodleProvider` | **377** | hesap CRUD + syncAll/syncAccount + 6 veri tipi cache (courses/assignments/grades/announcements/events/messages); `MoodleAccountRepository` + `MoodleSyncService` + `MoodleApiService` inline |

- **Devasa UI Dosyaları:** ✅ **DOĞRULANDI** (satırlar birebir uyuyor)
  - `note_detail_screen.dart` — **1.302**
  - `course_detail_screen.dart` — **1.075**
  - `moodle_course_detail_screen.dart` — **803**
  - `home_screen.dart` — **804**
  - `settings_e2e_section.dart` — **849**
  - `storage_screen.dart` — **801**

- **Devasa Servisler:** ✅ **DOĞRULANDI**
  - `sync_service.dart` — **970** satır: encrypt/decrypt, backup, restore, cloud delete, connectivity, KVKK deleteAllUserData, E2E upload helpers — tek sınıfta.
  - `database_helper.dart` — **692** satır.

---

### ⚠️ C. Dependency Injection (DI) Eksikliği & Bağımlılık Hataları

> **Uygulama:** → [Faz 2.0 DI deseni](#20-di-deseni-standart) · [Faz 1.2](#12-pubspecyaml-bağımlılıkları)

> **Doğrulama notu (01.08.2026 yeniden tarama):** Import ve inline `= Xxx()` taraması yapıldı. **Doğrulandı; küçük nüanslar eklendi.**

- **Inline Instantiation:** ✅ **DOĞRULANDI**
  - `CourseProvider`: `CourseRepository()`, `AbsenceRepository()`, `GradeRepository()`, `FileRepository()` alan olarak; silme akışında ek olarak `NoteRepository()`, `FileService()`, `SyncService()`, `AutoSyncService()`.
  - `NoteProvider`: `NoteRepository()`, `OcrService()`, `FileService()`, `AudioService()`.
  - `MoodleProvider`: `MoodleAccountRepository()`, `MoodleSyncService()`, `MoodleApiService()`.
  - Ayrıca: `SyncProvider` → `SyncService()`; `PlannerEventProvider` → `PlannerEventRepository()`; `DeadlineProvider` → `DeadlineRepository()` + `CalendarService()`.
  - Constructor injection yok → unit testte mock enjekte edilemiyor.

- **Dış Servis Bağımlılığı:** ✅ **DOĞRULANDI**
  - `SharedPreferences.getInstance()`: `AuthProvider`, `CourseProvider`, `LanguageProvider`, `ThemeProvider`.
  - `NotificationService()`: `CourseProvider` (schedule/cancel/dispose).
  - `url_launcher` / `launchUrl`: `CourseProvider.openFile` (satır ~879–880).

- **Eksik Dependency Bildirimleri (Korsan Import'lar):** ✅ **DOĞRULANDI**
  | Paket | Import yeri | pubspec |
  |---|---|---|
  | `flutter_cache_manager` | `storage_screen.dart` | **yok** |
  | `mockito` | `test/screens/auth_flow_test.dart` | **yok** (`mocktail` var, test onu kullanmıyor) |
  | `sqflite` | repositories + `database_helper` + `auto_sync_service` + `test_helpers` | **doğrudan yok** (`sqflite_sqlcipher` var; transitive olabilir ama `depend_on_referenced_packages` ihlali) |

- **Ölü Bağımlılık:** ✅ **DOĞRULANDI**
  - `sqflite_common_ffi_web` (pubspec:26) — `lib/` ve `test/` içinde **sıfır** import; yalnızca pubspec'te geçiyor.

---

### ⚠️ D. Veri Tutarsızlığı ve Durum Senkronizasyon Hataları (State Desynchronization)

> **Uygulama:** → [Faz 2.3](#23-state-desync--kalanlar)

> **Doğrulama notu (01.08.2026 yeniden tarama):** Orijinal iki iddia **büyük ölçüde düzeltilmiş**; artık farklı kalan riskler var.

- **Devamsızlık Takibinde Mantık Çelişkisi:** ⚠️ **KISMEN ESKİ / DÜZELTİLMİŞ**
  - ~~Takvim doğrudan `AbsenceRepository`'ye yazıyor~~ → **Artık yanlış.** `AbsenceCalendarTab` yazma yolları `CourseProvider.addAbsenceAt` / `removeAbsenceById` / `updateAbsenceReasonById` kullanıyor; bu metotlar `_courses` güncelliyor + `notifyListeners()`.
  - `AbsenceTrackerCard` hâlâ parent callback ile `CourseProvider.addAbsence` çağırıyor (`course_detail_header_info.dart`) — tutarlı.
  - Takvim **okuma** için hâlâ kendi `AbsenceRepository` örneğini kullanıyor (`_loadAbsences`) — yazma desync'i değil, UI yeniden yükleme deseni.
  - **Kalan risk:** `AttendanceAutomationService` arka planda doğrudan `absenceRepo.insertAbsence(...)` yapıyor; `Course.currentAbsences` / `CourseProvider` state'ini güncellemiyor. Otomatik yoklamadan gelen devamsızlıklar uygulama yeniden yüklenene kadar kartta görünmeyebilir. `SyncService` restore da benzer şekilde doğrudan repo yazıyor.

- **Çok Sayfalı PDF Çizim Notu Kaybı:** ⚠️ **BÜYÜK ÖLÇÜDE DÜZELTİLMİŞ**
  - ~~`note_detail_screen` yalnızca 1. sayfayı çiziyor~~ → **Artık yanlış.** `_DrawingDisplayWidget` `strokesByPage` parse ediyor, `PageController` + sayfa sayacı UI var (~satır 951–1090).
  - Düzenleme tarafı (`handwriting_canvas_screen.dart`): PDF modunda `_strokesByPage[_currentPdfPage]` doğru; blank/photo modları sayfa 1'e yazıyor (tek sayfa — beklenen).
  - Kayıt formatı: `{"strokesByPage": {...}, "totalPages": N}` JSON.
  - **Kalan risk / doğrulama borcu:** PDF sayfa değişiminde stroke kaybı edge-case'i manuel test edilmeli; görüntüleyici hâlâ çizimleri **PDF üzerinde değil** boş/şeffaf tuvalde sayfa sayfa gösteriyor (PDF arka planı display path'te yok — ürün kararı mı bug mı net değil).

---

### ⚠️ E. Pazarlama Vaatleri vs. Kod Gerçekliği (Eksik & Halüsinasyon Özellikler)

> **Uygulama:** stylus → [Faz 3.2](#32-stylus--çizim); program üretici → [Faz 4b](#4b--ürün-kararı-backlog)

> **Doğrulama notu (01.08.2026 yeniden tarama):**

- **"Otomatik Ders Programı Oluşturucu" Yanılsaması:** ✅ **DOĞRULANDI (hâlâ yok)**
  - `lib/` içinde backtracking / CSP / schedule optimizer / optimal program algoritması **yok** (yalnızca UI `BoxConstraints` ve Workmanager `Constraints` eşleşmeleri).
  - `WeeklyTimetableScreen` mevcut `course.scheduleDays` verisini grid'e basan **pasif** görüntüleyici.

- **"Apple Pencil Hissi" Illüzyonu:** ⚠️ **ESKİ — KOD GÜNCELLENMİŞ**
  - ~~Sadece `GestureDetector` ile (x,y)~~ → **Artık yanlış.** `drawing_canvas.dart` `Listener` + `PointerDeviceKind` kullanıyor:
    - Stylus / invertedStylus / mouse / touch kabul; diğer kind'lar reddediliyor (~satır 138–143).
    - Touch için `radiusMajor > 25` palm rejection (~146–147).
    - `_normalizedPressure(event.pressure)` ile basınç noktalara yazılıyor (~158, 172, 204+).
  - **Kalan nüanslar:**
    - Serileştirmede `toMap()` yalnızca `{x,y}` kaydediyor — **pressure persist edilmiyor** (yeniden açınca stroke kalınlık varyasyonu kaybolur).
    - `StrokeOptions.simulatePressure: false`.
    - **Tilt** hâlâ yok.
    - Yorumda hâlâ "Apple Pencil feel / support" ifadesi var; özellik kısmen gerçek, abartı azaltılmış.

---

### ⚠️ F. Dart & Flutter Statik Analiz Uyarıları (`flutter analyze` — 69 Sorun)

> **Uygulama:** → [Faz 1.1](#11-flutter-analyze-69--0)

> **Doğrulama notu (01.08.2026 yeniden tarama):** `flutter analyze` yeniden koşuldu → **69 issues found** (0 error). Kural dağılımı aşağıda.

- **Async Gap / BuildContext Riski:** ✅ **DOĞRULANDI — hâlâ 27**
  - `use_build_context_synchronously`: **27** (en yüksek kural).

- **Deprecated API Kullanımları:** ⚠️ **KISMEN İYİLEŞMİŞ**
  - `deprecated_member_use`: **5** (analyze).
  - `withOpacity`: lib içinde **yalnızca 1** kaldı (`moodle_assignments_tab.dart:75`) — planın genel "withOpacity kullanımı" ifadesi abartılı kalmış; çoğu `.withValues()`'a geçmiş.
  - `encryptedSharedPreferences: true` hâlâ 2 yerde: `moodle_token_storage.dart`, `secure_storage_service.dart`.

- **Print Disiplinsizliği:** ⚠️ **NÜANSLI**
  - Toplam `print` + `debugPrint`: **229** (1 `print`, **228** `debugPrint`) — sayı doğru.
  - ~~`avoid_print` kapalı~~ → **Yanlış/yanıltıcı.** `analysis_options.yaml` içinde `avoid_print: false` **yorum satırı** (devre dışı bırakma kapalı); `flutter_lints` varsayılanında `avoid_print` **açık**. `debugPrint` bu kurala takılmaz; asıl gürültü `debugPrint` yoğunluğu.

- **Diğer analyze kırılımı (01.08.2026):**  
  `depend_on_referenced_packages` 12 · `constant_identifier_names` 6 · `unused_field` 4 · `curly_braces_in_flow_control_structures` 4 · `unused_import` 3 · diğerleri ≤2.

---

### ⚠️ G. Test Altyapısı Kırıklıkları & Flakiness

> **Uygulama:** → [Faz 0.5](#05-kırık--flaky-testler) · [Faz 1.3](#13-test-altyapısı)

> **Doğrulama notu (01.08.2026 yeniden tarama):** Test dosyaları statik incelendi; flakiness için full `flutter test` bu turda koşulmadı (zaman). Kod kanıtları:

- **72 test:** ✅ `test/` altında 15 `*_test.dart`, ~72 `test(`/`testWidgets(` — sayı uyuyor.
- **`auth_flow_test.dart`:** ✅ **DOĞRULANDI**
  - `import 'package:mockito/mockito.dart';` — pubspec'te **mockito yok** (`mocktail` var).
  - Hardcoded EN: `expect(find.text('Email Address')…)`, `'Log In'`, `'Continue as Guest'`, `'Forgot Password?'`.
  - `MaterialApp` locale **zorlanmıyor** → cihaz/varsayılan locale (çoğu ortamda TR) ile EN string araması çakışır.
- **`home_screen_test.dart` / `add_course_screen_test.dart`:** ⚠️ **KISMEN**
  - Bunlar **`mocktail`** kullanıyor (mockito değil) — planın "aynı mockito" genellemesi yanlış.
  - `home_screen_test` `mockLanguageProvider.locale` → `Locale('en')` set ediyor; locale sorunu auth kadar net değil; flakiness hâlâ timing/`pumpAndSettle` kaynaklı olabilir.
- **Flaky 6–11 fail:** Bu oturumda yeniden koşulmadı — önceki ölçüm olarak bırakıldı; 3× `flutter test` ile teyit borcu açık (Faz 0.5 / 1.3).

---

### ⚠️ H. Diğer Bulgular & Git Çöplüğü

> **Uygulama:** git → [Faz 0.3](#03-git-çöpü-kilo-bak); imza → [Faz 0.6](#06-android-release-imzalama); CI → [Faz 1.4](#14-ci-github-actions)

> **Doğrulama notu (01.08.2026 yeniden tarama):**

- **Git Temizliği Eksiği:** ✅ **DOĞRULANDI (nüanslı)**
  - `.kilo/` → 6 dosya hâlâ tracked; `node_modules` diskte var ama untracked.
  - `*.bak` → `app_localizations.dart.bak` diskte, **untracked** (izlenmiyor).
  - Kök `.gitignore` log/PDF/env temizliğini kapsıyor; **`.kilo/` ve `*.bak` hâlâ yok**.

- **Web Desteği Yarı Yolda:** ✅ **DOĞRULANDI**
  - `database_helper.dart` `get database` → `if (isWeb) throw UnsupportedError('SQLite is not supported on web');` (satır ~48 civarı; satır numarası kaymış olabilir, davranış aynı).

- **Android Release İmzası:** ✅ **DOĞRULANDI**
  - `app/android/app/build.gradle.kts` release: `signingConfig = signingConfigs.getByName("debug")` + TODO yorumu.

- **Erişilebilirlik Kısıtı (TextScaler 0.8–1.2×):** ❌ **ARTIK YOK**
  - `main.dart` `MaterialApp` içinde TextScaler/clamp **bulunamadı**. Bu madde kapanmış sayılır; Faz 3.3'teki "TextScaler kısıtını kaldır" adımı **gereksiz** (Semantics ekleme hâlâ geçerli olabilir).

- **Moodle Dosya Entegrasyonu:** ⚠️ **KISMEN DÜZELTİLMİŞ**
  - Hâlâ varsayılan/seçenek olarak `OpenFilex.open` / external launch var.
  - **Yeni:** indirilmiş dosyada bottom sheet → **`addAsNote`** (`_OpenAction.addAsNote` → `_addDownloadedFileAsNote`). Tam otomatik "Moodle PDF ↔ not sistemi" değil ama UI bağlantısı eklenmiş.
  - CI: `.github/workflows` **yok** — CI iddiası hâlâ geçerli.

---

### ✅ I. Son Denetimden Bu Yana Yapılmış İyileştirmeler (Doğrulandı)

| Öğe | Durum |
|---|---|
| `flutter_background_service` bağımlılığı | Kaldırılmış ✓ (01.08.2026: pubspec/lib'te yok) |
| `vibration` bağımlılığı | Kaldırılmış ✓ |
| `exportCanvasToImage()` ölü kodu | Silinmiş ✓ |
| Kök `.gitignore` | Eklenmiş ✓ (ancak `.kilo/` ve `*.bak` kapsam dışı) |
| Kök dizin rapor karmaşası (17 dosya) | `docs/` içinde konsolide edilmiş ✓ |
| SqlCipher test mock (setUp patlaması) | Düzeltilmiş ✓ (provider testleri geçiyor) |

#### 01.08.2026 yeniden taramada ek olarak düzelmiş / kısmen düzelmiş bulunanlar

| Öğe | Durum |
|---|---|
| Takvim → `CourseProvider` devamsızlık yazımı | Düzelmiş ✓ (D maddesi güncellendi) |
| Çok sayfalı PDF çizim görüntüleme + kaydetme | Büyük ölçüde düzelmiş ✓ (D) |
| Stylus basınç + palm rejection (`Listener`) | Eklenmiş ✓ (E; pressure serileştirme eksik) |
| `withOpacity` kitlesel kullanımı | ~1 kalana inmiş ✓ (F) |
| TextScaler 0.8–1.2 clamp | Kaldırılmış ✓ (H) |
| Moodle dosya → "Nota ekle" | Kısmen eklenmiş ✓ (H) |
| `app/.env` fiziksel varlığı | Mevcut ✓ (A.4; asset paketleme riski sürüyor) |
| `app/.env.example` | Mevcut ✓ |

---

### 📁 J. Boş Dosyalar, Çift Yapılar & Repo Hijyeni (01.08.2026 tarama)

> **Uygulama:** → [Faz 0.3](#03-git-çöpü-genişletilmiş) · [Faz 0.7](#07-asset--klasör-yapısı-tekilleştirme) · [Faz 2.5](#25-servis-klasör-birleştirme-opsiyonel)

#### J.1 Boş / anlamsız dosyalar

| Path | Durum | Aksiyon |
|---|---|---|
| `v` (kök, 0 B) | **Git’te tracked** — boş, isim anlamsız | Sil + untrack |
| kök `.env` (0 B) | Boş; gerçek env `app/.env` | Sil (veya dokümante et: kullanılmıyor) |
| `app/assets/icons/.gitkeep` | Klasör boş (yalnızca gitkeep) | İkon gelene kadar kalabilir; yoksa klasörü kaldır + pubspec’ten çıkar |
| `app/assets/images/.gitkeep` | Aynı — ikon/splash yok | 0.2 ile doldur veya geçici placeholder |
| `app/assets/models/.gitkeep` + `README.md` (“placeholder content”) | **Hiçbir `lib/` referansı yok**; pubspec’te `assets/models/` var | Klasörü kaldır **veya** ML model gerçekten eklenecekse dokümante et; şimdilik ölü |
| `app/lib/l10n/app_localizations.dart.bak` | Untracked yedek | Sil |
| `app/.flutter-plugins-dependencies 2` | macOS kopya artifact (untracked) | Sil; gitignore’a `* 2` / `* 2.*` opsiyonel |

#### J.2 Git’te tracked çöp (gitignore’da olsa bile hâlâ index’te)

`.gitignore` kuralları **sonradan** eklendiği için şu dosyalar **hâlâ izleniyor**:

| Path | Not |
|---|---|
| `.DS_Store` | Kök; macOS |
| `iconoriginal.pdf` (~116 KB) | Tasarım kaynağı — `docs/assets/` veya repo dışı; kökte olmamalı |
| `app/analyze_output.txt`, `app/dart_analysis.txt`, `app/dart_files.txt` | Eski analiz dökümleri |
| `app/test_logs.txt`, `app/test_output.txt` | Test log kopyaları |
| `app/xcodebuild_log.txt` | Diskte **~18 MB** — repo şişirir |
| `app/fix_opacity.py` | Tek seferlik script; `scripts/` veya sil |
| `v` | Boş |

**Aksiyon:** `git rm --cached` (+ sil) + gitignore’da zaten varsa yeterli; yoksa ekle (`*.pdf` kök istisnası dikkat, veya sadece `iconoriginal.pdf`).

Untracked ama diskte gürültü: `app/flutter_01.log` … `flutter_03.log` (gitignore `flutter_*.log` ile kapsanmış olmalı).

#### J.3 Asset / font çift yapısı

```
app/fonts/Lexend-*.ttf          ← pubspec `fonts:` BUNU kullanıyor (HTML sahte)
app/assets/fonts/Lexend-*.ttf   ← AYNI bozuk kopya; pubspec fonts’ta YOK; yine git’te
app/assets/images/              ← boş (.gitkeep); launcher/splash path’leri buraya bakıyor
app/assets/icons/               ← boş
app/assets/models/              ← ölü placeholder
```

| Problem | Etki |
|---|---|
| İki font dizini | Hangisi “kaynak” belirsiz; 0.1’de tek path seç (`app/fonts/` pubspec ile uyumlu), `assets/fonts/` **sil** |
| pubspec `assets/images/`, `icons/`, `models/` | Boş klasörler asset bundle’a girer (zararsız ama yanıltıcı) |
| `iconoriginal.pdf` kökte | İkon kaynağı planlı kullanılmıyor; 0.2 ile ilişkilendir veya arşivle |

#### J.4 `lib/` katman yapı tutarsızlığı

| Gözlem | Detay |
|---|---|
| **Çift services kökü** | `lib/core/services/` (~25 dosya: sync, audio, OCR, E2E, notification…) vs `lib/services/` (home_widget + `moodle/*` API/sync/token). Moodle “background” `core/services`, Moodle API `services/moodle` — keşif zor |
| **Widgets çift yer** | Feature-local: `screens/home/widgets/`, `screens/course_detail/widgets/` · Shared: `widgets/home/home_widgets.dart` (806 satır monolit), `widgets/course/`, `widgets/deadlines/` — kural belirsiz |
| **Docs çift yer** | Kök `docs/` (asıl) + `app/docs/FIREBASE_TASKS.md` (tek dosya, dağınık) |
| **Platform fazlalığı** | `web/`, `macos/` mevcut; SQLite web’de `UnsupportedError` — yarı destek |
| **Kök `build/`** | `build/.last_build_id` — genelde `app/` altından çalışılır; kök build kafa karıştırır |
| **functions/** | `index.js` + `package.json` — OK, ama kök README’de net değil |

**Hedef kural (öneri):**

```
lib/
  core/          # theme, db, exceptions, utils, constants
  services/      # TÜM servisler (moodle/ alt klasör dahil)  ← core/services buraya taşınır (Faz 2.5)
  models/
  repositories/
  providers/
  screens/<feature>/{,tabs,widgets}/
  widgets/       # yalnızca ≥2 feature’da paylaşılan
  l10n/
```

- Feature’a özel widget → `screens/<feature>/widgets/`
- Paylaşılan → `lib/widgets/<domain>/`
- `widgets/home/home_widgets.dart` monolit → home feature widgets’a veya domain dosyalarına (Faz 3)

#### J.5 Özet etki

| Öncelik | Ne | Neden |
|---|:---:|---|
| P0 | Tracked log/PDF/`.DS_Store`/`v` temizliği | Repo hijyeni, klon boyutu (`xcodebuild_log` ~18MB disk) |
| P0 | Font tekilleştirme (`fonts/` vs `assets/fonts/`) | 0.1 ile birlikte |
| P1 | Boş `assets/models` + pubspec satırı | Ölü config |
| P1 | macOS kopya `* 2` dosyaları | Gürültü |
| P2 | `core/services` → `services` birleştirme | Mimari netlik (import churn — ayrı PR) |
| P2 | widgets yerleşim kuralı + `home_widgets` split | Faz 3 ile |
| P3 | `app/docs` → kök `docs`; web/macos stratejisi | Dokümantasyon |

---


## 🛠️ 04 — Refactoring Yol Haritası & Görev Listesi (Detaylı)

Her iş kalemi şu şablonu kullanır: **Amaç · Dosyalar · Adımlar · Kabul · Risk · Doğrulama**.

> **Bu listeyi kodlamadan önce** [§08 Uygulama Kılavuzu](#-08--uygulama-kılavuzu-how-to-execute) oku: sıra, branch, PR tanımı, gate kuralları ve “yapma” listesi orada.

### 4.0 Genel ilkeler

1. **Küçük, yeşil PR’lar:** Her PR `flutter analyze` + `flutter test` yeşil olmadan merge yok (CI geldikten sonra zorunlu).
2. **Davranış koruma:** UI split ve provider split’te public API mümkün olduğunca aynı kalır veya ince facade ile korunur.
3. **Önce ölç, sonra böl:** Satır sayıları ve `flutter analyze` sayıları her faz başında not edilir.
4. **Test stratejisi iki katman:**
   - Provider testleri: gerçek FFI SQLite (`test_helpers` + `testOpenDatabaseOverride`) — mevcut desen.
   - Widget testleri: **mocktail** ile provider mock — `auth_flow` de buna hizalanır.
5. **DI kuralı (Faz 2’den itibaren):** Bağımlılıklar **constructor parametresi** ile alınır (`XxxRepository? repo` + `?? XxxRepository()` default). Alan üzerinde `= XxxRepository()` kullanılmaz. Testte mock enjekte edilir; `main.dart` MultiProvider’da gerçek implementasyon verilir.
6. **State kuralı:** Domain yazımı (absence/course/note) UI veya background’dan **doğrudan repo’ya gitmez**; provider/facade üzerinden gider veya “state invalidation” event’i yayınlanır.
7. **Kapsam dışı (bilinçli):** Riverpod göçü, get_it/injectable, web için tam SQLite desteği (ayrı ürün kararı).
8. **Tek yön:** Faz 0 → 1 → 2 → 3 → 4a. Gate geçilmeden sonraki faza **özellik** işi açılmaz (istisna: §08.4 paralel izinler).

---

### 🔹 Faz 0: Yayın Blokörleri (Release Blockers — 1–2 gün)

**Gate:** 0.1 + 0.3 + 0.4 + 0.7 zorunlu; 0.2/0.6 asset/keystore’a bağlı; 0.5 yeşil test. Ayrıntı: §J.

#### 0.1 Lexend fontları

| | |
|---|---|
| **Amaç** | Marka tipografisinin sistem yedeğine düşmesini durdurmak |
| **Dosyalar** | `app/fonts/Lexend-*.ttf` (pubspec kaynağı); `app/assets/fonts/Lexend-*.ttf` (**yinelenen — silinecek**); `app/pubspec.yaml` → `fonts:` |
| **Adımlar** | 1) Google Fonts’tan gerçek TTF indir → **yalnızca** `app/fonts/`. 2) `app/assets/fonts/` dizinini tamamen sil (`git rm -r`). 3) `file app/fonts/Lexend-Regular.ttf` → TrueType. 4) Hex `00 01 00 00` / `OTTO`. 5) UI görsel kontrol. |
| **Kabul** | `file` HTML demez; tek font kökü `app/fonts/`; `assets/fonts` yok |
| **Risk** | Yanlış dosya/lisans; eski path referansı kalırsa (grep `assets/fonts`) |
| **Doğrulama** | `file app/fonts/Lexend-*.ttf`; `test ! -d app/assets/fonts` |

- [x] **0.1** Lexend gerçek TTF + `assets/fonts/` yinelenenini kaldır

#### 0.2 App icon & splash

| | |
|---|---|
| **Amaç** | Mağaza/derleme varsayılan Flutter ikonundan çıkmak |
| **Dosyalar** | `app/assets/images/app_icon.png`, `splash_logo.png`, `splash_logo_dark.png`; `app/pubspec.yaml` (`flutter_launcher_icons`, `flutter_native_splash`); üretilen `android/` / `ios/` asset’leri |
| **Adımlar** | 1) En az 1024×1024 `app_icon.png` koy. 2) Splash logoları ekle. 3) `dart run flutter_launcher_icons`. 4) `dart run flutter_native_splash:create`. 5) Cihazda cold start görsel kontrol. |
| **Kabul** | Komutlar hatasız; launcher + native splash doğru |
| **Risk** | Tasarım asset yoksa madde “asset hazır olunca” kalır; geçici placeholder + TODO kabul edilebilir |
| **Doğrulama** | İkon/splash komutları exit 0; cihaz smoke |

- [ ] **0.2** `assets/images/` + `assets/icons/` gerçek ikon/splash + generator çalıştır

#### 0.3 Git çöpü (genişletilmiş)

| | |
|---|---|
| **Amaç** | Tracked gürültü + boş dosyalar + ignore boşlukları (bkz. §J) |
| **Dosyalar** | `.kilo/*`; `*.bak`; `v`; kök `.env` (0 B); `.DS_Store`; `iconoriginal.pdf`; `app/analyze_output.txt`, `dart_analysis.txt`, `dart_files.txt`, `test_logs.txt`, `test_output.txt`, `xcodebuild_log.txt` (~18MB disk); `app/fix_opacity.py`; untracked: `app_localizations.dart.bak`, `app/.flutter-plugins-dependencies 2`, `app/flutter_0*.log` |
| **Adımlar** | 1) `.gitignore`’a ekle: `.kilo/`, `*.bak`, `v`, `iconoriginal.pdf` (veya `docs/design/`’e taşı), `* 2`, `* 2.*` (macOS duplicate). 2) `git rm -r --cached .kilo` (varsa). 3) `git rm --cached` + sil: log/txt dökümleri, `.DS_Store`, `v`, isteğe bağlı `fix_opacity.py`. 4) `iconoriginal.pdf` → ya sil ya `docs/design/iconoriginal.pdf` (ikon işi 0.2). 5) Untracked bak/kopya/log sil. 6) `git ls-files` doğrula. |
| **Kabul** | Aşağıdaki komutlar boş çıktı verir: `git ls-files \| rg -i '(\.kilo\|\.bak\|\.DS_Store\|xcodebuild\|test_output\|analyze_output\|^v$\|iconoriginal)'` |
| **Risk** | History’de büyük blob kalır ( purging ayrı iş ); `fix_opacity.py` ileride lazımsa önce `scripts/`’e taşı |
| **Doğrulama** | `git ls-files` + `du -sh app/*.txt app/*log* 2>/dev/null` |

- [x] **0.3** Git çöpü: `.kilo`, logs, `.DS_Store`, `v`, PDF, bak, macOS `* 2`

#### 0.4 `.env` asset + optional load

| | |
|---|---|
| **Amaç** | Secret’ların APK/IPA içine gömülmesini engellemek; CI/klon’da crash’i önlemek |
| **Dosyalar** | `app/pubspec.yaml` (`- .env` asset); `app/lib/main.dart` (`dotenv.load`); `app/.env.example` (mevcut) |
| **Adımlar** | 1) pubspec assets’ten `.env` satırını kaldır. 2) `await dotenv.load(fileName: ".env", isOptional: true);`. 3) `dotenv.env` / `env[` kullanan yerlerde null-safe fallback. 4) Mümkünse release artifact’ta `.env` olmadığını spot-check. |
| **Kabul** | `.env` asset listesinde yok; uygulama `.env` olmadan ayağa kalkar (Firebase kısıtlı olabilir, crash yok) |
| **Risk** | Env yokken throw eden path’ler — grep ile tarama zorunlu |
| **Doğrulama** | `rg '\.env' app/pubspec.yaml`; app cold start without env |

- [x] **0.4** `.env` asset’ten çıkar + `isOptional: true`

#### 0.5 Kırık / flaky testler

| | |
|---|---|
| **Amaç** | 72/72 stabil yeşil |
| **Dosyalar** | `app/test/screens/auth_flow_test.dart` (kritik); `home_screen_test.dart`, `add_course_screen_test.dart`; pubspec’e **mockito eklenmez** (`mocktail` var) |
| **Adımlar** | 1) `mockito` → `mocktail`. 2) `MaterialApp`’e `locale: const Locale('en')` **veya** l10n string assert. 3) Hardcoded EN string’leri sabitle/l10n. 4) `pumpAndSettle` timeout gözden geçir. 5) `flutter test` **3 kez** ardışık. |
| **Kabul** | 3× tam suite 72/72; `auth_flow_test` mocktail kullanır |
| **Risk** | Locale sabitleme bilinçli EN test ortamı demektir |
| **Doğrulama** | `cd app && flutter test` ×3 |

- [x] **0.5** auth_flow mocktail + locale; flakiness gider; 72/72 ×3

#### 0.6 Android release imzalama

| | |
|---|---|
| **Amaç** | Debug key ile release yayınını kesmek |
| **Dosyalar** | `app/android/app/build.gradle.kts` (`signingConfig = debug`); opsiyonel `key.properties` (**gitignore**); keystore **asla commit edilmez** |
| **Adımlar** | 1) Keystore oluşturma + backup prosedürünü dokümante et. 2) `signingConfigs.release` + `key.properties` okuma. 3) Release buildType’ı release config’e bağla. 4) CI secret notları (Faz 1.4). |
| **Kabul** | Dokümantasyon + lokal `key.properties` ile imzalı release build; repo’da secret yok. Keystore yoksa madde “prosedür + template” ile kapanır. |
| **Risk** | Keystore kaybı = mağaza güncelleme imkânsız |
| **Doğrulama** | `flutter build apk --release` (keystore ile) |

- [ ] **0.6** Release signing template + docs (keystore kullanıcıda)

#### 0.7 Asset & klasör yapısı tekilleştirme

| | |
|---|---|
| **Amaç** | Boş/ölü asset path’leri ve yanıltıcı klasörleri temizlemek (§J.3) |
| **Dosyalar** | `app/pubspec.yaml` assets listesi; `app/assets/models/`; `app/assets/icons/`; `app/assets/images/`; `app/docs/FIREBASE_TASKS.md`; kök `build/` |
| **Adımlar** | 1) `assets/models/` kullanımdışı → dizini sil + pubspec’ten `- assets/models/` kaldır. 2) `icons/` / `images/`: 0.2 asset gelene kadar `.gitkeep` OK; gelmeyecekse path’i pubspec’ten çıkarma. 3) `app/docs/FIREBASE_TASKS.md` → `docs/archive/` veya `docs/`. 4) Kök `build/` gereksizse sil (gitignore’da `build/`). 5) Hedef asset ağacı dokümante: yalnızca `assets/images/`, `assets/icons/` (+ dolu dosyalar); fontlar `app/fonts/`. |
| **Kabul** | pubspec’te ölü `models/` yok; `rg 'assets/models' app` boş; docs tek kök altında |
| **Risk** | Düşük |
| **Doğrulama** | `ls app/assets/`; `rg 'assets/models' app/pubspec.yaml` |

- [x] **0.7** Ölü `assets/models` + docs/`build` hijyeni; asset ağacı net

**Faz 0 gate (güncel):** 0.1 + 0.3 + 0.4 + 0.7 zorunlu; 0.2/0.6 asset/keystore’a bağlı; 0.5 yeşil test.

---

### 🔹 Faz 1: Temel Kod Sağlığı, Bağımlılıklar ve Test Altyapısı

**Gate:** analyze 0 issue · test 3× yeşil · CI dosyası main’de.

#### 1.1 `flutter analyze` 69 → 0

| Alt iş | Detay |
|---|---|
| **1.1a** | `use_build_context_synchronously` (~27): `await` sonrası `if (!context.mounted) return;` |
| **1.1b** | Deprecated: kalan `withOpacity` → `withValues(alpha:)` (`moodle_assignments_tab.dart:75`); `encryptedSharedPreferences: true` güncelle (`moodle_token_storage.dart`, `secure_storage_service.dart`) — paket breaking notunu oku |
| **1.1c** | `unused_field` / `unused_import` / `curly_braces_*` / `constant_identifier_names` — analyze listesine göre batch |
| **1.1d** | Logging: `avoid_print` zaten açık. 229 `debugPrint` için `AppLog` thin wrapper (`core/utils/app_log.dart` → debug’ta `debugPrint`, release’de no-op) **veya** kademeli azaltma. **Tam 0 debugPrint zorunlu değil**; hedef: ham `print` yok + kritik path’te Crashlytics/`ErrorHandler` |

| | |
|---|---|
| **Kabul** | `flutter analyze` → No issues found (veya gerekçeli satır ignore ≤5) |
| **Doğrulama** | `cd app && flutter analyze` |

- [x] **1.1** Analyze 69 → 0 (async gap, deprecated, unused, logging politikası)

#### 1.2 `pubspec.yaml` bağımlılıkları

| Aksiyon | Paket | Gerekçe |
|---|---|---|
| **Ekle** | `flutter_cache_manager` | `storage_screen.dart` import ediyor |
| **Ekle** | `sqflite` | repo + `database_helper` + `test_helpers` doğrudan import; `depend_on_referenced_packages` |
| **Zaten var** | `mocktail` | 0.5’te auth test buna geçer |
| **Kaldır** | `sqflite_common_ffi_web` | lib/test’te sıfır kullanım; web zaten `UnsupportedError` |

| | |
|---|---|
| **Kabul** | `flutter pub get` + analyze’da `depend_on_referenced_packages` = 0 |
| **Doğrulama** | `cd app && flutter pub get && flutter analyze` |

- [x] **1.2** Eksik deps ekle; ölü `sqflite_common_ffi_web` kaldır

#### 1.3 Test altyapısı

| | |
|---|---|
| **Dosyalar** | `app/test/test_helpers.dart`; tüm `*_test.dart` |
| **Adımlar** | 1) DB testlerinin `setupTestInfrastructure` (+ gerekirse secure storage / sqlcipher mock) kullandığını doğrula. 2) `DatabaseHelper.dbName` test bazında unique kalsın. 3) Flaky timing → `pump(Duration)`. 4) 3× `flutter test`. |
| **Kabul** | 3 ardışık 72/72 (veya N/N) |
| **Not** | Constructor injection sonrası fake repo örnekleri Faz 2’de |

- [x] **1.3** Test altyapısı standardize; 3× yeşil suite

#### 1.4 CI (GitHub Actions)

| | |
|---|---|
| **Dosya** | `.github/workflows/flutter_ci.yml` (**yeni**) |
| **Job** | `ubuntu-latest`: checkout → Flutter stable → `pub get` → `flutter analyze` → `flutter test` → `flutter build apk --debug` |
| **Tetik** | `pull_request` + `push` branches: `[main]` |
| **Kabul** | Workflow yeşil; analyze fail merge’i engeller |
| **Not** | Release imza job’u 0.6 + secrets sonrası |

- [x] **1.4** GitHub Actions CI ekle

---

### 🔹 Faz 2: Mimari & Provider (Constructor Injection)

**Gate:** Ana provider’larda DI · SyncService facade/split · automation desync kapalı · analyze+test yeşil.

#### 2.0 DI deseni (standart)

**Karar:** Constructor injection + mevcut `provider` — **get_it / Riverpod yok**.

```dart
class CourseProvider extends ChangeNotifier {
  CourseProvider({
    CourseRepository? courseRepo,
    AbsenceRepository? absenceRepo,
    GradeRepository? gradeRepo,
    FileRepository? fileRepo,
    NotificationService? notificationService,
  })  : _courseRepo = courseRepo ?? CourseRepository(),
        _absenceRepo = absenceRepo ?? AbsenceRepository(),
        _gradeRepo = gradeRepo ?? GradeRepository(),
        _fileRepo = fileRepo ?? FileRepository(),
        _notificationService = notificationService ?? NotificationService();

  final CourseRepository _courseRepo;
  // ...
}
```

`main.dart` (mevcut kayıt stili korunur):

```dart
ChangeNotifierProvider(create: (_) => CourseProvider()),
```

**Sıra:** CourseProvider → NoteProvider → MoodleProvider → SyncProvider / SyncService → diğerleri.

**Kapsam dışı bu fazda:** Repository’lere `DatabaseHelper` constructor DI (test hook `testOpenDatabaseOverride` yeterli).

- [x] **2.0** DI standardını tüm ana provider’lara uygula (breaking yok; default repo)

#### 2.1 CourseProvider / Note / Moodle bölme

Mevcut `course_provider.dart` (~982) kümeleri:

| Küme | ~Satır | Hedef |
|---|---|---|
| State + CRUD + mute + schedule conflict | 26–504 | **`CourseProvider`** (ince) |
| Notifications + SharedPreferences | 83–176 | **`NotificationScheduler`** service veya ince wrapper |
| Absences | 506–614 | **`AttendanceProvider`** (veya ilk PR’da sadece DI) |
| Grades | 616–736 | **`GradeProvider`** |
| Files / links / `launchUrl` | 738–899 | **`CourseFileService`** |
| Sample data | 901+ | CourseProvider veya dev helper |

**PR dilimi (davranış korumalı):**

1. **2.1a** Constructor injection (API aynı) — testler `CourseProvider()` ile çalışmaya devam eder.
2. **2.1b** `GradeProvider` — UI `context.read` **veya** CourseProvider facade delege (breaking yok tercih).
3. **2.1c** `AttendanceProvider` + kart senkronu.
4. **2.1d** File/open → service.

| Provider | Aksiyon |
|---|---|
| `NoteProvider` (~543) | DI: `NoteRepository`, `OcrService`, `FileService`, `AudioService`. Opsiyonel sonra: `NoteAudioController`. |
| `MoodleProvider` (~377) | DI: account repo, sync, api. `..initialize()` main’de kalsın. |

| | |
|---|---|
| **Kabul** | `course_provider_test` / grade / absence testleri yeşil; home + course detail smoke |
| **Risk** | Çok `watch<CourseProvider>` — ilk geçişte **facade** daha güvenli |

- [x] **2.1a** Constructor DI (Course/Note/Moodle/Sync) — *PR-2a*
- [x] **2.1b** GradeProvider (veya facade delege) — *PR-2d.1, PR-2d.2*
- [x] **2.1c** AttendanceProvider — *PR-2d.1, PR-2d.2*
- [x] **2.1d** CourseFileService (url_launcher/open_filex dışarı) — *PR-2d.3*

#### 2.2 SyncService bölme (facade)

| Yeni birim | Sorumluluk | Kaynak ~ |
|---|---|---|
| `SyncEncryption` | key/IV encrypt/decrypt | 85–128 |
| `SyncBackup` | `backupData` | 303–520 |
| `SyncRestore` | `restoreData` | 522–795 |
| `SyncBatchUtils` | chunk commit + retry | 798–875 |
| `SyncService` | public facade + `deleteAllUserData` / connectivity | public API **değişmez** |

| | |
|---|---|
| **Kabul** | `SyncProvider` + home restore aynı imzaları çağırır |
| **Dosyalar** | `lib/core/services/sync_service.dart` + yeni modüller aynı klasörde |

- [x] **2.2** SyncService facade + modül split (encryption + batch retry — part 1/2)

#### 2.3 State desync — kalanlar

##### 2.3.1 AttendanceAutomationService → UI state

| | |
|---|---|
| **Problem** | `absenceRepo.insertAbsence` doğrudan; `CourseProvider` bilmez → kartlar restart’a kadar bayat |
| **Öneri** | **AbsenceChangeBus** (basit `StreamController` singleton) veya restore/app-resume dirty flag. Automation (ve gerekirse repo) event yayınlar; `CourseProvider` subscribe → ilgili course reload. Background’dan doğrudan provider çağırmak (Workmanager) **tercih edilmez**. |
| **Aynı class** | `SyncService.restoreData` ~784 `insertAbsence` — restore sonrası **full** `loadCourses` zorunlu |
| **Dosyalar** | `attendance_automation_service.dart`, `course_provider.dart`, opsiyonel `absence_change_bus.dart`, `sync_service.dart` |
| **Kabul** | Simüle insert + event sonrası home/course kartı **restart olmadan** güncellenir |

- [x] **2.3.1** Automation/restore → CourseProvider senkronu (bus veya dirty reload)

##### 2.3.2 AbsenceCalendarTab dual read

| | |
|---|---|
| **Problem** | Tab kendi `AbsenceRepository` ile okuyor; yazma `CourseProvider` üzerinden |
| **Aksiyon** | Okumayı provider’dan (`loadAbsencesForCourse`) veya yazma sonrası provider dinlemesi; tab-level repo kaldır |
| **Kabul** | Takvim + header kart aynı absence sayısı |

- [x] Takvim **yazma** → CourseProvider (`addAbsenceAt` / `removeAbsenceById`) — *01.08.2026*
- [x] **2.3.2** Takvim **okuma** tek kaynaktan (provider)

##### 2.3.3 Drawing (Faz 3’e devir)

| Madde | Faz |
|---|---|
| Pressure `toMap`/`fromMap` | **3.2** (`v:2` + backward compat) |
| PDF arka plan display | **3.2** / ürün kararı |

- [x] Çok sayfalı PDF çizim görüntüleme + kaydetme — *01.08.2026*

#### 2.5 Servis klasör birleştirme (opsiyonel / mimari netlik)

| | |
|---|---|
| **Amaç** | `lib/core/services/` (~25) + `lib/services/` (moodle + home_widget) çift kökünü bitirmek (§J.4) |
| **Hedef** | Tüm servisler → `lib/services/` (`moodle/` alt klasör kalır); `core/` yalnızca database, theme, exceptions, utils, constants |
| **Adımlar** | 1) `git mv app/lib/core/services/*.dart app/lib/services/` (moodle çakışması yok). 2) Import path güncelle (`../core/services/` → `../services/` veya package import). 3) `flutter analyze`. 4) barrel `services.dart` **zorunlu değil**. |
| **Kabul** | `lib/core/services/` yok; analyze 0 yeni hata; testler yeşil |
| **Risk** | Yüksek import churn — **ayrı PR**; Faz 2a DI ile karıştırma |
| **Doğrulama** | `test ! -d app/lib/core/services`; `flutter analyze` |

- [x] **2.5** `core/services` → `services` birleştir — *PR-2.5*

**Widgets yerleşim kuralı (Faz 3 ile zorunlu):**

| Tür | Konum |
|---|---|
| Tek feature | `screens/<feature>/widgets/` |
| ≥2 feature paylaşılan | `lib/widgets/<domain>/` |
| Anti-pattern | `widgets/home/home_widgets.dart` 800+ satır “çöp çekmecesi” — domain dosyalarına böl |

---

### 🔹 Faz 3: UI Komponent Parçalama & Stylus & A11y

**Gate:** P0 ekranlar hedef satırda · `DrawingDataCodec` tek yerde · pressure persist veya bilinçli erteleme.

**Split sırası:** yaprak private widget → paylaşılan util → dialog → shell.

#### 3.1 Ekran bölme haritası

> **Doğrulama notu (11.08.2026):** Checkbox'lar uzun süre güncellenmemişti; gerçek `wc -l` + dosya varlığı taraması yapıldı. Sonuç: işin büyük kısmı fiilen tamamlanmış, ama hiçbiri işaretlenmemişti (bkz. §8.2 kural 6). Aşağıda her madde satır kanıtıyla güncellendi.

##### P0 — `note_detail_screen.dart` (1302 → ~300)

| Yeni dosya | Kaynak |
|---|---|
| `screens/note_detail/widgets/note_audio_player.dart` | `_AudioPlayerWidget` ~759–949 |
| `.../note_drawing_display.dart` | `_DrawingDisplayWidget` ~951–1141 |
| `.../note_pdf_display.dart` | `_PdfDisplayWidget` + `_PdfViewer` |
| `.../full_screen_image_viewer.dart` | ~1273–1298 |
| `.../move_note_sheet.dart` | ~586–757 |

- [x] **3.1.1** note_detail private widget extract — *kısmi: 1302 → 653 (hedef ~300); 5 dosyanın 5'i de var (`note_audio_player`, `note_drawing_display`, `note_pdf_display`, `full_screen_image_viewer`, `move_note_sheet`) — 11.08.2026*

##### P0 — `course_detail_screen.dart` (~1040 → ~350)

Tabs zaten ayrılmış (`course_*_tab`, app bar, header, toolbar). Kalan:

| Yeni dosya | Kaynak |
|---|---|
| `widgets/course_options_sheet.dart` | options + `_OptionTile` |
| `widgets/add_text_note_sheet.dart` | ~717–851 |
| `widgets/add_link_sheet.dart` | link dialog |
| actions helper | capture / OCR / image note |

- [x] **3.1.2** course_detail sheet/action extract — *1075 → 421 (hedef ~350, ±%20 içinde); `course_options_sheet`, `option_tile`, `add_text_note_sheet`, `add_link_sheet` + plandan fazlası (`course_add_deadline_sheet`, `course_add_grade_sheet`, `course_image_note_sheet`, `confirm_action_dialog`) — 11.08.2026*

##### P1 — `moodle_course_detail_screen.dart` (803 → ~200)

| Yeni dosya | Kaynak |
|---|---|
| `widgets/moodle_section_card.dart` | `_SectionCard` |
| `widgets/moodle_module_tile.dart` | `_ModuleTile` + `_OpenAction` (~560 satır) |

- [x] **3.1.3** moodle module/section extract — *803 → 191 (hedef ~200'ün altında); `moodle_section_card.dart` (`MoodleSectionCard`) ve `moodle_module_tile.dart` (`MoodleModuleTile`, eski `_ModuleTile`/`_ModuleTileState`) çıkarıldı — 11.08.2026*

##### P1 — `home_screen.dart` (805 → ~180)

| Yeni dosya | Kaynak |
|---|---|
| `widgets/home_content.dart` | `_HomeContent` public |
| `widgets/restore_cloud_dialog.dart` | restore dialog |
| `widgets/course_selection_sheet.dart` | **paylaşılan** (OCR, Moodle, note move) |
| bootstrap helper | `_loadData` device/restore/sample |

- [x] **3.1.4** home shell + paylaşılan course selection sheet — *804 → 248 (hedef ~180, ±%20 dışında ama yakın); 4 dosyanın 4'ü de var (`home_content`, `restore_cloud_dialog`, `course_selection_sheet` paylaşılan, bootstrap → `home_init_loader.dart`); ayrıca `home_widgets.dart` (806 satır monolit) tamamen silinmiş — 11.08.2026*

##### P1 — settings

| Dosya | Split |
|---|---|
| `settings_e2e_section.dart` (~849) | `security_questions_sheet.dart` + `core/services/security_questions_service.dart` |
| `storage_screen.dart` (~801) | size utils + optimization sheet + breakdown widgets |

- [x] **3.1.5** settings E2E + storage split — *`settings_e2e_section.dart` 849 → 479 (`security_questions_sheet.dart` + service ayrılmış); `storage_screen.dart` 801 → 642 (`directory_size_utils` + storage breakdown widget'ları ayrılmış, ama en büyük kalan dosya hâlâ bu) — 11.08.2026*

##### P2 — canvas / absence

| Dosya | Split |
|---|---|
| `handwriting_canvas_screen.dart` (~640) | mode layers + codec kullanımı |
| `absence_calendar_tab.dart` (~654) | reason sheets + summary; repo kaldır (2.3.2 ile) |

- [x] **3.1.6** handwriting + absence calendar extract — *`absence_calendar_tab.dart` 654 → 310, reason sheet'ler ayrılmış, doğrudan `AbsenceRepository` kullanımı yok (2.3.2 ile tutarlı); `handwriting_canvas_screen.dart` 641 → 470, mode seçici (`canvas_mode_selector.dart`) ve mode katmanları (`canvas_mode_views.dart`: `BlankCanvasView`/`PhotoCanvasView`/`PdfCanvasView`) ayrıldı — 11.08.2026*

##### Paylaşılan çıkarımlar

1. **`DrawingDataCodec`** — `strokesByPage` + legacy list (handwriting + note_detail).
2. **`CourseSelectionSheet`** — home / moodle / note move.
3. Opsiyonel: ortak confirm-delete dialog.

| | |
|---|---|
| **Kabul (her ekran PR’ı)** | Davranış aynı; widget testleri geçer; satır hedefi ±20% |

#### 3.2 Stylus / çizim

| Madde | Detay |
|---|---|
| Pressure persist | `DrawingStroke.toMap` → `{x,y,p?}`; `fromMap` default p; `simulatePressure` politikası dokümante |
| Format version | `{"v":2,"strokesByPage":...}` — v1 okunur |
| Tilt | **opsiyonel / 4b backlog** |
| PDF display background | pdfx alt katman + stroke üst; veya bilinçli “sadece stroke” ürün kararı |

- [x] `Listener` + stylus pressure + palm rejection — *01.08.2026*
- [x] Çok sayfalı PDF stroke saklama — *01.08.2026*
- [x] **3.2.1** Pressure persist (`v:2`) + codec tek yerde — *`core/utils/drawing_data_codec.dart`; `{"v":2,...}` formatı + v1 geri uyumlu okuma; hem `handwriting_canvas_screen.dart` hem `note_drawing_display.dart` bu codec'i kullanıyor — 11.08.2026*
- [x] **3.2.2** Display path PDF arka planı — *ürün kararı: PDF arka planı uygulandı (stroke-only değil). `note_drawing_display.dart` artık `pdfPath` alıyor, `pdfx` ile her sayfayı `page.render()` üzerinden görsele çevirip `DrawingCanvas`'ın (şeffaf arka plan) altına koyuyor; sayfa görselleri `Future` cache'te tutuluyor. `note_detail_screen.dart` PDF-destekli çizim notlarında ayrı `NotePdfDisplay`'i artık göstermiyor (çift gösterim önlendi) — 11.08.2026*

#### 3.3 Erişilebilirlik

| | |
|---|---|
| **Durum** | TextScaler 0.8–1.2 clamp **zaten yok** — kapalı |
| **Yapılacak** | Primary CTA, tab, FAB, devamsızlık ± → `Semantics` / `tooltip` |
| **Kabul** | TalkBack/VoiceOver: ders listesi → detay → not ekle |

- [x] TextScaler kısıtı kaldırılmış — *01.08.2026*
- [x] **3.3** Semantics etiketleri ana akışta — *kısmi: ders listesi (`ScheduleCard`/`PriorityCourseCard` → tek `Semantics` düğümü, ad+saat+konum), devamsızlık ± (`AbsenceTrackerCard` → `Semantics`+`Tooltip`, yeni l10n anahtarları `addAbsenceAction`/`removeAbsenceAction`, 4 dilde), not ekle CTA satırı (`CourseBottomToolbar` → her ikon `Semantics`+`Tooltip`), ana FAB (`HomeFAB` → hardcoded TR yerine `l10n.addNewCourse`) kapsandı. Sekmeler (`Tab(text:...)`) zaten Flutter'ın kendi semantics'ini kullanıyor. Gerçek cihazda TalkBack/VoiceOver ile doğrulanmadı — 11.08.2026*

---

### 🔹 Faz 4: Teknik cilalama (4a) & Ürün backlog (4b)

#### 4a — Teknik (refactor/teknik borç — yapılacak)

| ID | İş | Detay |
|---|---|---|
| **4a.1** | Freezed yaygınlaştırma | Sıra: `grade` → `deadline` → `course_file` → `planner_event` → `study_session` → `models/moodle/*`. Her PR: codegen + repo map uyumu + test. |
| **4a.2** | PDF/görsel cache | `cached_network_image` / `flutter_cache_manager` politikası; storage deep clean ile uyum |
| **4a.3** | Repository lifecycle standardı | Singleton vs plain tutarlılığı — düşük öncelik |
| **4a.4** | Web stratejisi dokümanı | `UnsupportedError` kalsın mı, web target düşürülsün mü |

- [x] **4a.1** Freezed: en az grade + deadline — *`Grade` ve `Deadline` `@freezed` sınıflarına çevrildi (`course.dart`/`note.dart` ile aynı desen: `const X._()` + `factory` + elle yazılmış `toMap`/`fromMap` korundu); `build_runner` ile `grade.freezed.dart`/`deadline.freezed.dart` üretildi. Not: `Grade`'in eski `==`/`hashCode`'u yalnızca `id` bazlıydı, Freezed varsayılanı tüm alanları karşılaştırıyor — kod tabanında hiçbir yerde nesne eşitliğine (`==`/`contains`/`Set`) bağlı kullanım yoktu (yalnızca `.id ==` karşılaştırmaları), bu yüzden davranış değişikliği yok. analyze 0, testler regresyonsuz — 11.08.2026*
- [ ] **4a.2** Cache politikası + ölçüm notu
- [ ] **4a.3** Repo lifecycle standardı (opsiyonel)
- [ ] **4a.4** Web destek kararı dokümante

**4a gate:** freezed grade+deadline; cache notları uygulanmış veya ölçülmüş.

#### 4b — Ürün kararı backlog (refactor zorunluluğu değil)

> Bu maddeler **teknik borç değildir**. Pazarlama/roadmap onayı olmadan kod yazılmaz.

| ID | Başlık | Mevcut kod | Karar sorusu | Onay sonrası iskelet |
|---|---|---|---|---|
| **4b.1** | Otomatik ders programı üretici | Yok; `WeeklyTimetableScreen` pasif grid | Vaat var mı? MVP+1? | Ayrı CSP/backtracking design doc |
| **4b.2** | Moodle ↔ yerel ders otomatik eşleşme | Manuel nota ekle / export | Otomatik mi, öneri mi? | Matching kuralları + UX |
| **4b.3** | Moodle PDF in-app annotate | download + `addAsNote` + ayrı handwriting | Tek akış mı? | open → handwriting PDF mode |
| **4b.4** | Full Pencil parity (tilt vb.) | Pressure live; persist 3.2 | Pazarlama dili sade mi? | Metin güncellemesi yeterli olabilir |

- [x] Moodle indirilmiş dosyada “Nota ekle” — *kısmi*
- [ ] **4b.*** Onaylanana kadar beklet (ürün)

---

## 🧪 05 — Doğrulama Planı (Faz Gate Tablosu)

| Gate | Komut / kontrol | Faz |
|---|---|---|
| Font | `file app/fonts/Lexend-*.ttf` → TrueType | 0.1 |
| Env | pubspec’te `.env` asset yok; `isOptional: true` | 0.4 |
| Git | `git ls-files` içinde `.kilo/` / `*.bak` yok | 0.3 |
| Test | `flutter test` ×3 → 72/72 (veya N/N) | 0.5, 1.3 |
| Analyze | `flutter analyze` → 0 issue | 1.1 |
| CI | GHA analyze + test + debug APK yeşil | 1.4 |
| DI | ≥1 provider testinde fake repo enjekte örneği | 2.0 |
| Desync | Automation/simülasyon sonrası UI refresh (restart yok) | 2.3 |
| UI split | P0 dosya satır hedefleri (±20%) | 3.1 |
| Manuel | Yoklama, Moodle sync, multi-page çizim, cloud restore | her major faz sonu |

### Manuel smoke checklist

1. Ders ekle → haftalık grid’de görün.
2. Devamsızlık: kart ±, takvim ekle/sil, sayılar eşit.
3. Smart attendance simülasyonu (veya bus event) → kart güncellenir.
4. Not: metin / ses / OCR / çizim (PDF multi-page) kaydet-reopen.
5. Moodle: sync, dosya indir, “Nota ekle”.
6. Ayarlar: E2E bölümü açılır; storage clean crash yok.
7. Misafir / login akışı (l10n EN test ortamı ile uyumlu).

---

## 📦 06 — PR Dilimleme Önerisi

| PR | İçerik | Bağımlılık |
|---|---|---|
| **PR-0a** | Fonts (tek path) + git çöpü (logs/DS_Store/`v`/PDF/`.kilo`) + env asset/optional + ölü `assets/models` | — |
| **PR-0b** | auth_flow mocktail + locale + test yeşil | — |
| **PR-0c** | Icons/splash (asset hazırsa) | tasarım |
| **PR-0d** | Android signing template + docs | keystore kullanıcıda |
| **PR-1a** | pubspec deps fix | — |
| **PR-2e** | `core/services` → `services` birleştirme | 2a sonrası tercih |
| **PR-1b** | analyze batch (`context.mounted`, deprecated, unused) | — |
| **PR-1c** | CI workflow | 1a/1b yeşil tercih |
| **PR-2a** | Constructor DI (breaking yok) | Faz 1 |
| **PR-2b** | Absence bus / automation + calendar read path | 2a |
| **PR-2c** | SyncService split facade | 2a |
| **PR-2d** | Grade/Attendance provider split | 2a–2b |
| **PR-3a** | note_detail widget extract | — |
| **PR-3b** | course_detail sheets | — |
| **PR-3c** | moodle module tile + home + `CourseSelectionSheet` | — |
| **PR-3d** | `DrawingDataCodec` + pressure v2 | — |
| **PR-4a** | freezed models batch | — |

Her PR açıklamasında: **davranış değişikliği (yok / şunlar)** + doğrulama komutları.

**Önerilen ilk kod işi:** `PR-0a` (fonts tek path + git çöpü + env + ölü assets).

---

## ⚠️ 07 — Riskler & Geri Dönüş

| Risk | Etki | Azaltma |
|---|---|---|
| Provider split UI kırılması | Yüksek | Önce facade + DI; split sonra |
| Drawing JSON format | Orta | `v` field + legacy parse |
| Env optional sonrası null | Orta | `dotenv` kullanım yerlerini grep + fallback |
| Release keystore kaybı | Kritik | Backup prosedürü; secret yönetişimi |
| Analyze “sıfır” takıntısı | Düşük | Gerekçeli ignore ≤5 |
| Büyük UI move merge conflict | Orta | Dosya bazlı sıralı PR; main sık rebase |

**Geri dönüş:** Her PR tek sorumluluk; `git revert` ile geri alınabilir. Facade dönemi eski public API’yi korur.

---

## 📎 Çapraz referans özeti (Analiz → Uygulama)

| Analiz (§03) | Uygulama |
|---|---|
| A Yayın blokörleri | Faz 0 |
| B Monolitler | Faz 2.1, 2.2, 3.1 |
| C DI + korsan deps | Faz 2.0, 1.2 |
| D State desync | Faz 2.3 (kalan); yazma path ✓ |
| E Pazarlama vs kod | 3.2 stylus; 4b özellikler |
| F Analyze | Faz 1.1 |
| G Test | Faz 0.5, 1.3 |
| H Git / imza / CI / Moodle kısmi | 0.3, 0.6, 1.4, 4b.3 |
| I Zaten düzelmiş | Yeniden yapma |
| J Boş dosya / çift yapı / tracked junk | 0.1, 0.3, 0.7, 2.5 |

---

## 🚀 08 — Uygulama Kılavuzu (How to Execute)

Bu bölüm planın **nasıl işletileceğini** anlatır. §03 “ne bozuk”, §04 “ne yapılacak”, §06 “hangi PR”, **§08 “hangi sırayla, hangi kurallarla, ne zaman bitti sayılır”**.

### 8.1 Dokümanı okuma sırası

| Sıra | Bölüm | Ne için |
|---:|---|---|
| 1 | §01 özet tablo | Mevcut durum hissi |
| 2 | §03 A–J (ilgili madde) | İşin *neden*i; doğrulama notları |
| 3 | **§08 (bu bölüm)** | Süreç kuralları |
| 4 | §04 ilgili faz kartı | Dosya / adım / kabul |
| 5 | §05 gate + §06 PR satırı | Bitti mi? Hangi PR? |
| 6 | §07 risk | Takılınca |

**Yapma:** §04 checklist’i baştan sona tek PR’da bitirmeye çalışma. **Yap:** §06’daki bir PR kimliğini seç → karttaki adımları uygula → gate komutları → merge → checkbox işaretle.

### 8.2 Altın kurallar (özet)

1. **Bir seferde bir PR-boyutu iş** — ideal: &lt; ~400 satır diff veya tek tema (fontlar *veya* test *veya* bir ekran extract).
2. **Davranış sabitle, yapı değiştir** — kullanıcı görünür regresyon yoksa refactor PR’ı “refactor only” işaretlenir.
3. **Ölç → değiştir → ölç** — PR öncesi/sonrası: `flutter analyze` issue sayısı, `flutter test`, kritik dosya `wc -l`.
4. **Gate geçmeden sonraki faza atlama** — özellikle Faz 0 bitmeden Faz 2 monolit split’e girme.
5. **Ana dal her zaman yeşil** — kırık `main` yasak; fix-forward veya revert.
6. **Plan checkbox = kaynak gerçeği** — iş bitince bu dosyada `- [x]` yap; ayrı gizli TODO listesi tutma.
7. **§I / zaten düzelmiş maddeleri yeniden “fix” etme** — zaman kaybı.
8. **4b ürün işleri** onaysız kodlanmaz; sadece metin/backlog güncellenir.

### 8.3 Faz sırası ve atlama kuralları

```
Faz 0 (blokör + hijyen) ──gate──► Faz 1 (analyze/test/CI) ──gate──► Faz 2 (DI + state)
                                      │
                                      └──gate──► Faz 3 (UI split) ──► Faz 4a (freezed/cache)
                                                      4b yalnızca ürün onayı
```

| Kural | Açıklama |
|---|---|
| **Zorunlu sıra** | 0 → 1 → 2.0 (DI) → 2.3 (desync) → 2.1 split / 2.2 sync |
| **Faz 3 erken başlayabilir mi?** | Evet, **yalnızca yaprak widget extract** (note_detail private widget → dosya), provider imzası değişmiyorsa. Provider split ile **aynı PR’da birleştirme**. |
| **Faz 2.5 services move** | DI (2.0) merge olduktan sonra ayrı PR; UI split PR’ları ile çakıştırma. |
| **Faz 4a** | 2–3 ile kısmen paralel (freezed model PR’sı ekran PR’sından bağımsız dosyalardaysa). |
| **0.2 / 0.6 asset-keystore** | Tasarım/keystore yoksa gate’i **bloklamaz**; checkbox “blocked: asset” notu ile açık kalır, diğer 0.x devam eder. |

### 8.4 Ne paralelde yapılabilir?

| Paralel OK | Aynı anda yapma |
|---|---|
| PR-0b (test) ∥ PR-0a (hijyen) — conflict az | CourseProvider split + note_detail extract + services move |
| PR-3a note_detail ∥ PR-3b course_detail (farklı path) | İki kişinin aynı monolit dosyayı bölmesi |
| freezed `grade` ∥ UI extract başka ekran | pubspec + büyük DI aynı PR |
| Dokümantasyon / § checkbox güncelleme her an | “Hepsini bir branch’te bitireyim” |

**Conflict riski yüksek dosyalar** (sıralı çalış): `course_provider.dart`, `sync_service.dart`, `main.dart`, `pubspec.yaml`, `note_detail_screen.dart`.

### 8.5 Branch ve PR işletim modeli

#### Branch isimlendirme

```
refactor/0a-fonts-git-env
refactor/0b-auth-flow-tests
refactor/1b-analyze-async-context
refactor/2a-constructor-di
refactor/3a-note-detail-split
```

`main` (veya `master`) ← kısa ömürlü branch ← squash veya merge commit (takım tercihi; **force-push main yok**).

#### Her PR’ın Definition of Done (DoD)

PR merge edilmeden **hepsi** sağlanmalı:

| # | Kontrol |
|---|---|
| 1 | Kapsam §04 kartı / §06 PR satırı ile sınırlı; “yanına şunu da sıkıştırayım” yok |
| 2 | `cd app && flutter analyze` — yeni hata yok (hedef: faz ilerledikçe 0) |
| 3 | `cd app && flutter test` — yeşil (Faz 0.5 sonrası 3× flaky kontrolü major PR’larda) |
| 4 | İlgili §05 gate komutları (font `file`, git ls-files, vb.) |
| 5 | Manuel smoke: değişen akışa özel 1–3 adım (§05 checklist’ten) |
| 6 | Bu planda checkbox güncellendi; PR gövdesinde **Davranış:** yok / şunlar |
| 7 | Secret yok (`.env`, keystore, token) |

#### PR açıklama şablonu (kopyala-yapıştır)

~~~markdown
## Plan referansı
- Faz / madde: örn. 0.1 + 0.3 + 0.4 + 0.7
- PR id: PR-0a

## Özet
(1–3 cümle)

## Davranış değişikliği
- [ ] Yok (pure refactor / hijyen)
- [ ] Var: …

## Doğrulama
    cd app && flutter analyze
    cd app && flutter test
    # maddeye özel: file fonts/Lexend-Regular.ttf

## Risk / rollback
- revert ile geri alınabilir: evet/hayır
- bilinen takip: …
~~~

#### Merge politikası

- Review: mümkünse 1 göz; solo ise self-review + DoD checklist zorunlu.
- Kırmızı CI → merge yok.
- Main bozulursa: **önce revert veya hotfix**, yeni özellik/refactor değil.

### 8.6 Tek iş kalemini uygulama döngüsü (günlük ritim)

Her checkbox için aynı 7 adım:

```
1. SEÇ     §06’dan sıradaki PR veya §04’ten tek madde
2. OKU     Amaç / Dosyalar / Risk; §03 ilgili kanıt
3. BRANCH  main’den güncel branch
4. UYGULA  Karttaki Adımlar sırayla; kapsam dışı dokunma
5. DOĞRULA Kabul + Doğrulama komutları + test/analyze
6. PR      Şablon + plan checkbox’ını PR içinde veya hemen merge sonrası [x]
7. MERGE   Gate OK → main; sonra sonraki madde
```

**Süre tahmini (tek kişi, kaba):**

| Dilim | Süre |
|---|---|
| PR-0a hijyen | 2–4 saat (+ font indirme) |
| PR-0b test | 2–6 saat (flaky’ye göre) |
| PR-1a/1b | 0.5–2 gün |
| PR-1c CI | 1–3 saat |
| PR-2a DI | 0.5–1 gün |
| PR-2b desync | 0.5–1 gün |
| PR-2c/2d | 1–3 gün |
| Her UI extract PR | 0.5–1 gün |
| Faz 0+1 toplam | ~1 hafta |
| Faz 2 | ~1–2 hafta |
| Faz 3 | ~1–2 hafta |
| Faz 4a | aralıklı |

### 8.7 Faz geçiş kapıları (ne zaman “bitti”?)

| Faz bitti sayılır | Kanıt |
|---|---|
| **0** | 0.1 font TrueType; 0.3 tracked junk yok; 0.4 env asset yok + optional; 0.7 models yok; 0.5 test 3× yeşil *(0.2/0.6 blocked olabilir)* |
| **1** | analyze 0 (veya ≤5 gerekçeli); CI workflow main’de yeşil; deps düzgün |
| **2** | Ana provider’larda constructor DI; automation desync kapalı; SyncService en az facade; testler yeşil |
| **3** | P0 ekranlar hedef satır bandında; DrawingDataCodec tek yerde |
| **4a** | freezed grade+deadline + cache notu |

Gate **geçilmeden** bir üst faza “büyük” iş açma. Mini istisnalar §8.3’te.

### 8.8 İlerleme takibi

1. **Bu dosyadaki checkbox’lar** birincil backlog.
2. İsteğe bağlı: GitHub Project / milestone = Faz 0,1,2,3,4a; issue başlığı = PR id.
3. Faz sonunda §01 metrik tablosunu güncelle (`analyze` sayısı, test, satır).
4. “Doğrulama notu” tarihleri eski kaldıysa yeni satır ekle: `Doğrulama (YYYY-MM-DD): …`.

### 8.9 Rol dağılımı (1 kişi vs ekip)

| Rol | Sorumluluk |
|---|---|
| **Implementer** | Branch, kod, test, PR şablonu |
| **Reviewer** | Davranış regresyonu, kapsam şişmesi, secret |
| **Owner (plan)** | Gate kararı, 4b ürün onayı, sıra çatışması |

Tek kişide: implementer = reviewer; her PR’da DoD’yi sesli checklist gibi işaretle.  
İki+ kişide: monolit dosyaları **sahiple** (örn. A = providers, B = note_detail/UI).

### 8.10 Yapılmaması gerekenler (anti-pattern)

| Yapma | Neden |
|---|---|
| Riverpod/get_it’e “madem refactor” göçü | Plan dışı; scope patlar |
| Tek PR’da DI + provider split + UI extract + freezed | Review/revert imkânsız |
| `CourseProvider`’ı test yeşil değilken bölmek | Regresyon körlüğü |
| Background’dan `CourseProvider` instance yaratmak | Yanlış isolate/context |
| 4b özellik vaadi kodlamak (program üretici vb.) | Ürün onayı yok |
| HTML fontu “biraz düzeltmek” | Gerçek TTF şart |
| `.env`’i asset’te bırakmak “şimdilik” | Güvenlik borcu birikir |
| Analyze’i `// ignore_for_file` ile toplu susturmak | Borç gizleme |
| Main’e doğrudan push + test sonra | Kırmızı main |

### 8.11 İlk gün: somut başlangıç (PR-0a)

Sıfırdan başlayan biri için **ilk iş günü** komut iskeleti:

```bash
# 0) main güncel
git checkout main && git pull

# 1) branch
git checkout -b refactor/0a-fonts-git-env

# 2) Git çöpü (örnek — liste §0.3 / §J)
# git rm --cached ... ; git rm ... ; .gitignore güncelle

# 3) Env
# pubspec’ten .env asset satırını kaldır
# main.dart: dotenv.load(..., isOptional: true)

# 4) Fontlar
# Gerçek TTF → app/fonts/ ; assets/fonts/ kaldır

# 5) Ölü assets/models + pubspec

# 6) Doğrula
cd app
flutter pub get
flutter analyze
flutter test
file fonts/Lexend-Regular.ttf

# 7) PR + planda checkbox
```

**PR-0a biter bitmez:** PR-0b (test) veya PR-1a (deps) — ikisi de 0 gate’in parçası/yanı.

### 8.12 AI / asistan ile çalışma (opsiyonel)

Asistan (Cursor, Grok, vb.) kullanılıyorsa:

1. **Tek PR kapsamı ver:** “Sadece PR-0a; CourseProvider’a dokunma.”
2. **Plan path’ini ver:** `docs/REFACTORING_PLAN.md` ilgili madde numarası.
3. **DoD’yi sen koştur:** analyze/test asistan çıktısına güvenip merge etme.
4. **Büyük extract’lerde** önce dosya listesini onayla, sonra hareket ettir.
5. Asistanın ürettiği “yanına bir de şunu yapayım” önerilerini **reddet** veya yeni PR’a yaz.

### 8.13 Acil durum / rollback

| Durum | Aksiyon |
|---|---|
| Merge sonrası test kırmızı | `git revert <merge>` veya hotfix branch; yeni refactor yok |
| Font yanlış yüklendi | Önceki TTF’ye dön (veya sistem font); release’i tut |
| Env optional sonrası crash | `isOptional` kalsın; null check ekle — asset’e geri **koyma** |
| DI sonrası provider test fail | Default `?? Repo()` geriye uyumlu mu kontrol; test DB adı çakışması |
| Çok büyük PR sıkıştı | PR’ı ikiye böl (cherry-pick / yeni branch); main’e zorla basma |

### 8.14 Başarı tanımı (tüm plan)

Plan “bitmiş” sayılmaz; **sürekli yeşil + borç eritme**dir. Kilometre taşları:

1. **M0 — Ship hygiene:** Faz 0 gate (+ mümkünse 0.2/0.6)
2. **M1 — Trust:** Faz 1 (analyze 0, CI, stabil test)
3. **M2 — Structure:** Faz 2 (DI + desync yok)
4. **M3 — Maintainable UI:** Faz 3 P0 ekranlar
5. **M4 — Polish:** 4a; 4b yalnızca ürünle

Her kilometre taşında §01 tablosunu ve bu kılavuzdaki gate satırını güncelle.

---
