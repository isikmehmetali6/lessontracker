import 'package:flutter/material.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});

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
          l10n.cookiePolicy,
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
              l10n.cookiePolicy,
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
              'Son güncelleme: 25 Mart 2026',
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
              title: '1. Çerez Nedir?',
              icon: Icons.cookie,
              iconColor: AppColors.amber,
              content:
                  '''Çerezler, cihazınıza (bilgisayar, tablet, akıllı telefon) kaydedilen küçük metin dosyalarıdır. Çerezler, web sitelerinin veya uygulamaların cihazınızı tanımasına ve tercihlerinizi hatırlamasına yardımcı olur.''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '2. Kullandığımız Çerez Türleri',
              icon: Icons.category,
              iconColor: AppColors.blue,
              content: '''Zorunlu Çerezler:
Bu çerezler uygulamanın düzgün çalışması için gereklidir ve kapatılamazlar.

• firebase-auth-session: Firebase ile oturum yönetimi için
• encrypted-key: Şifreleme anahtarı güvenli saklama için
• kvkk_consent_timestamp: KVKK onay durumu için

İsteğe Bağlı Çerezler:
Bu çerezler tercihlerinizi saklamak için kullanılır ve kapatılabilirler.

• cloud_backup_enabled: Bulut yedekleme tercihi
• theme_mode: Karanlık/açık tema tercihi
• language: Dil tercihi
• onboarding_completed: Uygulamaya giriş yapıldı mı''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '3. Üçüncü Taraf Çerezleri',
              icon: Icons.groups,
              iconColor: AppColors.purple,
              content:
                  '''Uygulamamızda aşağıdaki üçüncü taraf servisleri kullanılmaktadır ve bu servisler kendi çerezlerini kullanabilir:

Firebase (Google LLC):
• Kimlik doğrulama
• Bulut veri depolama
• Cloud Messaging

Google ML Kit:
• OCR (Optik Karakter Tanıma) işlemleri
• Not: Görüntüler işlendikten sonra saklanmaz

Yerel Depolama:
• SQLite: Yapılandırılmış uygulama verileri
• Secure Storage: Şifrelenmiş hassas veriler''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '4. Çerezleri Yönetme',
              icon: Icons.settings,
              iconColor: AppColors.emerald,
              content:
                  '''Mobil uygulama olduğumuz için tarayıcı çerezleri geçerli değildir.

Ancak, cihazınızdan uygulama verilerini silebilirsiniz:

iOS (Ayarlar > Genel > iPhone Saklama Alanı > LessonTracker > Verileri Sil)
Android (Ayarlar > Uygulamalar > LessonTracker > Verileri Temizle)

Tüm verilerinizin silinmesini istiyorsanız "Hesabımı Sil" özelliğini kullanabilirsiniz.''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '5. Çerez Kullanım Amaçlarımız',
              icon: Icons.track_changes,
              iconColor: AppColors.orange,
              content:
                  '''• Oturum yönetimi: Kullanıcı girişi ve kimlik doğrulama
• Tercih hatırlama: Tema, dil ve diğer tercihleriniz
• Güvenlik: Şifreleme anahtarları ve oturum güvenliği
• Analiz: Uygulama performansı ve kullanım istatistikleri (anonim)''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '6. Daha Fazla Bilgi',
              icon: Icons.help_outline,
              iconColor: AppColors.emerald,
              content: '''Çerez politikamız hakkında sorularınız için:
E-posta: lessontracker@example.com

KVKK hakkında daha fazla bilgi:
www.kvkk.gov.tr''',
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
    required IconData icon,
    required Color iconColor,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
      ),
    );
  }
}
