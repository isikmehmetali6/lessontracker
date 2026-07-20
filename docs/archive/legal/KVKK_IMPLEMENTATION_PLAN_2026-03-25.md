# KVKK Uyumluluk Implementation Planı - LessonTracker

**Tarih:** 25 Mart 2026
**Kaynak:** KVKK 2026/347 Sayılı İlke Kararı ve KVKK Resmi Rehberleri
**Durum:** Mevcut Durum Analizi + Eksiklikler + Implementasyon Planı

---

## Özet: KVKK Uyumluluk Matrisi

| Gereklilik | KVKK Madde | Mevcut Durum | Öncelik |
|------------|-----------|--------------|---------|
| Aydınlatma Metni (Ayrı) | Madde 10 | ⚠️ Kısmen | KRITIK |
| Açık Rıza Metni (Ayrı) | Madde 10 | ⚠️ Aynı Metinde | KRITIK |
| Kamera Öncesi İzin Dialog | FSK Uyumu | ✅ Var | - |
| Fotoğraf Filigranı | FSK Uyumu | ✅ Var | - |
| PDF Export Filigranı | FSK Uyumu | ✅ Var | - |
| Metin Paylaşım Uyarısı | FSK Uyumu | ✅ Var | - |
| Bulut Yedekme Opt-in | Madde 5 | ⚠️ Kısmen | ORTA |
| Şifreleme (AES-256) | Madde 12 | ⚠️ Kısmen | YÜKSEK |
| Hesap Silme | Madde 7 | ❌ Yok | KRITIK |
| VERBİS Kaydı | Madde 3 | ⚠️ Kontrol Edilmeli | ORTA |
| Çerez Aydınlatma | Çerez KVKK | ❌ Yok | DÜŞÜK |
| 18 Yaş Altı Kontrolü | Çocuk KVKK | ❌ Yok | ORTA |
| Veri İşleme Envanteri | Madde 3 | ❌ Yok | ORTA |

---

## 1. KRITIK SORUN: Aydınlatma ve Açık Rıza Metinlerinin Ayrılması

### 1.1 KVKK 2026/347 Sayılı Karar Gereklilikleri

KVKK, **18 Şubat 2026** tarihli **2026/347 sayılı İlke Kararı**'nda açıkça belirtiyor:

> "Aydınlatma metni ve açık rıza metinleri **farklı başlıklar altında ayrı ayrı metinler** olarak düzenlenmelidir."

**Yayınlanma:** 24 Mart 2026 - Hemen uygulanmalı!

### 1.2 Mevcut Sorun

```dart
// ❌ MEVCUT (HATALI) - kvkk_consent_screen.dart
// Aydınlatma ve Açık Rıza tek panelde birleştirilmiş
// Kullanıcı sadece "okudum" diyerek onay vermiş oluyor

Scaffold(
  body: Column(
    children: [
      Text('KVKK Açık Rıza Metni'),  // HATA: Başlık yanıltıcı
      Checkbox('Gizlilik Politikası okudum'),
      Checkbox('Kullanım Şartları okudum'),
      Checkbox('Kişisel verilerimin işlenmesini kabul ediyorum'),
      // Problem: Aydınlatma yok, sadece "onay" var
    ],
  ),
)
```

### 1.3 Olması Gereken Yapı

