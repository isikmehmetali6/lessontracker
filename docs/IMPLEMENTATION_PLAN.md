# Uygulama Planı — `AUDIT_REPORT_2026-07-17.md` aksiyonları

- **Tarih:** 17 Temmuz 2026
- **Kaynak rapor:** `docs/AUDIT_REPORT_2026-07-17.md`
- **Yaklaşım:** Her madde kanıtlanmış (dosya:satır), uygulanabilir adımlara ayrılmış, sizden onay gereken yerler ayrı işaretlenmiş.
- **Durum:** ☐ Beklemede · 🚧 Devam ediyor · ✅ Tamamlandı · ❌ Sizin kararınız gerekli

---

## Doğrulanan Olgular (Uygulama Öncesi Kanıt)

| İddia | Kanıt | Durum |
|---|---|---|
| Lexend font dosyaları bozuk | İlk 16 byte: `0D 0A 0D 0A 0D 0A 0D 0A 0D 0A 0D 0A 0D 0A 0D 0A` (CRLF = Windows metin satır sonu). Gerçek TTF magic `00 01 00 00` veya `OTTO` (OpenType) olmalıydı. 5/5 dosya aynı şekilde bozuk. | ✅ Doğrulandı |
| `assets/images/` ve `assets/icons/` boş | Yalnızca `.gitkeep` mevcut. | ✅ Doğrulandı |
| `pubspec.yaml` font ailesi adı doğru | `app/pubspec.yaml:136-147` — `family: Lexend`, 5 weight (300/400/500/600/700) doğru tanımlı. **Sorun dosyalarda, yapılandırmada değil.** | ✅ Doğrulandı |
| `exportCanvasToImage` tanımlı ama çağrılmıyor | Tek tanım `app/lib/widgets/course/drawing_canvas.dart:330`. `grep` ile başka hiçbir referans yok. | ✅ Doğrulandı |
| `vibration` paketi yorumu yanlış | `app/pubspec.yaml:45-46`: yorum "Haptic Feedback (built into Flutter)" diyor, sonra paket ekleniyor. | ✅ Doğrulandı |
| `flutter_background_service` paketi | `app/pubspec.yaml:81` — ekli. | ✅ Doğrulandı |

---

## Hemen — Yayına Çıkmadan Önce

### #1 · Lexend font dosyalarını gerçek `.ttf` ile değiştir — 🚧

**Sorun:** 5 font dosyası metin (CRLF ile başlayan, ~299 KB), gerçek font değil.

**Uygulama adımları:**
1. ☐ Lexend font ailesini Google Fonts'tan indirin (lisans: OFL — açık kaynak, dağıtım serbest): https://fonts.google.com/specimen/Lexend
2. ☐ İhtiyaç duyulan 5 ağırlık dosyasını indirin: Light (300), Regular (400), Medium (500), SemiBold (600), Bold (700).
3. ☐ Mevcut dosyaların üzerine yazın: `app/assets/fonts/Lexend-Light.ttf`, `Lexend-Regular.ttf`, `Lexend-Medium.ttf`, `Lexend-SemiBold.ttf`, `Lexend-Bold.ttf`.
4. ☐ Doğrulama: ilk 4 byte hex = `00 01 00 00` veya `4F 54 54 4F` (`OTTO`).
5. ☐ `flutter run -d chrome` ile başlatın, konsolda font hatası kalmamalı.

**Sizden beklenen:** Font indirme (benim yerime siz yapın, çünkü lisans/dağıtım kararı).

---

### #2 · Uygulama ikonu ve açılış ekranı görselleri — ⏸ SİZİN KARARINIZ

**Sorun:** `assets/images/` ve `assets/icons/` boş, ama `pubspec.yaml:109-124` icon/splash üreteçlerine referans veriyor.

**Uygulama adımları:**
1. ☐ Marka logonuzu (PNG, en az 1024×1024) `assets/images/app_icon.png` olarak kaydedin.
2. ☐ Açılış ekranı logoları (`splash_logo.png`, `splash_logo_dark.png`) aynı klasöre ekleyin (önerilen: 512×512 PNG, şeffaf arka plan).
3. ☐ `dart run flutter_launcher_icons` çalıştırın.
4. ☐ `dart run flutter_native_splash:create` çalıştırın.

**Sizden beklenen:** Tasarım kararı + dosyaların hazırlanması (yerine geçecek placeholder üretirsem markanızı temsil etmez).

---

### #3 · SqlCipher mock altyapısı düzeltme — ☐ Beklemede

