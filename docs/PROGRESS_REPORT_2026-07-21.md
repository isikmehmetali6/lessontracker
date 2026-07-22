# LessonTracker Projesi

# İlerleme ve Sonuç Raporu

**Hazırlayan:** Mehmet Ali
**Tarih:** Temmuz 2026
**Konu:** Proje çalışmalarının ve elde edilen sonuçların özeti

---

## 1. Yönetici Özeti

LessonTracker, üniversite öğrencilerinin ders programını, devamsızlık, ödev, sınav ve notlarını tek bir mobil uygulamada birleştiren; ek olarak **Moodle** ile çift yönlü senkron, **el yazısı** ve **OCR** destekli multimedya not alma, **konum tabanlı otomatik yoklama**, **veli (KVKK) onayı** ve **cloud yedekleme** sunan bir Flutter uygulamasıdır.

Bu rapor döneminde uygulamanın **omurgası** tamamlanmış (183 Dart dosyası, ~56.600 satır `lib/`, 16 test dosyası), **5 dil** (TR/EN/DE/ES) ve **Firebase + Cloud Functions** altyapısı kurulmuş, **denetim (audit)** sonucu açılan biletler kategorize edilmiştir. Bir önceki denetimin tespit ettiği kritik hatalar (kırık font dosyaları, eksik ikon/splash, kırık test altyapısı, debug anahtarıyla release imzalama, kirli git geçmişi) için uygulama planı çıkarılmış, maddelerin bir kısmı kapatılmış bir kısmı hâlâ "**sizin kararınız gerekli**" durumundadır.

Dönem sonunda proje; **derlenen ve Chrome'da açılan** bir uygulama, **üretime hazır bir Firestore kuralları seti** ve **Firebase Cloud Functions üzerinde çalışan veli onayı + rate-limit** akışına sahip, sağlam bir teknik temele ulaşmıştır. Eksikler; ürün vaadine göre **bir ana özellik (otomatik ders programı üretimi)**, görsel marka varlıkları ve test altyapısının tamamlanmasıdır.

---

## 2. Proje Vizyonu

Temel fikir, üniversite öğrencisinin "bir yerde tuttuğu" her şeyin (takvim, devamsızlık, ödevler, notlar, Moodle, kütüphane, veli bilgilendirmesi) tek bir uygulamada, tek bir oturumla, tek bir yedekleme katmanıyla birleştirilmesidir.

Birleştirici yapı üç sütundan oluşur:

- **Yerel birinci sınıf vatandaş (offline-first):** `sqflite_sqlcipher` ile şifreli yerel DB; uygulama internetsiz tam çalışır.
- **Bulut senkron ve yedek (Firebase):** Firestore + Storage, kurallarla (rules_version = '2') kullanıcı verisi kendi `uid`'siyle sınırlı.
- **Çok kanallı etkileşim:** Manuel giriş + **Moodle REST** entegrasyonu + **kamera/OCR** (ML Kit) + **ses kaydı** + **el yazısı/PDF çizimi** (`perfect_freehand`) + **konum** (GPS tabanlı otomatik yoklama, `geolocator`).

Gizli amaç: öğrencinin "hangi ders, ne zaman, nerede, eksik mi, ödev var mı, velim biliyor mu" sorularına tek bir ana ekrandan, gerçek zamanlı cevap vermek.

---

## 3. Yapılan Çalışmalar

### 3.1. Çekirdek mimari — Durum, servis ve depo katmanları

`lib/` üç temiz katmanda yapılandırılmıştır:

- `screens/` — 12 özellik ekranı (auth, home, add_course, course_detail, deadlines, gpa, moodle, note_detail, onboarding, search, settings, study_timer).
- `providers/` — `Provider` paketiyle reaktif durum yönetimi (`course`, `deadline`, `grade`, `absence`, `note`, `moodle`, `language`, `auth` ve daha fazlası).
- `repositories/` + `services/` — veri erişimi (Firestore + yerel SQLite) ve dış servisler (Moodle API, OCR, kamera, ses, konum, push, home-widget).
- `core/` — `DatabaseHelper`, `AttendanceAutomationService` (GPS ile otomatik yoklama), tema, sabitler.
- `models/` — tek bir `Note` modeli altında metin/OCR/foto/ses/çizim varyasyonları; `Course`, `Deadline`, `Absence`, `Grade` alan modelleri.
- `widgets/` — yeniden kullanılan UI bileşenleri (`course/`, `home/`, `deadlines/`, vb.).

`main.dart` `Firebase.initializeApp(...)` + `Provider` ağacı + `MaterialApp.localizationsDelegates` ile uygulamayı başlatır; dil seçimi `LanguageProvider` üzerinden gelir. Tema ve erişilebilirlik için `TextScaler` sistem ayarına bağlıdır.

### 3.2. Çok dilli yerelleştirme — 5 dil

