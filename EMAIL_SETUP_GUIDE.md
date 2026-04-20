# Email Doğrulama Sistemi - Setup Rehberi

## Genel Bakış

Firebase Cloud Functions + Nodemailer kullanılarak gerçek email doğrulama sistemi implement edilmiştir.

---

## Kurulum

### 1. Firebase CLI ve Functions SDK

```bash
# Firebase CLI kontrol et
firebase --version

# Functions klasörüne git
cd functions

# Bağımlılıkları yükle
npm install

# Environment variables ayarla (email hesabı)
firebase functions:config:set email.user="your-email@gmail.com" email.pass="your-app-password"
```

### 2. Gmail App Password Almak

Gmail hesabınızdan email göndermek için App Password gerekiyor:

1. Google Account → Security → 2-Step Verification etkinleştir
2. App Passwords sayfasına git
3. "LessonTracker" için 16 karakterlik app password oluştur
4. Bu password'u `firebase functions:config:set email.pass="xxxx xxxx xxxx xxxx"` olarak ayarla

**Not:** Gmail yerine SendGrid, Mailgun veya AWS SES kullanmak daha güvenli olabilir.

### 3. Cloud Functions Deploy

```bash
# Sadece email fonksiyonunu deploy et
firebase deploy --only functions:sendVeliVerificationEmail

# Tüm functions'ı deploy et
firebase deploy --only functions
```

### 4. Firebase Planı

**ÖNEMLİ:** Cloud Functions HTTP trigger **Blaze plan** gerektirir.

- Spark plan: Sadece Firebase内部 çağrılar
- Blaze plan: Dışarıdan HTTP istekleri + kullanım başına ücret

Blaze plan ~2000 email/ay ücretsiz kota içerir.

---

## Fonksiyon Detayları

### Endpoint
```
POST https://us-central1-PROJECT_ID.cloudfunctions.net/sendVeliVerificationEmail
```

### Request Body
```json
{
  "email": "veli@ornek.com",
  "code": "123456",
  "veliName": "Ahmet"
}
```

### Response
```json
{
  "success": true,
  "message": "Doğrulama emaili gönderildi",
  "remainingRequests": 2
}
```

---

## Güvenlik Özellikleri

### 1. Rate Limiting
- 5 dakikada max 3 istek per email
- Aşım durumunda cooldown süresi döner

### 2. Input Validation
- Email format kontrolü (regex)
- 6 haneli numeric code kontrolü

### 3. Error Handling
- Başarısız email gönderimi kullanıcıya bildirilir
- Cloud Function hataları log'lanır

---

## Fallback Mekanizması

Cloud Function başarısız olursa:
1. Email gönderilemez
2. Ama kod yine de SharedPreferences'a kaydedilir
3. **Aynı cihazda** doğrulama yapılabilir

**Güvenlik Notu:** Bu fallback sadece geliştirme/test için kullanılmalı. Production'da email zorunlu olmalı.

---

## Email Template

Profesyonel HTML email template:
- LessonTracker branding
- 6 haneli büyük doğrulama kodu
- 30 dakika geçerlilik uyarısı
- Güvenlik notları
- Responsive tasarım

---

## Test Etmek

```bash
# Local emulator ile test et
firebase emulators:start

# curl ile manual test
curl -X POST http://localhost:5001/PROJECT_ID/us-central1/sendVeliVerificationEmail \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","code":"123456","veliName":"Test"}'
```

---

## Sorun Giderme

### Email Gelmiyor
1. Spam/Junk klasörünü kontrol et
2. Gmail App Password'un doğru olduğunu kontrol et
3. Cloud Function log'larını kontrol et: `firebase functions:log sendVeliVerificationEmail`
4. Firebase Blaze plan'ın aktif olduğunu kontrol et

### "permission denied" Hatası
- Cloud Function deployment'ın başarılı olduğunu kontrol et
- Firebase Console → Functions → yetkilendirme ayarlarını kontrol et

### Rate Limit Hatası
- 5 dakika bekleyip tekrar dene
- Veya farklı email adresi kullan

---

## Maliyet

| İşlem | Maliyet |
|-------|---------|
| Cloud Function (invocation) | ~$0.40/1M |
| Email (Gmail) | Ücretsiz |
| Cloud Function (compute) | ~$0.02-0.10/1M |

2000 email/ay ~$0.10 maliyet eder.

---

## Alternatif Email Servisleri

### SendGrid (Önerilen)
```javascript
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

sgMail.send({
  to: email,
  from: 'noreply@lessontracker.com',
  subject: 'Veli Onayı',
  html: htmlContent,
});
```

### AWS SES
```javascript
const AWS = require('aws-sdk');
const ses = new AWS.SES({ region: 'eu-west-1' });
```

---

*Tarih: 7 Nisan 2026*