**Sorun:** `test/test_helpers.dart` içindeki `setupSqlCipherMock()` gerçek `sqflite_sqlcipher` platform kanalını tam modellenemiyor; 30 iş-mantığı testi `clearAllData()` setUp adımında patlıyor.

**Uygulama adımları:**
1. ☐ `app/test/test_helpers.dart` okunup mevcut mock yapısı çıkarılacak.
2. ☐ Kullanılan yöntem seçilecek (iki seçenek var):
   - **(A) `sqflite_common_ffi` kullanmak:** Gerçek bir SQLite (FfiDatabase) test ortamında çalıştırmak. `sqflite_sqlcipher` yerine testlerde `databaseFactoryFfi` kullanmak. Güvenilir, bakımı kolay, CI'da çalışır.
   - **(B) Mock'u tamamlamak:** `sqflite_common_ffi`'de de `txnRawQuery` benzeri uç durumlar var; mock'u genişletmek yerine (A) tercih edilmeli.
3. ☐ `setUp`/`tearDown` içinde `databaseFactory = databaseFactoryFfi` atanacak, testlerde `sqflite_sqlcipher` factory bypass edilecek.
4. ☐ Doğrulama: `flutter test` → 0 başarısız (72/72 yeşil).

**Sizden beklenen:** Yaklaşım kararı (A öneriliyor).

---

### #4 · Android release imzalama — ⏸ SİZİN KARARINIZ

**Sorun:** `android/app/build.gradle.kts:38-41` debug keystore ile release imzalama yapılıyor; Play Store kabul etmez.

**Uygulama adımları:**
1. ☐ **Sizin makinenizde** üretim keystore üretin:
   ```
   keytool -genkey -v -keystore ~/lessontracker-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. ☐ `android/key.properties` oluşturun (git'e eklenmemeli, zaten `.gitignore`'da olmalı).
3. ☐ `android/app/build.gradle.kts` release blokunu `signingConfigs.release` ile değiştirin; debug keystore'a fallback kaldırın.
4. ☐ Doğrulama: `flutter build apk --release` üretilen APK `apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk` ile kontrol edildiğinde SHA256 sizin ürettiğiniz anahtar olmalı.

**Sizden beklenen:** Keystore üretimi + şifrelerin yönetimi (güvenlik sebebiyle ben üretmemeliyim).

---

### #5 · Kök `.gitignore` + log/txt/kişisel dosya temizliği — 🚧

**Sorun:** Kök dizinde `.gitignore` yok; sadece `app/.gitignore` var ve kapsamı `app/` altı. Sonuç: `flutter_*.log`, `current_analysis_*.txt`, kişisel PDF'ler git'e girmiş.

**Uygulama adımları:**
1. ☐ **Kök `.gitignore` oluştur** (`C:\projects\lessontracker\.gitignore`):
   ```
   # Flutter build artifacts
   **/build/
   **/.dart_tool/
   **/.flutter-plugins
   **/.flutter-plugins-dependencies
   **/.packages
   **/.pub-cache/
   **/.pub/
   **/pubspec.lock

   # IDE
   .idea/
   .vscode/
   *.iml
   *.iws

   # OS
   .DS_Store
   Thumbs.db

   # Logs & temp
   *.log
   flutter_*.log
   app/current_analysis_*.txt
   app/run_log*.txt
   app/test_results*.txt
   app/scratch_*.txt
   app/temp_*.txt
   app/tmp_*.txt
   app/.last_build/

   # Personal / unrelated
   *.pdf
   !app/assets/**/*.pdf
   ```

2. ☐ **Git'ten çıkar** (dosyaları silmeden):
   ```
   git rm --cached app/flutter_01.log app/flutter_02.log app/flutter_03.log app/flutter_04.log app/flutter_05.log
   git rm --cached app/current_analysis_1.txt app/current_analysis_2.txt app/current_analysis_3.txt app/current_analysis_4.txt app/current_analysis_5.txt app/current_analysis_6.txt app/current_analysis_7.txt
   git rm --cached app/run_log*.txt app/test_results*.txt app/scratch_*.txt app/temp_*.txt app/tmp_*.txt
   git rm --cached "2010-TBB-bilisim_Hukuku.pdf"
   ```

3. ☐ **Tasarım aracı dışa aktarım klasörlerini** git'ten çıkar ve sil:
   ```
   git rm -r --cached add_new_course_screen/ course_detail_multimodal_*/ priority_focus_home_screen/ ...
   ```
   (Listeyi çalıştırırken doğrulayacağım.)

4. ☐ **Kök dizindeki eski plan dosyasını** sil (uzantısız, `moodleentegrasyonplani`):
   ```
   git rm --cached moodleentegrasyonplani
   rm moodleentegrasyonplani
   ```

5. ☐ Doğrulama: `git status` temiz; `git ls-files | grep -E '\.log$|current_analysis|run_log|test_results|Hukuku'` boş dönmeli.

---

## Kısa Vadede

### #6 · Devamsızlık senkron bugı — ☐ Beklemede

**Sorun:** `AbsenceCalendarTab` doğrudan `AbsenceRepository`'ye yazıyor, `CourseProvider`'ı bilgilendirmiyor. UI bayatlıyor.

**Uygulama adımları:**
1. ☐ `app/lib/screens/course_detail/tabs/absence_calendar_tab.dart:394-513` okunacak.
2. ☐ `CourseProvider`'a `addAbsenceFromCalendar(...)` veya `recordAbsence(courseId, date, reason)` benzeri tek giriş noktası eklenecek.
3. ☐ `AbsenceCalendarTab` bu provider metodunu çağıracak; doğrudan repository çağrısı kaldırılacak.
4. ☐ `AbsenceTrackerCard` zaten provider üzerinden çalışıyor, değişiklik gerekmeyebilir.
5. ☐ Doğrulama: takvimden devamsızlık ekle → üst kart ve ana ekran risk göstergesi anında güncellensin.

---

### #7 · Çok sayfalı çizim notları — ☐ Beklemede

**Sorun:** `note_detail_screen.dart:964-976` yalnızca `strokesByPage['1']` çiziyor. 2+ sayfa verileri kaydediliyor ama gösterilmiyor.

**Uygulama adımları:**
1. ☐ `app/lib/screens/note_detail/note_detail_screen.dart` (1190 satır) okunacak, mevcut PDF entegrasyonu ve stroke veri yapısı anlaşılacak.
2. ☐ `PdfViewer` üzerinde `currentPage` state'i eklenecek.
3. ☐ `Stack` içinde her sayfa için `CustomPaint` ile strokesByPage[currentPage] çizilecek.
4. ☐ Sayfa gezinme UI'ı eklenecek (sol/sağ ok veya sayfa göstergesi).
5. ☐ Doğrulama: PDF'e 2. sayfaya not çiz → kaydet → tekrar aç → 2. sayfa gösterildiğinde not görünsün.

---

### #8 · Ölü bağımlılık ve ölü kod temizliği — 🚧

**Uygulama adımları:**
1. ☐ **`pubspec.yaml:81` `flutter_background_service` kaldır:**
   ```
   - flutter_background_service: ^5.1.0
   ```
   `flutter pub get` çalıştır.

2. ☐ **`pubspec.yaml:46` `vibration` kaldır:**
   ```
   - vibration: ^2.0.0
   ```
   ve yorum satırını (`# Haptic Feedback (built into Flutter)`) sil.