```
EKRAN 1 - AYDINLATMA METNİ (Sadece bilgilendirme, onay gerekmez):
┌─────────────────────────────────────────┐
│ ← Geri    Aydınlatma Metni              │
├─────────────────────────────────────────┤
│                                         │
│ 1. Veri Sorumlusu                       │
│ LessonTracker / lessontracker@example.com│
│                                         │
│ 2. İşlenen Kişisel Veriler              │
│ • Kimlik: Ad, e-posta, Google hesabı    │
│ • Eğitim: Ders notları, yoklama, notlar │
│ • Ses/Görüntü: Ses kaydı, fotoğraf      │
│ • Teknik: Cihaz bilgisi, loglar         │
│                                         │
│ 3. İşleme Amaçları                      │
│ • Ders takibi ve organizasyonu          │
│ • Not ve ödev yönetimi                  │
│ • Bulut yedekleme (opsiyonel)           │
│ • OCR ile metin tanıma                  │
│                                         │
│ 4. Verilerin Aktarımı                   │
│ • Firebase (ABD) - Yeterli güvence     │
│ • Google ML Kit - OCR için              │
│                                         │
│ 5. Saklama Süresi                       │
│ • Hesabınız aktif olduğu sürece         │
│ • Hesap silindiğinde 30 gün içinde      │
│                                         │
│ 6. Haklarınız (KVKK Madde 11)          │
│ • Erişim, silme, düzeltme, taşınma     │
│ • İşlemenin kısıtlanmasını talep etme   │
│                                         │
├─────────────────────────────────────────┤
│              [Anladım, Devam Et]         │
└─────────────────────────────────────────┘

EKRAN 2 - AÇIK RIZA METNİ (Ayrı onay gerekir):
┌─────────────────────────────────────────┐
│ ← Geri    Açık Rıza                    │
├─────────────────────────────────────────┤
│                                         │
│ ⚠️ Aşağıdaki işlemler için açık rızanız│
│    kanunen gerekmektedir (KVKK 5/1, 6/2)│
│                                         │
│ ☑ Kamera ile fotoğraf çekme             │
│   → Ders notlarını fotoğraflama         │
│                                         │
│ ☑ Ses kaydı alma                        │
│   → Ders ses kaydı                      │
│                                         │
│ ☑ Google ML Kit ile OCR işleme          │
│   → Fotoğraftan metin çıkarma          │
│                                         │
│ ☑ Firebase Cloud Messaging              │
│   → Push bildirimleri                  │
│                                         │
│ ☑ Bulut yedekleme (opsiyonel)          │
│   → Verilerin şifreli saklanması       │
│                                         │
├─────────────────────────────────────────┤
│    [Açık Rızayı Ver ve Devam Et]        │
│ ─────────────────────────────────────── │
│      [Rıza Vermeden Devam Et]            │
│  (Sadece temel özellikler kullanılır)   │
└─────────────────────────────────────────┘
```

### 1.4 Implementasyon Detayları

**Mevcut Dosya:** `app/lib/screens/onboarding/kvkk_consent_screen.dart` (DEĞİŞTİRİLECEK)

**Yeni Dosyalar:**
```
app/lib/screens/onboarding/
├── aydinlatma_screen.dart           # Aydınlatma metni (onay gerektirmez)
├── acik_riza_screen.dart             # Açık rıza (ayrı onay gerekir)
└── kvkk_onboarding_flow.dart        # 2 adımlı akış koordinatörü
```

**kvkk_onboarding_flow.dart:**
```dart
class KvkkOnboardingFlow extends StatelessWidget {
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        AydinlatmaScreen(
          onContinue: () => Navigator.push(... AcikRizaScreen()),
        ),
        AcikRizaScreen(
          onConsentGiven: onComplete,
          onSkip: onComplete, // Rıza vermeden devam
        ),
      ],
    );
  }
}
```

---

## 2. HESAP SİLME ÖZELLİĞİ (KVKK Madde 7)

### 2.1 Yasal Gereklilik

KVKK Madde 7: "İlgili kişi, kişisel verilerinin silinmesini, yok edilmesini veya anonim hale getirilmesini talep etme hakkına sahiptir."

### 2.2 Mevcut Durum

```dart
// ❌ YOK - privacy_policy_screen.dart'da bahsediliyor ama implementasyon yok:
// "Bu haklarınızı kullanmak için uygulama içi 'Hesabımı Sil' seçeneğini kullanabilirsiniz"
```

### 2.3 Implementasyon Planı

**Güncellenecek:** `app/lib/screens/settings/widgets/settings_about_section.dart`

**Eklenen Dosya:** `app/lib/screens/settings/delete_account_dialog.dart`

```dart
// delete_account_dialog.dart
class DeleteAccountDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 8),
          Text('Hesabı Silmek Üzeresiniz'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu işlem geri alınamaz. Aşağıdaki verileriniz kalıcı olarak silinecektir:',
          ),
          SizedBox(height: 16),
          _buildBullet('Tüm ders notlarınız'),
          _buildBullet('Ses kayıtlarınız'),
          _buildBullet('Fotoğraflarınız ve OCR verileriniz'),
          _buildBullet('Yoklama ve not kayıtlarınız'),
          _buildBullet('Çalışma oturumlarınız'),
          _buildBullet('Firebase hesabınız'),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Verileriniz 30 gün içinde kalıcı olarak silinecektir.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Vazgeç'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _handleDeleteAccount(context),
          child: Text('Hesabımı Sil'),
        ),
      ],
    );
  }
}
```

