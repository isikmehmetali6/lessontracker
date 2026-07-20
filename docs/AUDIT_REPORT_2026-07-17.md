# LessonTracker Denetim Raporu

- **Tarih:** 17 Temmuz 2026
- **Dal:** main
- **Flutter:** 3.41.7
- **Kapsam:** Ürün açıklamasına göre 6 temel özelliğin kaynak kodu + uygulamanın gerçek çalıştırılması + otomatik test paketi
- **lib/:** 183 dosya, ~56.600 satır

---

## 01 — Yönetici Özeti

Altı özellikten ikisi tam, biri hiç yok; otomatik test paketinin yarısından fazlası kendi altyapı hatası yüzünden kırık.

Uygulama derleniyor ve Chrome'da açılıyor; kritik bir çöküş görülmedi. Ancak "otomatik ders programı oluşturma" hiçbir yerde yok, tipografi tüm platformlarda kırık, uygulama ikon/açılış görseli dosyaları boş ve kök dizin 17 rapor dosyası + git'e sızmış kişisel/geçici dosyalarla dolu.

| Metrik | Değer |
|---|---|
| Tam çalışan özellik | 2 / 6 |
| Tamamen eksik özellik | 1 / 6 (otomatik program) |
| Otomatik test geçti | 33 / 72 (%46) |
| `flutter analyze` uyarısı | 63 (0 derleme hatası) |
| Kök dizinde rapor/plan dosyası | 17 (~24.300 kelime) |
| Kullanılmayan (ölü) bağımlılık | 2 |

---

## 02 — Test Yöntemi ve Dürüst Sınırlar

### Yapılanlar

- Uygulama `flutter run -d chrome` ile gerçekten başlatıldı, açılış konsol çıktısı (font/asset hataları dahil) incelendi.
- `flutter run -d windows` denendi (masaüstü desteği eksikliği ortaya çıktı).
- Tüm otomatik test paketi (`flutter test`, 72 test) çalıştırıldı, 39 başarısız testin kök nedeni tek tek incelendi.
- `flutter analyze` ile statik analiz yapıldı.
- Altı istenen özellik (ders ekleme, devamsızlık, otomatik program, Moodle senkron, not alma, tablet defter) için ilgili tüm ekran/provider/servis/repository dosyaları uçtan uca okunup kod yolu izlendi.
- `pubspec.yaml` bağımlılıkları tek tek kullanım taraması yapıldı; git geçmişi ve `.gitignore` kapsamı doğrulandı.

### Yapılamayanlar (kapsam dışı)

- Ekranlara gerçek parmak/kalemle dokunup görsel olarak gezinme imkanı yoktu — bu ortamda tarayıcı otomasyon/ekran görüntüsü aracı yok. Bulgular kod izleme + konsol/log çıktısına dayanır, tıklama testine değil.
- Gerçek bir Moodle sunucusuna bağlanıp uçtan uca senkronizasyon denenmedi (kod yolu okunarak değerlendirildi).
- Android/iOS cihaz veya emülatörde çalıştırma yapılmadı (bu makinede yalnızca Windows/Chrome/Edge hedefleri mevcut).
- Gerçek stylus/tablet donanımıyla basınç testi yapılmadı; değerlendirme kod seviyesinde (`GestureDetector` vs. basınca duyarlı `Listener` kullanımı) yapıldı.

---

## 03 — Özellik Bazlı Analiz

### 1. Ders Ekleme — Tam

**Nerede:** `screens/add_course/add_course_screen.dart`, `providers/course_provider.dart`

Doğrulamalı tam CRUD formu, çakışma kontrolü (`hasScheduleConflict`), Moodle'dan senkron edilmiş bir dersten isim önerisi. Yapısal tuhaflık: bir dersin farklı günlerde farklı saatleri olamıyor — model tek bir başlangıç/bitiş saati taşıdığı için (haftada iki farklı saatte işleniyorsa) aynı isimle iki ayrı Course kaydı oluşturuluyor ve ekranda sonradan birleştiriliyor (`course_provider.dart:51-68`).

### 2. Devamsızlık Kaydı — Tam ama durum senkron hatası var

**Nerede:** `repositories/absence_repository.dart`, `absence_calendar_tab.dart`, `absence_tracker_card.dart`, ayrıca `core/services/attendance_automation_service.dart` (GPS ile otomatik yoklama — beklenenden fazlası, iyi kurgulanmış).

