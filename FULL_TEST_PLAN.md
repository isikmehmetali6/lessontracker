# LessonTracker - Kapsamlı QA Test Planı

**Hazırlık:** 07 Nisan 2026  
**Versiyon:** 1.0  
**Durum:** Tüm Fonksiyonel Testler

---

## 1. Authentication (Kullanıcı Doğrulama)

### 1.1 Kayıt & Giriş
| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| AUTH-01 | Geçerli kayıt | Geçerli email + 6+ karakter şifre ile kayıt | Başarılı kayıt, ana ekrana yönlendirme |
| AUTH-02 | Geçersiz email | Email: "test@", Şifre: "123456" | "Geçersiz email formatı" hatası |
| AUTH-03 | Kısa şifre | Email: "test@test.com", Şifre: "123" | "Şifre en az 6 karakter olmalı" hatası |
| AUTH-04 | Mevcut email | Daha önce kayıt olunmuş email ile tekrar kayıt | "Bu email zaten kayıtlı" hatası |
| AUTH-05 | Doğru giriş | Email + şifre ile giriş | Ana ekrana yönlendirme |
| AUTH-06 | Yanlış şifre | Mevcut email + yanlış şifre | "Email veya şifre hatalı" hatası |
| AUTH-07 | Şifre sıfırlama | "Şifremi Unuttum" → email gönder | Email ile sıfırlama linki gelir |

### 1.2 Misafir & Oturum
| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| AUTH-08 | Misafir girişi | "Misafir olarak devam et" seçeneği | Alert dialog: "Veriler lokalde tutulacak" → onay → ana ekran |
| AUTH-09 | Oturum sürekliliği | Login → app'i kapat → tekrar aç | Oturum korunur, tekrar login gerekmez |
| AUTH-10 | Çıkış yapma | Settings → Çıkış yap | SQLite temizlenir → Login ekranı |

---

## 2. Onboarding & İzinler

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| PERM-01 | Kamera izni (OCR) | Fotoğraf notu ekle → ilk sefer | Sistem izin dialogu |
| PERM-02 | Kamera reddi | İzni reddet → fotoğraf çek | Uyarı gösterir, uygulama çökmez |
| PERM-03 | Mikrofon izni | Sesli not başlat | Sistem izin dialogu |
| PERM-04 | Mikrofon reddi | İzni reddet → kayıt başlat | Uyarı gösterir, uygulama çökmez |
| PERM-05 | Bildirim izni | İlk açılış veya ayarlardan etkinleştir | Sistem izin dialogu |
| PERM-06 | Takvim izni | Deadline → takvime ekle | Sistem izin dialogu |

---

## 3. Ders Yönetimi (Course Management)

### 3.1 Ders Ekleme
| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| COURSE-01 | Başarılı ekleme | Tüm zorunlu alanlar doldurulur | Ders eklenir, listeye eklenir |
| COURSE-02 | Eksik bilgi | Ders adı boş → Kaydet | "Ders adı gerekli" hatası |
| COURSE-03 | Geçersiz saat | Bitiş < Başlangıç | "Bitiş saati başlangıçtan önce olamaz" hatası |
| COURSE-04 | Renk seçimi | Farklı renk seçimi | Seçilen renk ders kartında görünür |

### 3.2 Çakışma Kontrolü
| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| COURSE-05 | Aynı gün/ saat | Pazartesi 10:00-12:00 ekle → tekrar 11:00-13:00 ekle | "Ders çakışması var" uyarısı |
| COURSE-06 | Update'de çakışma | Mevcut dersi düzenlerken kendisiyle çakışma | Çakışma uyarısı VERMEMELİ (excludeId kullanımı) |

### 3.3 Ders Silme (Cascade Delete)
| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| COURSE-07 | Cascade silme | Ders sil → ilgili notlarabak | Notlar, dosyalar, yoklamalar, notlar SILİNMİŞ |
| COURSE-08 | Bulut silme | Ders sil → Firebase console bak | Buluttan da silinmiş |
| COURSE-09 | Dosya temizliği | Ders sil → cihaz depolama kontrol | Fiziksel dosyalar silinmiş |

### 3.4 Ders Düzenleme & Arşiv
| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| COURSE-10 | Düzenleme | Ad, saat, renk, limit değiştir | Değişiklikler kaydedilir |
| COURSE-11 | Arşivleme | Ders → arşivle | Ana ekranda görünmez, veriler korunur |

---

