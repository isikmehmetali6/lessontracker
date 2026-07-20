# Firebase Cloud Functions - Email Doğrulama Sistemi

## Genel Bakış

Bu dokümantasyon, LessonTracker uygulamasındaki veli onayı email doğrulama sistemini Firebase Cloud Functions kullanarak gerçek email gönderim sistemine dönüştürmeyi açıklar.

---

## 1. Kurulum

### 1.1 Firebase CLI Kurulumu

```bash
npm install -g firebase-tools
firebase login
```

### 1.2 Functions Dizini

```bash
cd functions
npm install
```

---

## 2. Environment Variables Ayarlama

### 2.1 Gmail Kullanımı

1. **2 Adımlı Doğrulama** etkinleştirin (Google Account > Security)
2. **App Passwords** oluşturun:
   - Google Account > Security > 2-Step Verification > App passwords
   - "Mail" uygulaması için 16 karakterlik bir şifre oluşturun

3. **Environment variables** ayarlayın:

```bash
firebase functions:config:set email.user="your-email@gmail.com" email.pass="xxxx xxxx xxxx xxxx"
```

### 2.2 alternatif Email Servisleri

#### SendGrid
```bash
firebase functions:config:set email.service="sendgrid" email.user="apikey" email.pass="SG.xxx"
```

```javascript
const transporter = nodemailer.createTransport({
  service: 'SendGrid',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});
```

#### Mailgun
```bash
firebase functions:config:set email.service="mailgun" email.user="postmaster@mg.domain.com" email.pass="your-mailgun-key"
```

---

## 3. Cloud Function Deployment

### 3.1 Deploy Komutu

```bash
cd functions
firebase deploy --only functions:sendVeliVerificationEmail
```

### 3.2 Tüm Fonksiyonları Deploy Etme

```bash
firebase deploy --only functions
```

---

## 4. Spark Plan Uyarısı

**ÖNEMLİ:** Firebase Cloud Functions'ın ücretsiz **Spark plan**ı sadece **HTTP trigger** destekler ve **dış ağ bağlantısı YOKTUR**.

### Çözüm: Blaze Planına Geçiş

1. Firebase Console > Billing
2. "Upgrade to Blaze" seçin
3. Kredi kartı bağlayın (Spark plan gibi ücretsiz kullanım devam eder)

**Spark Plan Kullanım Limitleri:**
- CPU: 100,000 GHz-sanıye/ay
- İnvocations: 2,000,000/ay
- Ücret: Kullanım başına ~$0.40/million (Blaze plan)

---

## 5. Rate Limiting

Cloud Function'da built-in rate limiting mevcut:
- 5 dakika içinde max **3 istek** per email
- Spam koruması için otomatik temizlik

---

## 6. Frontend Entegrasyonu

### Kullanım

```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<void> _sendVerificationEmail(String email, String code) async {
  final functions = FirebaseFunctions.instance;
  final callable = functions.httpsCallable('sendVeliVerificationEmail');
  
  final result = await callable.call({
    'email': email,
    'code': code,
    'veliName': 'Veli',
  });
  
  if (result.data['success'] == true) {
    // Başarılı
  }
}
```

---

## 7. Test Etme

### Local Emulator

```bash
firebase emulators:start --only functions
```

### Manual Test

```bash
curl -X POST http://localhost:5001/project-id/us-central1/sendVeliVerificationEmail \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","code":"123456","veliName":"Test"}'
```

---

## 8. Monitoring

### Logs查看
```bash
firebase functions:log sendVeliVerificationEmail
```

### Error Tracking
Firebase Console > Functions > Dashboard

---

## 9. Güvenlik Notları

1. **Email/password asla hardcode edilmemeli** - Environment variables kullan
2. **Rate limiting** her zaman aktif
3. **Input validation** Cloud Function tarafında yapılıyor
4. **HTTPS** zorunlu (Cloud Functions otomatik HTTPS)

---

## 10. Troubleshooting

### Email Gönderilmiyor
1. Blaze planına upgrade edildi mi?
2. Environment variables doğru ayarlandı mı?
3. Gmail App Password doğru mı?

### Rate Limit Hatası
5 dakika bekleyin veya farklı email kullanın

### CORS Hatası
Cloud Functions otomatik CORS headers ekler - ek bir ayar gerekmez