**Bulunan hata:** Devamsızlığı düzenlemenin iki bağımsız yolu var ve birbirinden habersizler. Ders başlığındaki +/- sayaç (`AbsenceTrackerCard`) `CourseProvider` üzerinden yazıp ekranı güncelliyor; takvim sekmesindeki (`AbsenceCalendarTab`, satır 394-513) tarih+gerekçeli ekleme ise doğrudan `AbsenceRepository`'ye yazıyor, `CourseProvider.loadCourses()`'ı hiç çağırmıyor. Sonuç: takvimden eklenen bir devamsızlık, üst kartta ve ana ekrandaki risk göstergelerinde uygulama yeniden yüklenene kadar görünmüyor.

### 3. Otomatik Ders Programı Oluşturma — Eksik

`otomatik`, `generate`, `timetable`, `optimal`, `conflict` gibi terimlerle kod tabanının tamamı tarandı. Bulunan tek şey: `weekly_timetable_screen.dart` ve `weekly_plan_screen.dart` — bunlar kullanıcının elle girdiği ders saatlerini haftalık ızgara olarak gösteren pasif ekranlar. Yeni ders eklerken çakışma varsa reddeden `hasScheduleConflict` fonksiyonu da bir "üretici" değil, sadece bir "reddedici".

**Sonuç:** "Derslerimi girince benim için otomatik ders programı oluşturabilme" ürün vaadi kod tabanında karşılığı olmayan bir özellik. Kullanıcı bugün her dersin saatini tek tek elle giriyor; sistem sadece çakışırsa uyarıyor. Bu, algoritma (CSP/backtracking/greedy) gerektiren gerçek bir "otomatik oluşturma" değil.

### 4. Moodle Senkronizasyonu — Kısmi

**Nerede:** `services/moodle/moodle_api_service.dart` (471 satır), `moodle_sync_service.dart`, `providers/moodle_provider.dart`, `screens/moodle/*` (6 sekme).

Kapsam gerçekten geniş: dersler, ders içerikleri/dosyaları, ödevler, notlar, duyurular, takvim, mesajlar — tek yönlü (Moodle → uygulama) ama iyi mühendislik edilmiş; hata ayrımı (auth/network/servis) ve çevrimdışı önbellek geri dönüşü mevcut. Boşluk: indirilen Moodle dosyaları uygulama içi PDF/not sistemine bağlı değil — `OpenFilex.open()` ile harici uygulamada açılıyor (`moodle_course_detail_screen.dart:654`). Senkronize edilen bir ders slaydının üzerine not almak isteyen öğrenci, aynı dosyayı elle tekrar seçmek zorunda.

### 5. Ders Materyali Üzerine Not Alma — Kısmi

**Nerede:** `providers/note_provider.dart`, `screens/note_detail/note_detail_screen.dart` (1190 satır).

Metin, OCR, fotoğraf, sesli not ve çizim notu — tek bir `Note` modelinde, tek bir görüntüleme ekranında (kopya ekran yok). Bulunan hata: çok sayfalı bir PDF'e çizilen notlar kaydediliyor ama `note_detail_screen.dart:964-976`'daki görüntüleyici yalnızca `strokesByPage['1']`'i, yani ilk sayfayı çiziyor. 2. ve sonraki sayfalara atılan notlar veride duruyor ama not tekrar açıldığında hem sayfa gezinme arayüzü yok hem de PDF arka planı kayboluyor — çizimler boş beyaz bir yüzeyde beliriyor.

### 6. Tablet Kalemiyle Defter — Kısmi

**Nerede:** `handwriting_canvas_screen.dart`, `widgets/course/drawing_canvas.dart` (`perfect_freehand` paketi).

Boş sayfa / fotoğraf / PDF olmak üzere 3 çizim modu, geri al, temizle, 8 renk, 5 kalınlık — çalışıyor ve akıcı görünüyor. Ama:

```dart
// drawing_canvas.dart:38 — yorum satırı iddia ediyor:
// "Apple Pencil feel"
// Gerçek: _onPanUpdate sadece (x, y) alıyor, basınç (z) hiç okunmuyor
```

- Basınç algılama yok (düz `GestureDetector` kullanılıyor, `Listener`/`PointerDeviceKind` yok).
- Avuç içi reddi (palm rejection) yok.
- Gerçek çok sayfalı "defter" kavramı yok (boş sayfa modu tek sayfaya sabit — `handwriting_canvas_screen.dart:479`).
- Sayfalar yalnızca PDF'in kendi sayfa sayısı kadar var oluyor.
- `exportCanvasToImage()` fonksiyonu (`drawing_canvas.dart:330-378`) tanımlı ama hiçbir yerden çağrılmıyor — arayüzde "dışa aktar" butonu yok.