## 4. Ana Ekran (Home Screen)

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| HOME-01 | Günlük ilerleme | Bugün 2 ders var → ilerleme çemberini kontrol et | %50 dolu (2/4 saat vs) |
| HOME-02 | İstatistik özetleri | Yaklaşan deadline, risk dersi sayısı | Doğru hesaplanmış değerler |
| HOME-03 | Bugünkü dersler | Bugünün dersleri listelenir | Geçmiş dersler soluk (opacity 0.65) |
| HOME-04 | Priority Focus | Yatay liste, risk dersleri kırmızı arka plan | Sorunlu dersler öne çıkar |

---

## 5. Devamsızlık Takibi (Absences)

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| ABS-01 | Yoklama ekleme | + butonu → yoklama sayısı +1 | 1 artar, veritabanına kaydedilir |
| ABS-02 | Limit aşımı | 3 limitli derste 4. yoklama | Kırmızı uyarı ikonu |
| ABS-03 | Yoklama silme | Son yoklamayı sil | Sayı 1 azalır |
| ABS-04 | Yoklama resetleme | Tümünü sil | Sıfıra döner |

---

## 6. Deadlines & Takvim

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| DEAD-01 | Deadline ekleme | Tarih + ders + tür (Homework/Exam) seç | Liste başına eklenir |
| DEAD-02 | Ders içinden ekleme | Ders detayında + → dialog açılır | Ders otomatik seçili |
| DEAD-03 | Takvime ekleme | Switch ON → cihaz takvimine ekle | Takvimde etkinlik görünür |
| DEAD-04 | Sıralama | Deadline listesini kontrol et | En yakın tarih en üstte |
| DEAD-05 | Geçmiş deadline | Tarihi geçmiş deadline | Kırmızı renkte gösterilir |
| DEAD-06 | Deadline düzenleme | Edit → bilgi değiştir | Güncellenir |
| DEAD-07 | Deadline silme | Swipe veya sil butonu | Silinir |

---

## 7. Notlar (Notes) & Multimodal Capture

### 7.1 Metin Notları
| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| NOTE-01 | Metin notu ekle | Başlık + içerik yaz → kaydet | Ders detayında görünür |
| NOTE-02 | Not düzenleme | Mevcut notu aç → içerik değiştir | Güncellenir |
| NOTE-03 | Not silme | Notu sil | Listeden kalkar |

### 7.2 Ses Kayıtları
| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| VOICE-01 | Kayıt başlat | Mic → kayda başla | Kayıt devam eder, süre artar |
| VOICE-02 | Kayıt duraklat | Duraklat butonu | Duraklar, tekrar başlatılabilir |
| VOICE-03 | Kayıt bitir | Durdur → kaydet | Dosya kaydedilir |
| VOICE-04 | Ses oynatma | Play butonu | Ses çalar |
| VOICE-05 | Ses dosyası kalıcılığı | Kayıt → app kapat → aç → oynat | Dosya hala mevcut |

### 7.3 OCR / Kamera
| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| OCR-01 | Fotoğraf çek | Kamera aç → çek → onayla | Fotoğraf notta görünür |
| OCR-02 | OCR işleme | Fotoğraftan metin algıla | Metin not içeriğine eklenir |
| OCR-03 | PDF dönüştürme | Fotoğraf → PDF'e çevir | PDF oluşur, Files sekmesinde görünür |

### 7.4 El Yazısı
| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| HAND-01 | Canvas açılır | El yazısı modu → canvas açılır | Beyaz tuval görünür |
| HAND-02 | Çizim yap | Parmakla çiz | Çizim görünür |
| HAND-03 | Temizle & Kaydet | Clear → Save | Canvas temizlenir, kaydedilir |

---

## 8. Notlandırma & GPA

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| GRADE-01 | Not ekleme | Tür (Vize/Final/Proje) + puan/max + ağırlık | Not eklenir, ortalama güncellenir |
| GRADE-02 | Ağırlık uyarısı | Toplam ağırlık > %100 | Warning gösterilir, kayıt devam eder |
| GRADE-03 | Ağırlık hesabı | 2 not ekle: %50 ağırlık 70/100, %50 ağırlık 80/100 | Ortalama: 75 |
| GRADE-04 | Sıfıra bölünme | Sadece ağırlıksız not | Crash olmaz, "N/A" gösterilir |
| GRADE-05 | Not silme | Notu sil | Ortalama güncellenir |

---

## 9. Moodle Entegrasyonu

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| MOOD-01 | Bağlantı | URL + credentials → giriş yap | Başarılı bağlantı, dersler gelir |
| MOOD-02 | Bağlantı hatası | Yanlış şifre veya internet yok | Snackbar/Dialog hatası |
| MOOD-03 | Senkronizasyon | Sync butonu → ders/ödev/duyuru çek | Veriler gelir |
| MOOD-04 | Dosya indirme | Moodle dosyası → indir | Dosya cihaza kaydedilir |
| MOOD-05 | Offline erişim | Interneti kapat → önceden çekilenleri aç | Veriler görüntülenir |