3. ☐ **`exportCanvasToImage` için iki seçenek:**
   - **(A) Sil:** Hiç çağrılmıyor, kullanıcı arayüzünde "dışa aktar" yok → kaldır.
   - **(B) UI'a bağla:** `HandwritingCanvasScreen` AppBar'ına "PNG olarak kaydet" butonu ekle, `exportCanvasToImage` → `gallery_saver` veya `path_provider` ile diske yaz.
   - **Önerim:** (A) — özellik kapsam dışı bırakılmadıysa bile kullanıcı talep etmedi.

4. ☐ Doğrulama: `flutter pub get` hatasız; `flutter analyze` aynı/benzer uyarı sayısı.

---

### #9 · 17 rapor dosyasını `docs/` altında konsolide et — 🚧

**Uygulama adımları:**
1. ☐ Mevcut raporları `docs/` altına tarihli taşı (silmeden):
   - `AUDIT_REPORT.md` → `docs/archive/AUDIT_REPORT_2026-05-10.md`
   - `TESTING_REPORT.md` → `docs/archive/TESTING_REPORT_<tarih>.md`
   - (Tüm 17 dosya için aynı işlem)
2. ☐ Yeni güncel tek dosya: `docs/QA.md` (sadece aktif QA/test sürecinin özeti):
   - Test stratejisi
   - Çalıştırma komutları
   - Coverage hedefleri
   - Bilinen kırık testler ve kök nedenleri
3. ☐ Kök dizinde yalnızca `README.md` (varsa) + `docs/` kalacak.
4. ☐ Doğrulama: `ls *.md` kök dizinde boş (veya sadece README).

---

## Orta / Uzun Vadede

### #10 · Otomatik ders programı — ✅ MVP+1'E BIRAKILDI (Karar: B)