**SyncService'e Eklenen Metod:**
```dart
/// Tüm kullanıcı verilerini sil
Future<void> deleteAllUserData() async {
  final user = _auth.currentUser;
  if (user == null) throw Exception('Kullanıcı giriş yapmamış');

  // 1. Firestore'daki tüm verileri sil
  await _firestore.collection('users').doc(user.uid).delete();

  // 2. Firebase Storage'daki dosyaları sil
  final storageRef = FirebaseStorage.instance.ref('users/${user.uid}');
  await storageRef.deleteAll();

  // 3. Firebase Auth hesabını sil
  await user.delete();

  // 4. Local database'i temizle
  await DatabaseHelper().deleteAllData();

  // 5. Secure storage'ı temizle
  await _secureStorage.deleteAll();

  // 6. SharedPreferences'ı temizle
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
```

---

## 3. ÇEREZ AYDINLATMA METNİ

### 3.1 Yasal Gereklilik

KVKK kapsamında çerez/izleme teknolojileri için aydınlatma yapılmalı. Firebase ve Google ML Kit kullanılıyor.

### 3.2 Mevcut Durum

```dart
// ❌ YOK - Çerez aydınlatma metni uygulamada bulunmuyor
```

### 3.3 Implementasyon Planı

**Yeni Dosya:** `app/lib/screens/settings/cookie_policy_screen.dart`

```dart
class CookiePolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Çerez Politikası')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('1. Çerez Nedir?', '''
Çerezler, cihazınıza kaydedilen küçük metin dosyalarıdır. 
Uygulamamız, kullanıcı deneyimini iyileştirmek için çerezler kullanır.
'''),
            _buildSection('2. Kullandığımız Çerez Türleri', '''
Zorunlu Çerezler:
• firebase-auth-session: Oturum yönetimi için
• encrypted-key: Şifreleme anahtarı saklama için

İsteğe Bağlı Çerezler:
• cloud_backup_enabled: Bulut yedekleme tercihi
• theme_mode: Karanlık/açık tema tercihi
• language: Dil tercihi
'''),
            _buildSection('3. Üçüncü Taraf Çerezleri', '''
• Firebase Authentication (Google)
• Google ML Kit (OCR için geçici işleme)
'''),
            _buildSection('4. Çerezleri Yönetme', '''
Mobil uygulama olduğumuz için tarayıcı çerezleri geçerli değildir.
Cihaz ayarlarınızdan uygulama verilerini silebilirsiniz.
'''),
          ],
        ),
      ),
    );
  }
}
```

---

## 4. VERBİS KAYDI KONTROLÜ

### 4.1 Yasal Gereklilik

KVKK Madde 3: Veri Sorumluları Siciline (VERBİS) kayıt yükümlülüğü.

### 4.2 Eşik Değerleri

VERBİS kaydı gereken durumlar:
- Yıllık çalışan sayısı **50+**
- Yıllık mali işlem hacmi **25 milyon TL+**
- Merkez dışında şube açılması

### 4.3 Yapılması Gereken

```markdown
┌─────────────────────────────────────────┐
│ VERBİS Kaydı Kontrol Listesi            │
├─────────────────────────────────────────┤
│ □ Şirket çalışan sayısı < 50 mi?       │
│ □ Yıllık ciro < 25 milyon TL mi?       │
│ □ Sadece Türkiye'de faaliyet mi?       │
│                                         │
│ Eğer HEPSİ "Evet":                      │
│ → VERBİS kaydı gerekli DEĞİL            │
│                                         │
│ Eğer herhangi biri "Hayır":             │
│ → VERBİS kaydı gereklidir               │
│ → https://verbis.kvkk.gov.tr            │
└─────────────────────────────────────────┘
```

---

## 5. ÇOCUK KULLANICILAR İÇİN KONTROL

### 5.1 Yasal Gereklilik

KVKK, 18 yaş altı için ek koruma öngörmese de, GDPR etkisiyle çocuk kullanıcılar için veli onayı önerilmektedir.