---

## 04 — Uygulamayı Çalıştırırken Bulunan Somut Hatalar

Önceki denetimler (bkz. `AUDIT_REPORT.md`) uygulamayı hiç çalıştırmamıştı. Bu oturumda gerçekten başlatıldı ve şu somut kırıklar ortaya çıktı:

### Marka fontu (Lexend) 5 platformda da kırık — Kritik

`fonts/Lexend-Regular.ttf` ve diğer 4 ağırlık dosyası (Light/Medium/SemiBold/Bold) gerçek font verisi içermiyor — dosyaları açtığımızda hepsi bir GitHub HTML sayfasının kaynak kodu (`<!DOCTYPE html>...<html lang="en"...`). Muhtemelen dosyalar GitHub'dan "raw" yerine sayfa görünümü linkiyle indirilip yanlışlıkla `.ttf` olarak kaydedilmiş (commit `21ae28a` "fix_and_improvements"). Chrome'da uygulamayı başlatınca konsolda 5 font için "contains a valid font" hatası alındı — bütün tipografi sistemi sistem yedek fontuna düşüyor.

```
Failed to load font Lexend at assets/fonts/Lexend-Regular.ttf
Verify that assets/fonts/Lexend-Regular.ttf contains a valid font.
(Light / Medium / SemiBold / Bold için de aynı hata — 5/5)
```

### Uygulama ikonu ve açılış ekranı görselleri hiç yok — Kritik

`assets/images/` ve `assets/icons/` klasörleri tamamen boş (yalnızca `.gitkeep` var). Oysa `pubspec.yaml` hem `flutter_launcher_icons` (satır 109-113: `assets/images/app_icon.png`) hem `flutter_native_splash` (satır 115-124: `splash_logo.png`, `splash_logo_dark.png`) yapılandırmalarında bu klasördeki dosyaları referans alıyor. Bu araçlar bugün çalıştırılırsa hata verir — mağazaya gönderilecek yapı hâlâ varsayılan Flutter ikonuyla derlenir.

### Masaüstü (Windows) hedefi yapılandırılmamış — Orta

`flutter devices` Windows'u geçerli bir hedef olarak listeliyor ama `app/windows/` platform klasörü yok; `flutter run -d windows` anında "No Windows desktop project configured" hatasıyla çöküyor. Mobil odaklı bir uygulama için beklenir, ancak `web/` klasörünün var olması ("Chrome" hedefi çalışıyor, yukarıdaki font hatasıyla) web desteğinin de yarım/test edilmemiş olduğunu gösteriyor.

### Otomatik test paketinin %54'ü altyapı hatasından çöküyor — Kritik

`flutter test`: 72 testten 39'u başarısız. Bunun 30 tanesi (`absence_provider_test`, `course_provider_test`, `deadline_provider_test` + `_extended`, `grade_provider_test`, `note_provider_test` — yani iş mantığı testlerinin tamamı) aynı kök nedenden ötürü ilk satırda patlıyor:

```
Unsupported operation: Unsupported queryResult type null
package:sqflite_common/src/database_mixin.dart … txnRawQuery
package:lesson_tracker/core/database/database_helper.dart:48 DatabaseHelper.database
test/providers/absence_provider_test.dart:22 (setUp → clearAllData)
```

`test/test_helpers.dart` içindeki `setupSqlCipherMock()`, gerçek `sqflite_sqlcipher` platform kanalını taklit etmeye çalışıyor ama sorgu sonucu şekli eksik/yanlış modellenmiş; her testin `setUp` adımındaki `clearAllData()` çağrısında anında istisna fırlatıyor. Yani bu 30 test, iş mantığındaki bir hatadan değil, hiç bitirilmemiş test altyapısından dolayı kırık — CI hiçbir zaman yeşil olmamış. Ayrıca 3 ekran testi (`auth_flow_test.dart`) `pubspec.yaml`'de bile olmayan `mockito` paketini import ediyor.

---

## 05 — Önceki Denetimden Bugün Yeniden Doğrulananlar

`AUDIT_REPORT.md`'nin (2026-05-10) iddiaları bugün kontrol edildi.