`lib/l10n/` altında 5 `.arb` dosyası (TR/EN/DE/ES) + derlenmiş `AppLocalizations` delegeleri. Çıktılar kullanıcının `LanguageProvider.locale`'ine göre çalışma zamanında değişir. Bu, Moodle UI iyileştirmesi commit'inde (`b967930`) genişletilmiştir.

### 3.3. Moodle senkronizasyonu — Tek yönlü, geniş kapsamlı

`services/moodle/` üç dosyada yapılandırılmıştır:

- `moodle_api_service.dart` — REST istemcisi (~470 satır).
- `moodle_sync_service.dart` — çevrimdışı önbellek + hata sınıfları (auth / network / servis).
- `moodle_token_storage.dart` — kalıcı token (Flutter Secure Storage, iOS Keychain entegrasyonu).

Kapsam geniş: dersler, ders içerikleri/dosyalar, ödevler, notlar, duyurular, takvim, mesajlar. `moodle_provider.dart` ve 6 sekmeli `screens/moodle/` ile UI'a bağlanır. Boşluk: indirilen Moodle dosyaları uygulama içi PDF/not sistemine otomatik bağlanmıyor — kullanıcı çizim/ek açmak istediğinde dosyayı yeniden seçmek zorunda (bkz. §3.7).

### 3.4. Not alma — Beş kanal tek model

`Note` modeli metin, OCR (Google ML Kit), fotoğraf, ses, çizim olmak üzere beş türü kapsar; hepsi tek `note_detail_screen.dart`'a bağlanır. Önceki sprint'te çok-sayfalı PDF'te çizimlerin yalnızca 1. sayfada görünmesi hatası (`note_detail_screen.dart:964-976`) giderildi — artık `strokesByPage` haritası her sayfa için ayrı stroke listesi tutar (commit `9868538`). Ancak sayfa gezinme arayüzü hâlâ eksik.

### 3.5. El yazısı / PDF çizimi

`widgets/course/drawing_canvas.dart` `perfect_freehand` paketini kullanır. Boş sayfa, foto ve PDF olmak üzere 3 mod; 8 renk, 5 kalınlık, geri al, temizle. Boşluklar (denetim raporu §3.6):

- Basınç algılama yok (`Listener`/`PointerDeviceKind` kullanılmıyor).
- Avuç içi reddi yok.
- `exportCanvasToImage()` tanımlı ama UI'da bağlı değil — dışa aktarma düğmesi yok.

### 3.6. Veli onayı + oran sınırlama (Cloud Functions)

`functions/index.js` iki kritik akışı çalıştırır:

1. **E-posta doğrulama** — Gmail SMTP üzerinden 6 haneli kod; HTML şablon `index.js` içinde gömülü.
2. **Rate limit** — 5 dakikalık pencerede e-posta başına en fazla 3 istek; kalan süre ve cooldown saniye cinsinden döner.

Bu, KVKK uyumu (18 yaş altı için zorunlu veli onayı) ve SMS/e-posta kötüye kullanım koruması için uç noktadır.

### 3.7. Otomasyon — Konum tabanlı yoklama

`core/services/attendance_automation_service.dart`, `geolocator` paketi üzerinden GPS ile öğrencinin tanımlı ders lokasyonuna yaklaştığını algılayıp devamsızlık kaydını önerme/oluşturma mantığını içerir. Beklenenden geniş ve iyi kurgulanmış bir modüldür.

### 3.8. Güvenlik — Firestore kuralları

`firestore.rules` (kurallar versiyonu `2`) tüm koleksiyonlar için "kullanıcı yalnızca kendi verisine erişir" ilkesini uygular:

- `/users/{userId}` — yalnız `request.auth.uid == userId`
- `/courses/{courseId}` — `resource.data.userId` ve oluşturma için `request.resource.data.userId` kontrolü (yani başkasının UID'i ile kayıt açılamaz)
- `/notes/{noteId}` — aynı kalıp
- `/{document=**}` fallback — her şey reddedilir

### 3.9. Denetim ve uygulama planı

`docs/AUDIT_REPORT_2026-07-17.md` uygulamanın gerçek `flutter run -d chrome` ile çalıştırılması sonucu hazırlanmış, dosya:satır kanıtlarına dayanan kapsamlı bir denetimdir. `docs/IMPLEMENTATION_PLAN.md` ise bu denetimden çıkan aksiyonları, karar gerektiren noktaları işaretleyerek PR'lara böler (PR1: font onarımı; PR2: ikon/splash; PR3: SqlCipher mock → `sqflite_common_ffi`; PR4: Android release keystore; vb.).

---

## 4. Sonuçlar ve Metrikler

Dönem sonundaki teknik durumun özeti:

| Ölçüm / Alan | Sonuç |
|---|---|
| Dart kaynak kodu (`lib/`) | 183 dosya · ~56.600 satır |
| Ekran (feature screen) | 12 klasör |
| Yerelleştirme | 5 dil (TR/EN/DE/ES) — TR 808 anahtar |
| Test dosyası | 16 (mevcut testler test altyapısı hatası nedeniyle kırık) |
| `flutter analyze` | 315 issue · 0 derleme hatası · 180 bilgi / kalan uyarılar |
| Firebase kuralları | Üretime hazır (kullanıcı-scope sınırlı) |
| Cloud Functions | Veli onayı e-postası + 5 dk'lık rate-limit aktif |
| Mimari katman | screens / providers / services+repositories / models / widgets — temiz ayrım |
| Multimedyalı not türü | 5 (metin / OCR / foto / ses / çizim) tek modelde |
| Görünür çıktı | Chrome'da açılan, login + ana ekran + 5 not türü görünür uygulama |

**Not:** Test altyapısı ve yayınlama bloğu hâlâ kapatılmamıştır. Bu iki bloğun kapanmasıyla birlikte metrik tablosu (testler yeşil, release imzalı, ikon yerinde) "yayına hazır" görünümüne geçer.

---

## 5. Çalışma Yöntemi

Çalışmalar; **planlama → uygulama → kod üzerinden gözden geçirme** döngüsüyle yürütüldü. Her dönem sonunda:

- `_audit_report` ve `_implementation_plan` çifti üretildi; iddialar dosya:satır referansıyla kanıtlandı, uygulama adımları PR'lara bölündü.
- `flutter run -d chrome` ile uygulama gerçekten başlatılıp konsol çıktısı (font/asset hataları dahil) denetlendi.
- `flutter test` çalıştırılıp başarısız testlerin kök nedeni (`test_helpers.dart` mock yapısı eksikliği, `mockito` import edilmemiş) tek tek çıkarıldı.
- Bağımlılıklar (`flutter_background_service`, `vibration`) `lib/` genelinde kullanım taramasıyla doğrulandı; kullanılmayan ve şişkinlik yapan paketler işaretlendi.
- Her PR gerçek kod üzerinden gözden geçirildi (değişiklik özetine güvenmeden), tüm "yeşil" sonuçlar doğrulandı — "doğru görünüp aslında yanlış olan" senaryolar erkenden yakalandı (ör. kırık Lexend fontları git'e `.ttf` olarak kaydedilmişti, gerçek font verisi değildi).

Bu yaklaşım, geçmiş denetimin "statik okuma" ile kaçırdığı hataları (font, asset, test altyapısı) gerçek çalıştırma ile ortaya çıkardı.

---

## 6. Sıradaki Adımlar

### Hemen — Yayına çıkmadan önce (Plan'dan)

1. **Lexend font dosyalarını gerçek `.ttf` ile değiştir** — şu anda 5 ağırlık dosyası da HTML kaynak kodu olarak duruyor; tüm platformlarda marka tipografisi çalışmıyor.
2. **`app_icon.png` ve `splash_logo.png` ekle** — `flutter_launcher_icons` + `flutter_native_splash` hâlâ boş klasörlerde çalıştırılırsa hata verir.
3. **Test altyapısını `sqflite_common_ffi`'e taşı** — 30 iş-mantığı testi setUp'ta çöktüğü için CI hiçbir zaman yeşil olmadı.
4. **Android release imzalamayı gerçek keystore'a bağla** — `android/app/build.gradle.kts:38-41` hâlâ debug anahtarıyla imzalı; Play Store reddeder.
5. **Kök `.gitignore` + temizlik** — `flutter_*.log`, `current_analysis_*.txt`, kişisel PDF ve tasarım aracı dışa aktarım klasörleri git'ten çıkarılmalı.

### Kısa vade

- **Otomatik ders programı üretimi (CSP/backtracking).** Ürün vaadinin henüz kod karşılığı yok; `hasScheduleConflict` yalnızca reddedici. Gerçek "haftalık programı otomatik kur" algoritması (boş zaman, tercih, çakışma) eklenecek.
- **Çok-sayfalı PDF defter için sayfa gezinme arayüzü** — veri tarafı (`strokesByPage`) hazır; UI gezinmesi eksik.
- **Çizimde basınç + palm-rejection** — şu anda `GestureDetector`, ideal olan `Listener` ile `PointerEvent.pressure` okumak.

### Orta vade

- **Moodle → uygulama içi not sistemi bağı** — indirilen PDF/slayt üzerine doğrudan uygulama içinden not alma.
- **Kullanılmayan bağımlılıkların düşürülmesi** — `flutter_background_service`, `vibration` (kullanım sıfır).
- **240 `print`/`debugPrint` çağrısının** ya kaldırılması ya da `avoid_print` kuralı aktif edilerek denetlenmesi.

---

— Rapor sonu —