**Karar (17 Temmuz 2026):** Ürün metninden çıkarıldı. MVP kapsamına alınmıyor; MVP+1'de inşa edilecek (CSP/backtracking).

**Durum:**
- Ürünün kendi metinlerinde (pubspec.yaml description, README.md) "otomatik ders programı" vaadi yok.
- Beklenti yalnızca denetim raporundaki ürün tarifinde geçiyordu.
- Kod tabanında `hasScheduleConflict` reddedici yardımcı mevcut ve doğru çalışıyor — kaldı, değişiklik gerekmedi.
- Kullanıcıya yönelik herhangi bir string/yorum yoktu, bu nedenle ürün metninden çıkarma işlemi salt belgeleme ile sınırlı.

**MVP+1'de inşa edilirse:**
1. `Course` modeli tek bir `startTimeHour/Minute` taşıyor; `[scheduleSlot]` listesine geçiş + migration gerekir.
2. CSP/backtracking çözücü + unit testleri: 4-8 saat.
3. Kullanıcı kısıt toplama UI'ı (zorunlu gün/saat, tercih edilen boşluklar): 4-6 saat.
4. Üretilen planı önizleme + uygulama akışı: 4-6 saat.
5. Tahmini toplam: 12-21 saat mühendislik.

---

### #11 · Moodle materyallerini uygulama içi nota bağla — ☐ Beklemede

**Uygulama adımları:**
1. ☐ `app/lib/screens/moodle/moodle_course_detail_screen.dart:654` okunacak.
2. ☐ İndirilen PDF dosyası `NoteProvider`'a "PDF arka planlı not" olarak eklenebilecek.
3. ☐ `Note` modelinde `pdfAssetPath` veya `pdfLocalPath` alanı zaten varsa kullanılacak; yoksa eklenir (migration gerekebilir).
4. ☐ "Üzerine not al" butonu eklenecek, `NoteDetailScreen` ile aynı ekranı paylaşacak.
5. ☐ Doğrulama: Moodle'dan bir PDF indir → "Not al" de → kaydet → notlar PDF arka planıyla görünsün.

---

### #12 · Kalem basınç + palm rejection — ☐ Beklemede

**Uygulama adımları:**
1. ☐ `drawing_canvas.dart:38` (ve çevresindeki `_onPanUpdate`) okunacak.
2. ☐ `GestureDetector.onPanUpdate` → `Listener.onPointerMove` değiştirilecek; `PointerEvent.pressure` (0.0-1.0) okunacak.
3. ☐ Basınç normalize edilerek stroke kalınlığıyla çarpılacak (`size * (0.5 + pressure)` gibi).
4. ☐ Palm rejection: `PointerDeviceKind.touch` event'lerini yalnız `kind == PointerDeviceKind.stylus` veya `invertedStylus` ise kabul et; touch'ları reddet (alternatif: küçük bir `kPalmRejectionRadius` ile son N ms içinde stylus varsa touch'u yoksay).
5. ☐ Doğrulama: gerçek stylus olmadan kod analiziyle yapılır (ideal); varsa donanım testi.

---

### #13 · TextScaler kaldır + Semantics + Crashlytics — ☐ Beklemede

**Uygulama adımları:**
1. ☐ `lib/main.dart:159-160` okunacak; `MediaQuery` override'ı kaldırılacak veya `clamp(0.8, 1.2)` → kaldırılacak.
2. ☐ Kritik widget'lara `Semantics(label: ...)` ekleyin (FAB, tab bar, form alanları). En azından ana ekran ve kurs detay ekranı.
3. ☐ `firebase_crashlytics` bağımlılığı eklenmeli; `main.dart`'a `FlutterError.onError` ile Crashlytics'e yönlendirme.
4. ☐ Doğrulama: sistem metin ölçeğini 2.0× yap → uygulama hâlâ okunabilir; ekran okuyucu (TalkBack/VoiceOver) önemli öğeleri anlamlı şekilde okur; uygulama çökmesi Crashlytics'e düşer.

---

## İlerleme Özeti

| Kategori | Maddeler | Durum |
|---|---|---|
| Hemen | #1, #2, #3, #4, #5 | ⏸ 3 sizin kararınız, 🚧 2 uygulanmaya hazır |
| Kısa vade | #6, #7, #8, #9 | ☐ Hepsi uygulanabilir |
| Orta/uzun | #10, #11, #12, #13 | ⏸ 1 sizin kararınız, ☐ 3 uygulanabilir |

**Bir sonraki adım için onayınız:** Sıradaki hangi maddeyi uygulayayım? (Önerim: #5 — kök `.gitignore` + log/txt temizliği, çünkü tek başına risksiz ve hemen değer üretir.)