Kök dizindeki mevcut `AUDIT_REPORT.md` uygulamayı hiç çalıştırmadan, yalnızca statik olarak yazılmış (kendi "Kapsam Dışı" bölümünde belirtiyor). İki kritik maddesi bugün elle doğrulandı, bir maddesi ise artık geçersiz görünüyor.

| İddia | Durum | Kanıt |
|---|---|---|
| Metin ölçeği (TextScaler) sistem erişilebilirlik ayarını 0.8–1.2× ile sınırlıyor | Doğrulandı — hâlâ var | `lib/main.dart:159-160` |
| Android release derlemesi debug imza anahtarıyla imzalanıyor | Doğrulandı — hâlâ var | `android/app/build.gradle.kts:38-41` |
| `.env` dosyası git'e commit edilmiş ("aktif güvenlik ihlali") | Şüpheli / kanıtlanamadı | `git log --all -- app/.env` → boş sonuç; dosya `.gitignore`'da (satır 48) ve hiç commit geçmişi yok |

**Not:** ".env git'e hiç girmemiş" bulgusu, önceki raporun en dramatik maddesinin (F-01, "aktif güvenlik ihlali") güvenilirliğini sorguluyor — ya daha önce düzeltilip rapor güncellenmemiş ya da baştan yanlış tespit edilmiş. Yine de gerçek bir sorun duruyor: `pubspec.yaml:134` hâlâ `.env`'i uygulama varlığı (asset) olarak paketliyor — yani dosya git geçmişinde olmasa da, derlenmiş APK/IPA içine gömülüyor ve unzip ile çıkarılabilir. **Sorun git değil, paketleme.**

---

## 06 — Gereksiz / Şişkin İçerik

### Kök dizinde 17 rapor/plan dosyası — 24.300+ kelime

Aynı konuyu (QA/test) kapsayan 8 ayrı dosya var: `QA_TEST_RAPORU.md`, `FINAL_QA_REPORT.md`, `FIXED_QA_REPORT.md`, `TEAM_QA_AUDIT_REPORT.md`, `TESTING_REPORT.md`, `EVALUATION_REPORT.md`, `test_plan.md`, `FULL_TEST_PLAN.md`. Hangisinin güncel/geçerli olduğu dosya adından anlaşılmıyor.

| Dosya | Kelime |
|---|---|
| `TESTING_REPORT.md` | 3.829 |
| `AUDIT_REPORT.md` | 3.626 |
| `E2E_IMPLEMENTATION.md` | 2.564 |
| `KVKK_IMPLEMENTATION_PLAN.md` | 2.363 |
| `FULL_TEST_PLAN.md` | 2.111 |
| `TEAM_QA_AUDIT_REPORT.md` | 1.950 |
| + 11 dosya daha | ~7.900 |

| Bulgu | Kanıt | Etki |
|---|---|---|
| Kök dizinde hiç `.gitignore` yok — yalnızca `app/.gitignore` var | `app/.gitignore` `*.log` satırını içeriyor ama kapsamı `app/` altı; kökteki `flutter_*.log` bu yüzden takip ediliyor | Build logları, geçici çıktılar depoya sızmaya devam ediyor |
| 5 Flutter build log dosyası + 20 geçici analiz/çıktı dosyası git'e commit edilmiş | `flutter_01–05.log`; `app/current_analysis_1–7.txt`, `app/run_log*.txt`, `app/test_results*.txt`, vb. | Depo gürültüsü, hiçbir zaman temizlenmemiş "scratch" dosyalar |
| Uygulamayla hiç ilgisi olmayan kişisel bir PDF commit edilmiş | `2010-TBB-bilisim_Hukuku.pdf` (hukuk dersi notu, repo kökünde) | Muhtemelen dosya seçici test edilirken yanlışlıkla eklenmiş |
| 9 adet tasarım-aracı dışa aktarım klasörü (~1,9 MB) git'te | `add_new_course_screen/`, `course_detail_multimodal_*/`, `priority_focus_home_screen/`, vb. — her biri `screen.png` + `code.html` | Flutter kaynak koduyla hiç bağlantısı yok; bir tasarım aracının (v0/benzeri) ham çıktısı, referans olarak bırakılmış |
| Eski, artık tamamlanmış bir Moodle uygulama planı hâlâ kökte duruyor | `moodleentegrasyonplani` (uzantısız dosya) — içinde `/Users/mehmetaliisik/Desktop/...` yolu geçiyor, başka bir makineden kalma | Plan zaten uygulanmış (bkz. §3.4); dosyanın artık hiçbir işlevi yok |

