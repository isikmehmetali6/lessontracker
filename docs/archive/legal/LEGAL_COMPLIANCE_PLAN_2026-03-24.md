# Yasal Uyumluluk Planı - LessonTracker

**Tarih:** 24 Mart 2026
**Amaç:** Uygulamayı "Paylaşım Odaklı" platformdan "Kişisel Verimlilik" aracına dönüştürmek

---

## 1. BULUT YEDEkleme - Opt-In & Şifreli Hale Getir

**Öncelik:** YÜKSEK
**Dosya:** `app/lib/core/services/sync_service.dart`

### Yapılacaklar:

- [ ] `SharedPreferences`'dan `cloud_backup_enabled` flag'i kontrol et
- [ ] Yedekleme öncesi kullanıcıdan açık izin al
- [ ] `flutter_secure_storage` + `encrypt` paketi ile AES-256 şifreleme ekle
- [ ] Settings'e "Bulut Yedekleme" toggle'ı ekle (varsayılan: Kapalı)
- [ ] Şifreleme anahtarını cihazda güvenli depoda sakla

### Not:

> Mevcut Firestore yapısı zaten kullanıcı başına izole (`users/{uid}/...`), ancak veriler şifrelenmeden duruyor.

---

## 2. DIŞA AKTARMA SINIRLAMASI - Filigran & Uyarı

**Öncelik:** YÜKSEK
**Dosya:** `app/lib/core/services/export_service.dart`

### Yapılacaklar:

- [ ] `shareNoteAsPdf()` - PDF'e kullanıcı adı + tarih filigranı ekle
- [ ] `shareNoteAsText()` - Başa "Kişisel kullanım içindir" uyarısı ekle
- [ ] OCR'dan gelen notlara ek filigran (ders adı, tarih)
- [ ] Export sonrası "Bu içerik kişisel kullanımınız için şifrelenmiştir" uyarısı

### Örnek Filigran Metni:

```
"Kişisel Kullanım - [Kullanıcı Adı] - [Tarih]"
"Bu içerik 5846 Sayılı FSK kapsamında şahsi kullanım amacıyla kaydedilmiştir."
```

---

## 3. KAMERA/OCR İÇİN AÇIK İZİN ONAYI

**Öncelik:** YÜKSEK
**Dosya:** `app/lib/screens/course_detail/course_detail_screen.dart`

### Yapılacaklar:

- [ ] `_captureOcr()` metodundan önce `showDialog()` ekle
- [ ] Dialog içeriği:

```
"Ders içeriğini kaydetmek için öğretim görevlisinden sözlü izin aldığınızı beyan eder misiniz?"

[ ] Evet, izin aldım ve beyan ediyorum

[Devam] [İptal]
```

- [ ] Onay veritabanında `ocr_consent_timestamp` olarak kaydet
- [ ] İzin alınmadan OCR işlemi yapılmasın

---

## 4. WATERMARK SERVİSİ

**Öncelik:** ORTA
**Yeni Dosya:** `app/lib/core/services/watermark_service.dart`

### Yapılacaklar:

- [ ] Her kamera çekiminde fotoğraf üzerine eklenecek:
  - Dersin adı
  - Kullanıcı adı
  - Tarih/saat
  - "Kişisel Kullanım" etiketi
- [ ] Filigran silinemez/stil değiştirilemez olmalı
- [ ] `dart:ui` veya `image` paketi ile watermark ekleme

---

## 5. GİZLİLİK POLİTİKASI & KULLANIM ŞARTLARI

**Öncelik:** YÜKSEK
**Yeni Dosyalar:**

- `app/lib/screens/settings/privacy_policy_screen.dart`
- `app/lib/screens/settings/terms_of_service_screen.dart`

### İçermesi gerekenler:

**Gizlilik Politikası:**

- Hangi veriler toplanıyor (isim, email, ders notları, lokasyon)
- Veriler nerede sakalanıyor (Firebase Firestore, yerel SQLite)
- Verilerin kullanım amacı
- KVKK hakları (silme, taşıma, düzeltme hakkı)
- Üçüncü taraf servisleri (Firebase, Google ML Kit)