Kaynak: [KVKK Çocuk Kullanıcılar İçin Ebeveynlere Yönelik Tavsiyeler](https://www.kvkk.gov.tr/Icerik/8580/)

### 5.2 Mevcut Durum

```dart
// ❌ YOK - Yaş kontrolü ve veli onayı mekanizması yok
```

### 5.3 Implementasyon Planı

```dart
// Kayıt akışında doğum tarihi sorgulama
class RegisterScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mevcut e-posta, şifre alanları...

        // YENİ: Doğum tarihi
        DatePickerField(
          label: 'Doğum Tarihiniz',
          onChanged: (date) {
            if (_calculateAge(date) < 18) {
              _showVeliOnayDialog();
            }
          },
        ),
      ],
    );
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showVeliOnayDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Veli Onayı Gerekli'),
        content: Text(
          '18 yaşın altındaki kullanıcıların uygulamayı kullanabilmesi '
          'için veli onayı gerekmektedir.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Veli e-postası doğrulamasına yönlendir
            },
            child: Text('Veli Onayı Ver'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. VERİ İŞLEME ENVANTERİ

### 6.1 LessonTracker Veri İşleme Envanteri

| Veri Kategorisi | Veri Türü | İşleme Amacı | Hukuki Sebep | Saklama Süresi |
|-----------------|-----------|--------------|--------------|-----------------|
| Kimlik | Ad, E-posta | Hesap oluşturma | Sözleşme kurulması | Hesap süresince |
| Kimlik | Google ID | Google ile giriş | Açık rıza | Hesap süresince |
| Eğitim | Ders notları | Ders takibi | Meşru menfaat | Hesap süresince |
| Eğitim | Yoklama kaydı | Yoklama takibi | Meşru menfaat | Hesap süresince |
| Eğitim | Not/Notlar | Başarı takibi | Meşru menfaat | Hesap süresince |
| Görsel | Fotoğraf (filigranlı) | Ders kaydı | Açık rıza | Hesap süresince |
| Görsel | OCR sonucu | Metin çıkarma | Açık rıza | Hesap süresince |
| Ses | Ses kaydı | Ders kaydı | Açık rıza | Hesap süresince |
| Teknik | Cihaz bilgisi | Debugging | Meşru menfaat | 1 yıl |
| Teknik | Uygulama logları | Hata ayıklama | Meşru menfaat | 90 gün |

---

## 7. MEVCUT ÖZELLİKLERİN KVKK UYUMU KONTROLÜ

### 7.1 WatermarkService (✅ Uyumlu)

```dart
// WatermarkService - FSK uyumu için fotoğraflara filigran ekliyor
// Yasal dayanak: 5846 Sayılı FSK kapsamında kişisel kullanım

class WatermarkService {
  static String _buildWatermarkText({
    required String courseName,
    required String userName,
  }) {
    return '''
Kişisel Kullanım
Ders: \$courseName
Kullanıcı: \$userName
Tarih: \${_formatDate(DateTime.now())}
''';
    // 5846 Sayılı FSK kapsamında şahsi kullanım amacıyla kaydedilmiştir.
  }
}
```

### 7.2 ExportService Filigranları (✅ Uyumlu)

```dart
// PDF ve metin paylaşımında filigran
// _buildWatermarkFooter() - PDF footer'da filigran
// shareNoteAsText() - Metnin başında "Kişisel kullanım" uyarısı
```

### 7.3 OCR İzin Dialogu (✅ Uyumlu)

```dart
// _showOcrConsentDialog() - Kamera/OCR öncesi izin alınıyor
// FSK kapsamında öğretim izni beyanı isteniyor
```

---

## 8. DETAYLI IMPLEMENTASYON PLANI

### Sprint 1: Kritik Düzeltmeler (2 gün)

| Görev | Dosya | Durum |
|-------|-------|-------|
| AydinlatmaScreen oluştur | `onboarding/aydinlatma_screen.dart` | YAPILACAK |
| AcikRizaScreen oluştur | `onboarding/acik_riza_screen.dart` | YAPILACAK |
| KvkkOnboardingFlow oluştur | `onboarding/kvkk_flow.dart` | YAPILACAK |
| Eski KvkkConsentScreen kaldır | `onboarding/kvkk_consent_screen.dart` | YAPILACAK |
| Onboarding akışına entegre et | `onboarding/main.dart` | YAPILACAK |

### Sprint 2: Hesap Silme (1 gün)

| Görev | Dosya | Durum |
|-------|-------|-------|
| DeleteAccountDialog oluştur | `settings/delete_account_dialog.dart` | YAPILACAK |
| "Hesabımı Sil" butonu ekle | `settings/settings_about_section.dart` | YAPILACAK |
| deleteAllUserData() metodu ekle | `core/services/sync_service.dart` | YAPILACAK |
| deleteAccount() metodu ekle | `providers/auth_provider.dart` | YAPILACAK |

### Sprint 3: Çerez ve VERBİs (0.5 gün)

| Görev | Dosya | Durum |
|-------|-------|-------|
| CookiePolicyScreen oluştur | `settings/cookie_policy_screen.dart` | YAPILACAK |
| Gizlilik politikası altına ekle | `settings/settings_about_section.dart` | YAPILACAK |
| LEGAL_COMPLIANCE_PLAN.md güncelle | - | YAPILACAK |

### Sprint 4: Çocuk Kullanıcılar (1 gün)

| Görev | Dosya | Durum |
|-------|-------|-------|
| Doğum tarihi sorgulama ekle | `auth/register_screen.dart` | YAPILACAK |
| Veli onay dialogu oluştur | `auth/veli_onay_dialog.dart` | YAPILACAK |
| Veli e-posta doğrulaması | `auth/veli_email_verify.dart` | YAPILACAK |

---

## 9. ÖNCELİK SIRASI

```
1. [KRITIK] KVKK 2026/347 Uyumlu Aydınlatma + Açık Rıza Ayrımı
   → 18 Şubat 2026 tarihli karar - 24 Mart 2026'da yayınlandı
   → Hemen uygulanmalı - ceza riski

2. [KRITIK] Hesap Silme Özelliği (KVKK Madde 7)
   → "Hesabımı Sil" butonu gizlilik politikasında vaat edildi
   → Implementasyon yok - risk: Tüketicinin hak arama süreleri

3. [YÜKSEK] AES-256 Şifreleme Tam Implementasyonu
   → SyncService'de var ama doğrulama gerekli
   → Firebase Rules kontrol edilmeli

4. [ORTA] Çerez Aydınlatma Metni
   → Yasal gereklilik ama düşük öncelik

5. [ORTA] Çocuk Kullanıcı Kontrolü (18 yaş altı)
   → GDPR etkisiyle öneriliyor

6. [ORTA] VERBİS Kaydı Kontrolü
   → Eşik değerler kontrol edilmeli

7. [DÜŞÜK] Veri İşleme Envanteri Dokümantasyonu
   → Kurumsal olgunluk göstergesi
```

---

## 10. TEST LİSTESİ

### 10.1 KVKK Uyumluluk Testleri

- [ ] Aydınlatma metni ayrı ekranda gösteriliyor
- [ ] Açık rıza ayrı ekranda ve ayrı onay alınıyor
- [ ] Kamera izni dialogu her OCR çekiminde çıkıyor
- [ ] Fotoğraflara filigran ekleniyor
- [ ] PDF export'ta filigran görünüyor
- [ ] Metin paylaşımında "Kişisel kullanım" uyarısı var
- [ ] Hesap silme işlemi tüm verileri temizliyor
- [ ] Firebase Auth hesabı siliniyor
- [ ] Yerel SQLite temizleniyor
- [ ] Çerez politikası görüntülenebiliyor
- [ ] 18 yaş altı için veli onayı çalışıyor

### 10.2 Teknik Testler

- [ ] Firebase Rules sadece kullanıcının kendi verisine erişim sağlıyor
- [ ] Şifreleme anahtarı flutter_secure_storage'da saklanıyor
- [ ] Veri silme işlemi Firestore'dan user/uid altını temizliyor
- [ ] Cloud Storage'daki dosyalar siliniyor
- [ ] SharedPreferences temizleniyor

---

## 11. KAYNAKLAR VE REFERANSLAR

### Yasal Metinler

- [KVKK 2026/347 Sayılı İlke Kararı](https://www.resmigazete.gov.tr/eskiler/2026/03/20260324-3.pdf)
- [KVKK Açık Rıza ve Aydınlatma Ayrımı Duyurusu](https://www.kvkk.gov.tr/Icerik/8710/)
- [KVKK Açık Rıza Alırken Dikkat Edilecek Hususlar](https://www.kvkk.gov.tr/Icerik/2037/Acik-Riza-Alirken-Dikkat-Edilecek-Hususlar)
- [KVKK Özel Nitelikli Kişisel Veriler](https://www.kvkk.gov.tr/Icerik/2051/Ozel-Nitelikli-Kisisel-Veriler)

### KVKK Rehberleri

- [Ürün ve Hizmet Geliştirenler İçin KVKK Rehberi (PDF)](https://www.kvkk.gov.tr/SharedFolderServer/CMSFiles/f506d8fe-9f36-4538-bce9-a05a5ca8d8e6.pdf)
- [Çocuklar İçin KVKK Ebeveyn Rehberi](https://www.kvkk.gov.tr/Icerik/8026/Ebeveynler-Icin-Afisler)
- [Yapay Zeka Kullanan Çocuklar İçin Ebeveynlere Yönelik Tavsiyeler](https://www.kvkk.gov.tr/Icerik/8580/)

### VERBİS

- [VERBİS Kayıt Portalı](https://verbis.kvkk.gov.tr)
- [Veri Sorumluları Sicili Nedir?](https://www.kvkk.gov.tr/Icerik/2043/Veri-Sorumlulari-Sicili-Nedir)

---

## 12. CHANGELOG

| Tarih | Değişiklik |
|-------|------------|
| 25.03.2026 | İlk versiyon - KVKK 2026/347 uyumu eklendi |
