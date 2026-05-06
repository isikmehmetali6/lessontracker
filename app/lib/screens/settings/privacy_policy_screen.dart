import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.privacyPolicy,
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.privacyPolicy,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Son güncelleme: 24 Mart 2026',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              isDark: isDark,
              title: '1. Toplanan Veriler',
              content:
                  '''LessonTracker uygulaması, size en iyi hizmeti sunabilmek için aşağıdaki verileri toplar:

• Kimlik Bilgileri: Ad, e-posta adresi (Google hesabı ile kayıt)
• Ders Bilgileri: Ders adları, notlar, ödev tarihleri, yoklama bilgileri
• Not İçerikleri: Metin notları, OCR ile tanımlanan içerikler, ses kayıtları
• Kullanım Verileri: Uygulama kullanım istatistikleri, çalışma süreleri
• Cihaz Bilgileri: Cihaz modeli, işletim sistemi versiyonu''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '2. Verilerin Saklanması',
              content: '''Verileriniz aşağıdaki şekillerde saklanır:

• Yerel Depolama (SQLite): Cihazınızda yerel olarak saklanan veriler
• Firebase Firestore: Bulut yedeklemesi için şifrelenmiş olarak saklanan veriler
• Google ML Kit: OCR işlemleri için geçici olarak işlenen görüntüler

Verileriniz şifrelenmiş olarak saklanır ve yalnızca sizin erişiminizle kullanılabilir.''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '3. Verilerin Kullanım Amacı',
              content: '''Toplanan veriler aşağıdaki amaçlarla kullanılır:

• Ders takibi ve organizasyonu
• Not ve ödev yönetimi
• Yoklama takibi
• Çalışma süresi istatistikleri
• Bulut yedekleme ve senkronizasyon
• OCR ile metin tanıma''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '4. Üçüncü Taraf Servisleri',
              content:
                  '''Uygulamamızda aşağıdaki üçüncü taraf servisleri kullanılmaktadır:

• Firebase: Kimlik doğrulama ve bulut veri depolama
• Google ML Kit: OCR (Optik Karakter Tanıma) işlemleri
• Google Sign-In: Kullanıcı girişi

Bu servislerin gizlilik politikalarını incelemenizi öneririz.''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '5. KVKK Haklarınız',
              content:
                  '''6698 sayılı KVKK kapsamında aşağıdaki haklara sahipsiniz:

• Erişim Hakkı: Kişisel verilerinize erişim talep etme
• Silme Hakkı: Verilerinizin silinmesini talep etme
• Düzeltme Hakkı: Yanlış verilerin düzeltilmesini isteme
• Taşınabilirlik Hakkı: Verilerinizi dışa aktarma
• İşlemenin Kısıtlanmasını Talep Hakkı
• İtiraz Hakkı: Kişisel verilerinizin işlenmesine itiraz etme

Bu haklarınızı kullanmak için uygulama içi "Hesabımı Sil" seçeneğini kullanabilir veya bizimle iletişime geçebilirsiniz.''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '6. Veri Güvenliği',
              content:
                  '''Verilerinizi korumak için aşağıdaki önlemleri alıyoruz:

• AES-256 şifreleme ile veri güvenliği
• Firebase Security Rules ile erişim kontrolü
• Güvenli ağ iletişimi (HTTPS/TLS)
• Kullanıcı PIN koruması (opsiyonel)''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '7. Veri Saklama Süresi',
              content:
                  '''Verileriniz, hesabınız aktif olduğu sürece saklanır. Hesabınızı sildiğinizde, tüm kişisel verileriniz 30 gün içinde kalıcı olarak silinir.''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '8. İletişim',
              content:
                  '''Gizlilik politikamız hakkında sorularınız için lessontracker@example.com adresinden bize ulaşabilirsiniz.''',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required bool isDark,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