### Kod tabanında ölü ağırlık

| Öğe | Kanıt | Not |
|---|---|---|
| `flutter_background_service` bağımlılığı | `pubspec.yaml:81` — `lib/` içinde 0 kullanım | Kaldırılabilir |
| `vibration` bağımlılığı | `pubspec.yaml:46` — `lib/` içinde 0 kullanım | Yorum satırı zaten "Haptic Feedback (built into Flutter)" diyor, sonra yine de harici paket eklenmiş — kullanılmadan |
| `exportCanvasToImage()` | `drawing_canvas.dart:330-378` | Tanımlı, hiçbir yerden çağrılmıyor |
| 240 `print`/`debugPrint` çağrısı | `lib/` genelinde (daha önce F-04 olarak raporlanmış, bugün 240'a çıktığı doğrulandı) | `avoid_print` kuralı `analysis_options.yaml`'da kapalı |

---

## 07 — Öncelikli Aksiyon Planı

### Hemen — Yayına çıkmadan önce

| # | Aksiyon | Neden |
|---|---|---|
| 1 | Lexend font dosyalarını gerçek `.ttf` ile değiştir | 5 dosya da bozuk — tüm platformlarda marka tipografisi çalışmıyor |
| 2 | `assets/images` ve `assets/icons`'a gerçek `app_icon.png` / `splash_logo.png` ekle | Yoksa `flutter_launcher_icons` ve `flutter_native_splash` derlemede patlar |
| 3 | `test/test_helpers.dart` içindeki SqlCipher mock'unu düzelt | 30 iş-mantığı testi bu yüzden çöküyor — CI'nin hiçbir anlamı kalmıyor |
| 4 | Android release imzalamayı gerçek keystore'a bağla | Şu an debug anahtarıyla imzalı — Play Store reddeder |
| 5 | Kök dizine `.gitignore` ekle, log/txt/kişisel dosyaları git'ten temizle | `flutter_*.log`, `current_analysis_*.txt`, `2010-TBB-bilisim_Hukuku.pdf` |

### Kısa vadede

| # | Aksiyon | Neden |
|---|---|---|
| 6 | `AbsenceCalendarTab`'ı `CourseProvider` üzerinden yazacak şekilde birleştir | İki farklı devamsızlık düzenleme yolu birbirinden habersiz, arayüz bayatlıyor |
| 7 | Çok sayfalı çizim notlarını tüm sayfalarıyla görüntüle | Şu an yalnızca 1. sayfa gösteriliyor, veri kaybolmuyor ama erişilemiyor |
| 8 | `flutter_background_service` ve `vibration`'ı kaldır, `exportCanvasToImage`'a gerçek bir buton bağla ya da sil | Ölü bağımlılık + ölü kod |
| 9 | 17 rapor dosyasını tek bir `docs/` yapısında konsolide et | 8 çakışan QA raporu yerine tek güncel kaynak |

### Orta/uzun vadede

| # | Aksiyon | Neden |
|---|---|---|
| 10 | "Otomatik ders programı oluşturma" özelliğini ya gerçekten inşa et ya da ürün metninden çıkar — **karar (17.07.2026): MVP+1'e bırakıldı, ürün metninden çıkarıldı** | Şu an hiçbir algoritmik karşılığı yok; ürünün kendi metinlerinde zaten vaat yok, kullanıcıya yönelik string yok |
| 11 | Moodle materyallerini uygulama içi not/PDF sistemine bağla | Şu an harici uygulamada açılıyor, senkron ile not alma birbirinden kopuk |
| 12 | Kalem için gerçek basınç desteği ve avuç reddi ekle | `Listener` + `PointerDeviceKind` ile; "Apple Pencil feel" yorumundaki iddia şu an gerçek değil |
| 13 | TextScaler kısıtını kaldır, Semantics etiketleri ekle, Crashlytics/hata sınırı bağla | Önceki denetimin hâlâ açık olan erişilebilirlik/gözlemlenebilirlik maddeleri |

---

*Bu rapor lessontracker deposunun main dalı üzerinde, 17 Temmuz 2026 tarihinde, uygulamanın Chrome/Windows hedeflerinde başlatılması + tam otomatik test paketinin çalıştırılması + 6 istenen özelliğin kaynak kod izlemesiyle hazırlanmıştır. Görsel tıklama testi bu ortamda yapılamamıştır (bkz. §02).*