---

## 10. Bulut Senkronizasyonu & Offline

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| SYNC-01 | Offline çalışma | Interneti kapat → app aç | Crash olmaz, cached veriler görünür |
| SYNC-02 | Offline veri ekleme | Internet kapalı → ders ekle | SQLite'a kaydedilir |
| SYNC-03 | Manuel yedekleme | Ayarlar → Backup | Progress gösterir, Firebase'e yükler |
| SYNC-04 | Geri yükleme | Başka cihaz → Restore | Firebase'den veri çekilir, UI güncellenir |
| SYNC-05 | Start Fresh | Ayarlar → Start Fresh | SQLite + Firebase TEMİZLİĞİYLE silinir |

---

## 11. Bildirimler (Notifications)

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| NOTIF-01 | Ders hatırlatıcısı | 15 dk önce → bildirim gelir | Bildirim görünür |
| NOTIF-02 | Dersi sessize alma | Bildirimi kapat (course) → bekle →bildirim gelmez | Sadece o ders kapalı |
| NOTIF-03 | Tüm bildirimleri kapat | Ayarlardan kapat → bekle | Hiçbir bildirim gelmez |
| NOTIF-04 | Moodle bildirimleri | Yeni duyuru → bildirim gelir | Bildirim görünür |

---

## 12. UI/UX & Edge Cases

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| UI-01 | Dark mode | Tema değiştir → tüm ekranları kontrol et | Kontrast sorunu yok |
| UI-02 | Light mode | Tema değiştir → tüm ekranları kontrol et | Kontrast sorunu yok |
| UI-03 | Uzun metin taşması | Çok uzun ders adı gir → kaydet | "..." ile kesilir, ekran bozulmaz |
| UI-04 | Klavye yönetimi | Formda klavye aç → Save butonu | Buton klavyenin üstünde |
| UI-05 | Ekran döndürme | Telefonu yatay çevir | UI çökmez (veya kitli olduğu görünür) |
| UI-06 | Çoklu tıklama | Save'a spam tıkla | 2 kez kayıt olmaz, form korunur |
| UI-07 | Boş liste | Hiç ders yok → ana ekran | "Ders ekleyin" mesajı görünür |
| UI-08 | Arama yapma | Arama çubuğuna yaz → sonuçlar | İlgili sonuçlar filtrelenir |

---

## 13. Ayarlar (Settings)

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| SET-01 | Tema değiştirme | Karanlık/Açık seç | Tema değişir, uygulanır |
| SET-02 | Dil değiştirme | TR/EN seç | UI dili değişir |
| SET-03 | Bildirim ayarları | Süre seçimi (15/30/60 dk) | Hatırlatmalar ayarlanan sürede gelir |
| SET-04 | App lock | PIN/Şifre ayarla → kilit | App kilitlenir, PIN ile açılır |
| SET-05 | Hesap silme | Hesabı sil → tüm veriler | Tüm veriler silinir |

---

## 14. Performans Testleri

| ID | Test Senaryosu | Adımlar | Beklenen Sonuç |
|----|----------------|---------|----------------|
| PERF-01 | 100+ ders ekleme | Çok sayıda ders ekle → liste scroll | 60 FPS üzerinde scroll |
| PERF-02 | 1000+ not ekleme | Çok sayıda not ekle → arama | < 1 sn sonuç |
| PERF-03 | App açılış süresi | Cold start ölç | < 3 saniye |
| PERF-04 | Bellek sızıntısı | 10 dk kullan → bellek takibi | Bellek artışı < 50 MB |

---

## Test Sonuç Takip Tablosu

| Modül | Toplam | Geçen | Başarısız | Beklemede |
|-------|--------|-------|-----------|-----------|
| Authentication | 10 | | | |
| Permissions | 6 | | | |
| Course Management | 11 | | | |
| Home Screen | 4 | | | |
| Absences | 4 | | | |
| Deadlines | 7 | | | |
| Notes | 14 | | | |
| Grades | 5 | | | |
| Moodle | 5 | | | |
| Sync & Offline | 5 | | | |
| Notifications | 4 | | | |
| UI/UX | 8 | | | |
| Settings | 5 | | | |
| Performance | 4 | | | |
| **TOPLAM** | **92** | | | |

---

## Öncelikli Risk Alanları

1. **Moodle entegrasyonu** - Üniversiteye özel API farklılıkları
2. **Offline senkronizasyonu** - Veri kaybı riski
3. **Cascade delete** - Kalıcı veri silme
4. **OCR kalitesi** - El yazısı tanıma başarısı

---

*Test eden:* _________________  
*Tarih:* _________________  
*İmza:* _________________