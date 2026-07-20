# Lesson Tracker: App Store Ready QA Test Plan

Bu belge, uygulamanın App Store / Google Play Store'da yayınlanmadan önce geçmesi gereken **Tüm Kapsamlı (End-to-End) Kalite Güvence (QA) Testlerini** içerir. Testler, kullanıcı deneyimini, veri bütünlüğünü ve donanım entegrasyonlarını kapsar.

---

## 1. Kullanıcı Doğrulama (Authentication) Testleri
- [ ] **Kayıt Olma (Sign Up):** Geçerli e-posta ve şifre ile başarılı kayıt.
- [x] **Hatalı Kayıt:** Zaten var olan e-posta, geçersiz e-posta formatı veya kısa şifre ile kayıt denemesinde doğru hata mesajlarının (UI üzerinde) görünmesi. (auth_flow_test.dart)
- [ ] **Giriş Yapma (Sign In):** Doğru bilgilerle giriş yapıldığında ana ekrana yönlendirme.
- [ ] **Şifre Sıfırlama:** "Şifremi Unuttum" akışının çalışması ve e-postaya sıfırlama linki gitmesi.
- [x] **Misafir Modu (Guest Mode):** Hesapsız girişin çalışması, verilerin sadece lokalde (SQLite) tutulacağının kullanıcıya bildirilmesi. (auth_flow_test.dart)
- [ ] **Çıkış Yapma (Log Out):** Çıkış yapıldığında yerel verilerin temizlenmesi (SQLite [clearAllData()](file:///Users/mehmetaliisik/Desktop/lessontracker/app/lib/core/database/database_helper.dart#532-556)) ve uygulamanın Giriş Ekranına dönmesi.
- [ ] **Oturum Sürekliliği (Persistence):** Uygulama tamamen kapatılıp (kill app) açıldığında kullanıcının hesabında kalmaya devam etmesi.

---

## 2. Onboarding ve İzinler (Permissions)
- [ ] **Kamera İzni:** OCR / Fotoğraf notu eklenmeye çalışıldığında izin istenmesi. Reddedildiğinde uygulamanın çökmemesi ve uyarı göstermesi.
- [ ] **Mikrofon İzni:** Sesli not (Voice Memo) kaydedileceği zaman izin istenmesi ve reddedilirse çökmemesi.
- [ ] **Bildirim (Notification) İzni:** Ders hatırlatıcıları veya Moodle bildirimleri için izin istenmesi.
- [x] **Takvim İzni:** Bir teslim tarihi (deadline) takvime eklenmek istendiğinde izin kontrolünün yapılması. (Info.plist NSCalendarsUsageDescription + Android READ/WRITE_CALENDAR)

---

## 3. Ders Yönetimi (Course Management)
- [ ] **Ders Ekleme:** Geçerli bir ad, renk, gün(ler) ve saat ile ders eklenebilmesi.
- [x] **Çakışma Kontrolü (Conflict Prevention):** Aynı gün ve aynı saat aralığına denk gelen ikinci bir ders eklenmeye çalışıldığında uygulamanın çakışma hatası göstermesi.
- [ ] **Ders Düzenleme:** Dersin adı, saati, rengi, devamsızlık limiti veya profesör bilgilerinin sorunsuz güncellenebilmesi.
- [x] **Ders Silme (Derin Silme/Cascading):** (Fixed in previous session)
  - [x] Uygulama içinden silindiğinde Ana Ekranda ve Yoklama listelerinde kaybolması.
  - [x] **Kritik:** Silinen derse ait Notların, Dosyaların, Ödevlerin, Notların(Grades) ve Devamsızlıkların hem yerel SQLite'tan hem de Firebase Cloud'dan (**SyncService ile**) silinmesinin doğrulanması.
  - [x] Mümkünse telefondaki önbelleklenmiş ses ve resim dosyalarının da (device storage) temizlenmesi.
- [ ] **Arşivleme:** Dersin arşivlendiğinde Ana Ekranda (Bugünkü dersler vs.) görünmemesi ancak verilerinin (notlar) korunması.

---

## 4. Ana Ekran (Home Screen) & Widgetlar
- [ ] **Günlük İlerleme (Daily Progress):** Çember grafiğinin o günkü ders saatlerine göre doğru dolması ve hesaplamanın mantıklı olması.
- [x] **İstatistik Özetleri (Home Stats Summary):** Toplam ders, yaklaşan ödev (7 gün içinde) ve "Riskte olan" (devamsızlık limiti %70'e ulaşmış) ders sayılarının anlık ve doğru güncellenmesi. (Integration tests passing)
- [x] **Bugünkü Dersler (Today's Schedule):** O günün tarihiyle eşleşen derslerin listelenmesi ve saati geçenlerin doğru sırayla veya görsel farkla belirtilmesi. (Bitmiş dersler opacity 0.65 ile gösteriliyor)
- [x] **Priority Focus (Öncelikli Odak):** (Fixed in previous session)
  - [x] Tüm aktif derslerin listede görünmesi (yatay kaydırılabilir şekilde).
  - [x] Yaklaşan sınavı veya devamsızlık/puan sorunu olanların UI üzerinde kırmızı (veya belirgin) arka planla gösterilmesi.

---

## 5. Devamsızlık Takibi (Absences)
- [x] **Devamsızlık Ekleme:** Ana ekrandan veya ders detayından "+" butonuna basılarak devamsızlık sayısının 1 artırılması. (absence_provider_test.dart)
- [x] **Limit Kontrolü:** Devamsızlık limiti (örn. 3) aşıldığında veya yaklaşıldığında kullanıcıya görsel uyarı (Kırmızı ikon/renk) verilmesi. (absence_provider_test.dart)
- [x] **Devamsızlık Çıkarma:** Son devamsızlığın silinmesi ve sayacın hatasız olarak geriye düşmesi. (absence_provider_test.dart)

---

## 6. Deadlines (Teslim Tarihleri / Ödevler / Sınavlar)
- [x] **Deadline Ekleme:** Tarih, ders ve süre (Homework, Exam vs.) seçilecek şekilde başarıyla eklenmesi.
- [x] **Ders İçinden Deadline Ekleme:** Ders sayfasındaki sağ üstteki App Bar ikonuna tıklandığında dialog'un o dersi otomatik seçmiş olarak açılması.
- [ ] **Cihaz Takvimine Ekleme (Add to Calendar):** Switch açıldığında cihazın ana takvimine ilgili etkinliğin doğru gün ve başlıkla eklenmesi.
- [x] **Sıralama:** Deadline listesinde tarihi en yakın olanın en üstte görünmesi ve tarihi geçenlerin kırmızı/ayırt edici renkle gösterilmesi. (deadline_provider_extended_test.dart)
- [x] **Silme & Düzenleme:** Başarıyla silinmesi ve isim/tarih gibi bilgilerin Edit moduyla değiştirilebilmesi. (deadline_provider_extended_test.dart)

---

## 7. Notlar (Notes) & Quick Capture
- [x] **Metin Notu (Text Note):** Başlık ve içerik yazılarak kaydedilmesi, ders detayındaki "Notes" sekmesinde görünmesi. (note_provider_test.dart)
- [ ] **Ses Kaydı (Voice Memo):**
  - [ ] Kaydı başlatma, duraklatma ve bitirme işlemlerinin sorunsuz olması.
  - [x] Kaydedilen sesin uygulamanın medya oynatıcısından oynatılabilmesi (Play/Pause işlevleri). (Fixed in previous session)
  - [ ] Ses dosyasının telefondan doğru yolda tutulduğunun ve uygulama yeniden başlatıldığında hala çalınabildiğinin teyidi.
- [ ] **Kamera / OCR (Scan Notes):**
  - [ ] Kameranın açılıp çekilen fotoğrafın başarıyla uygulamaya aktarılması.
  - [ ] OCR modülüyle fotoğraftaki metnin algılanıp not içeriğine text olarak eklenmesi.
- [ ] **Fotoğraftan PDF'e (Photo to PDF):** Bu özellik varsa PDF çıktısının oluşturulması ve "Files" sekmesinde harici PDF görüntüleyici ile açılabilmesi.

---

## 8. Notlandırma ve GPA (Grades)
- [x] **Not Ekleme:** Vize, Final veya Proje notunun, alınan puan / maksimum puan / ağırlık (% katkısı) belirtilerek eklenmesi. (grade_provider_test.dart)
- [x] **Ağırlık Kontrolü:** Eklenen notların ağırlıklarının toplamının %100'ü geçtiği durumlarda uyarı (Warning) mesajının tetiklenmesi ancak işlemin kaydedilmesi. (grade_provider_test.dart)
- [x] **Ortalama (Weighted Average):** Ders detayında gösterilen ortalamanın eklenen ağırlıklara ve puanlara göre hatasız, net matematiksel hesapla gösterilmesi. (grade_provider_test.dart, course_provider_test.dart)

---

## 9. Moodle Entegrasyonu (Gelişmiş)
- [ ] **Moodle Girişi:** Kurum URL'si ve doğru Moodle kullanıcı/şifresiyle bağlantı kurulması.
- [ ] **Bağlantı Hatası:** İnternet yokken veya yanlış şifreyle girildiğinde uygulamanın çökmeyip Snackbar / Dialog hatası vermesi.
- [ ] **Senkronizasyon (Sync):** Moodle'daki derslerin, takvimdeki etkinliklerin (Event/Deadline) ve dosyaların başarıyla uygulamaya çekilmesi.
- [ ] **Offline Erişim:** İnternet kapatıldığında, Moodle'dan önceden çekilen verilerin (SQLite önbelleği sayesinde) uygulama içinde görüntülenebilmesi.

---

## 10. Bulut Senkronizasyonu & Çevrimdışı Çalışma (Sync & Offline)
- [ ] **Offline Çalışma:** İnternet kapalıyken uygulama açıldığında çökme olmaması, önbellekteki/SQLite'taki Ana Sayfa, Dersler, Notlar ve Ödevlerin sorunsuz görüntülenmesi.
- [ ] **Offline Veri Ekleme:** İnternetsiz ortamda bir Ders veya Not eklendiğinde başarıyla SQLite'a kaydedilmesi.
- [ ] **Manuel Yedekleme (Backup to Cloud):** Ayarlar sayfasından "Backup Data" butonuna basıldığında telefondaki (yerel) verilerin Firebase Firestore'a iletilmesi ve Progress Bar / Uyarıların doğru çalışması.
- [ ] **Buluttan Geri Yükleme (Restore from Cloud):** Farklı bir cihazda aynı hesaba girip "Restore Data" dendiğinde, Firebase'deki son derslerin, notların ve devamsızlıkların o cihaza aktarılıp UI'ın güncellenmesi.
- [x] **Start Fresh (Sıfırdan Başla):** (Fixed in previous session)
  - [x] "Start Fresh" dendiğinde lokal SQLite verilerinin ([clearAllData()](file:///Users/mehmetaliisik/Desktop/lessontracker/app/lib/core/database/database_helper.dart#532-556)) TAMAMEN SİLİNMESİ.
  - [x] **Çok Önemli:** Firebase'deki bulut yedeğin de (SyncService.clearCloudData) kalıcı olarak silinmesi ve böylece eski yedeklerin boş/temiz veriyle çakışmasının engellenmesi.

---

## 11. Bildirimler (Notifications)
- [ ] **Ders Hatırlatıcı:** Ayarlardan hatırlatma süresi (örn. 15 dk) seçildiğinde, ders başlamadan 15 dk önce "Local Notification" (bildirim) gelmesi.
- [ ] **Dersi Sessize Alma (Mute Course):** Ders detayından "Notifications: Off" dendiğinde sadece o derse ait hatırlatmaların durması ancak diğer derslerin gelmeye devam etmesi.
- [ ] **Genel Bildirimleri Kapatma:** Ayarlardan tüm bildirimler kapatıldığında hiçbir dersten hatırlatıcı gelmemesi.

---

## 12. UI/UX, Performans ve Uç Durumlar (Edge Cases)
- [x] **Dark/Light Mode (Karanlık Tema Düzeni):** Ayarlardan veya sistem ayarından tema değiştirildiğinde yazılarda okunmaz hale gelen beyaz-üzeri-beyaz veya siyah-üzeri-siyah kontrast sorunları olmaması (Tüm ekranlar, formlar ve bottom sheet'ler test edilmeli). (ui_ux_test.dart)
- [x] **Metin Taşması (Text Overflow):** Çok uzun bir ders adı, not başlığı veya profesör adı girildiğinde ekranın bozulmaması (RenderFlex overflow); metnin "..." (ellipsis) ile kesilmesi veya alt satıra geçmesi. (course_detail_app_bar, course_detail_header_info, add_deadline dropdown)
- [x] **Form Validasyonları:** Ders eklerken ders adı yazılmadan Save tuşuna basıldığında veya Saat hatalı (Bitiş saati < Başlangıç saati) girildiğinde uyarı çıkması. (add_course, add_grade, add_deadline)
- [x] **Uygulama İçi Klavye Yönetimi:** Herhangi bir sayfada klavye açıldığında altta kalan Save/Add butonlarının klavyenin üstüne çıkması (SafeArea/Bottom Inset) ve ekranın kapanıp ulaşılamaz hale gelmemesi. (ui_ux_test.dart)
- [x] **Ekran Rotasyonları (Orientation):** Destekleniyorsa, telefonu yatay ve dikey konuma getirince UI'ın çökmemesi. (Sadece dikey destekleniyorsa rotasyonun kitli olduğunun teyidi). (ui_ux_test.dart)
- [x] **Çoklu Tıklama Koruması:** Butonlara çok hızlı (spam) tıklandığında formun 2 kez veritabanına kayıt atıp atmadığının test edilmesi (Örn: Peş peşe Save butonuna basmak). (add_deadline_dialog, add_grade_dialog)
