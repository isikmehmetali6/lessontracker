# 📋 TODO List — Lesson Tracker

> Last Updated: 21 Nisan 2026
> Status: **Web deployment PAUSED** - Focus on mobile app only

---

## 🔴 Yapılacaklar (Mobile App Priority)

### 1. Firebase Email Verification
- [ ] **Firebase Console SMTP Ayarları**
  - Sender name ekle (şu an "not provided")
  - Custom domain bağla ve doğrula
  - Domain doğrulaması tamamla
- [ ] **Email Verification'ı aktif et** (`main.dart`)
  - Şu an comment out edildi, SMTP ayarları tamamlanınca aç
- [ ] Test: Gerçek email ile kayıt ol, verification email al ve doğrula

---

### 2. Moodle Senkronizasyonu — Ders Ekleme
- [ ] **Add Course Screen'e Moodle senkron butonu ekle**
  - Eğer kullanıcı Moodle hesabı bağlıysa, "Moodle'dan Senkronize Et" butonu göster
  - Tıklandığında Moodle'daki dersleri getir ve listele
  - Kullanıcı hangi dersleri ekleyeceğini seçsin
  - Seçilen dersler yerel veritabanına ekle ve Moodle course ID'sini kaydet
- [ ] **MoodleCourse modeline `moodleId` ve `syncStatus` ekle**
- [ ] **CourseProvider'a `syncFromMoodle()` metodu ekle**
- [ ] **UI: Course eklerken Moodle sync seçeneği**

---

### 3. Cloud Functions
- [ ] Email sending cloud function'ı deploy et
- [ ] Weekly report cloud function'ı deploy et
- [ ] Moodle sync cloud function'ı deploy et
- [ ] Functions URL'lerini `.env`'e ekle (`CLOUD_FUNCTIONS_URL`)

---

### 3. Firebase Security Rules
- [ ] Firestore security rules yaz (production için)
- [ ] Storage security rules yaz
- [ ] Authentication üzerinde yetkilendirme kuralları

---

### 4. Testing & QA
- [ ] Tüm UI component'leri mobile'da test et
- [ ] Auth flow test et (sign up, sign in, sign out, guest mode)
- [ ] Database CRUD işlemleri test et
- [ ] E2E test yaz (Flutter integration_test)

---

### 5. Performance & Optimization
- [ ] Web build optimization (`flutter build web --release`)
- [ ] App bundle size optimization

---

## ❌ Web Deployment DURDU
- [x] Web'e odaklanma iptal edildi
- [x] Mobile app geliştirmeye devam edilecek

---

## ✅ Tamamlananlar
- [x] Firebase Web API key ve config yapılandırması
- [x] Email verification UI hazır (ama disabled)

---

## 🔗 Bağlantılar
- Firebase Console: https://console.firebase.google.com/project/lessontracker-1beeb
- Flutter Documentation: https://docs.flutter.dev