**Kullanım Şartları:**

- 5846 Sayılı FSK kapsamında "şahsi kullanım" açıklaması
- Telifli materyallerin sorumluluğu kullanıcıya aittir
- Yüklenen içerikler kullanıcının kendi notları olmalıdır
- Yasadışı kullanım yasaktır

---

## 6. KVKK UYUMLULUK EKRANI

**Öncelik:** YÜKSEK
**Yeni Dosya:** `app/lib/screens/onboarding/kvkk_consent_screen.dart`

### Yapılacaklar:

- [ ] İlk kayıt sonrası göster
- [ ] Gizlilik Politikası linki (okunabilir)
- [ ] Kullanım Şartları linki (okunabilir)
- [ ] Açık onay checkbox'ı (zorunlu)
- [ ] "Verilerimi işleme izni veriyorum" seçeneği
- [ ] Onay `SharedPreferences`'da `kvkk_consent_timestamp` olarak kaydedilsin

### Ekran Akışı:

```
1. Kayıt oldu → KVKK onay ekranı
2. Politika ve şartları oku
3. Onay checkbox'ını işaretle
4. Devam et → Ana uygulama
```

---

## 7. VERİ İŞLEME İLKELERİ

**Öncelik:** DÜŞÜK
**Dosya:** `app/lib/core/database/database_helper.dart`

### Yapılacaklar:

- [ ] `moodle_accounts` ve `moodle_cache` tablolarının kullanımını kontrol et
- [ ] Kullanılmıyorsa kaldır
- [ ] Gereksiz veri toplamayı engelle
- [ ] Sadece zorunlu alanları sakla

---

## 8. UI METİNLERİNİ GÜNCELLEME

**Öncelik:** DÜŞÜK

### Değiştirilecek Mesajlar:

| Eski | Yeni |
|------|------|
| "Notu arkadaşlarınla paylaş" | "Notlarını görüntüle" |
| "Hocanın notunu çek" | "Ders notlarını kaydet" |
| Paylaşım ikonları | Kişisel klasör/arsiv ikonları |

---

## ÖNCELİK SIRASI

```
1. [YÜKSEK] KVKK İzin Ekranı + Gizlilik Politikası        → Yasal zorunluluk
2. [YÜKSEK] Kamera Öncesi İzin Dialogu                     → Hukuki koruma
3. [YÜKSEK] Bulut Yedekleme Opt-in + Şifreleme            → Veri koruma
4. [ORTA]   Watermark Servisi                              → Telif koruma
5. [ORTA]   Export Filigranları                            → Telif koruma
6. [DÜŞÜK]  UI Metinlerini Güncelleme                     → Marka konumlandırma
```

---

## TEKNİK DETAYLAR

### Şifreleme Yaklaşımı:

```dart
// Kullanıcı PIN'i veya cihaz anahtarı ile AES-256
// Anahtar: flutter_secure_storage'da saklanır
// Şifrelenen: Not başlıkları, içerikler, OCR metinleri
```

### Firestore Veri Yapısı (Mevcut - Zaten İzole):

```
users/{uid}/
  ├── courses/
  ├── notes/
  ├── deadlines/
  ├── grades/
  ├── files/
  ├── absences/
  └── planner_events/
```

### KVKK Kapsamında Haklar:

- **Erişim Hakkı:** Kullanıcı kendi verilerini görebilmeli
- **Silme Hakkı:** "Hesabımı Sil" seçeneği olmalı
- **Taşınabilirlik:** Verileri dışa aktarabilmeli (export)
- **Düzeltme:** Verileri düzeltebilmeli

---

## TEST LİSTESİ

- [ ] KVKK onayı olmadan uygulama kullanılamamalı
- [ ] Kamera izni dialogu her OCR çekiminde çıkmalı
- [ ] Şifrelenmemiş veri Firestore'da görünmemeli
- [ ] Export yapılan PDF'lerde filigran görünmeli
- [ ] Hesap silme işlemi tüm verileri temizlemeli
