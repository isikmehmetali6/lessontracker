import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AydinlatmaScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const AydinlatmaScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: AppColors.blue,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Aydınlatma Metni',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '6698 sayılı KVKK Madde 10 kapsamında bilgilendirme',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSection(
                      isDark: isDark,
                      title: '1. Veri Sorumlusu',
                      icon: Icons.business,
                      iconColor: AppColors.primary,
                      content:
                          'LessonTracker\nE-posta: lessontracker@example.com\nWeb: www.lessontracker.com',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      isDark: isDark,
                      title: '2. İşlenen Kişisel Veriler',
                      icon: Icons.storage,
                      iconColor: AppColors.orange,
                      content: '''
• Kimlik Bilgileri: Ad, e-posta adresi, Google hesabı
• Eğitim Verileri: Ders adları, notlar, yoklama bilgileri, notlar
• Görsel Veriler: Fotoğraflar (filigranlı), OCR ile tanımlanan içerikler
• Ses Verileri: Ses kayıtları
• Teknik Veriler: Cihaz bilgisi, uygulama logları (anonim)''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      isDark: isDark,
                      title: '3. Kişisel Verilerin İşlenme Amaçları',
                      icon: Icons.track_changes,
                      iconColor: AppColors.purple,
                      content: '''
• Ders takibi ve organizasyonu
• Not ve ödev yönetimi
• Yoklama takibi
• Çalışma süresi istatistikleri
• Bulut yedekleme ve senkronizasyon (opsiyonel)
• OCR ile metin tanıma
• Push bildirimleri (Firebase Cloud Messaging)''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      isDark: isDark,
                      title: '4. Kişisel Verilerin Aktarılması',
                      icon: Icons.sync_alt,
                      iconColor: AppColors.emerald,
                      content: '''
Kişisel verileriniz aşağıdaki üçüncü taraflara aktarılabilir:

• Firebase (Google LLC, ABD)
  → Kimlik doğrulama ve bulut veri depolama
  → Yeterli güvence mekanizması mevcut

• Google ML Kit
  → OCR işlemleri için geçici görüntü işleme
  → Veriler işlendikten sonra silinir''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      isDark: isDark,
                      title: '5. Saklama Süresi',
                      icon: Icons.timer,
                      iconColor: AppColors.amber,
                      content: '''
• Kişisel verileriniz, hesabınız aktif olduğu sürece saklanır
• Hesabınızı sildiğinizde, tüm verileriniz 30 gün içinde kalıcı olarak silinir
• Yasal yükümlülükler saklama sürelerini uzatabilir''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      isDark: isDark,
                      title: '6. Veri Güvenliği',
                      icon: Icons.security,
                      iconColor: AppColors.red,
                      content: '''
• AES-256 şifreleme ile veri koruma
• Firebase Security Rules ile erişim kontrolü
• Güvenli ağ iletişimi (HTTPS/TLS)
• Şifreleme anahtarı cihazda güvenli depoda saklanır''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      isDark: isDark,
                      title: '7. Haklarınız (KVKK Madde 11)',
                      icon: Icons.gavel,
                      iconColor: AppColors.blue,
                      content: '''
KVKK kapsamında aşağıdaki haklara sahipsiniz:

• Erişim Hakkı: Kişisel verilerinize erişim talep etme
• Silme Hakkı: Verilerinizin silinmesini talep etme
• Düzeltme Hakkı: Yanlış verilerin düzeltilmesini isteme
• Taşınabilirlik Hakkı: Verilerinizi dışa aktarma
• İşlemenin Kısıtlanmasını Talep Hakkı
• İtiraz Hakkı: İşlemeye itiraz etme

Bu haklarınızı kullanmak için lessontracker@example.com adresinden bize ulaşabilirsiniz.''',
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      isDark: isDark,
                      title: '8. Daha Fazla Bilgi',
                      icon: Icons.help_outline,
                      iconColor: AppColors.emerald,
                      content: '''
• Gizlilik Politikası: Uygulama içi "Ayarlar > Gizlilik Politikası"
• Kullanım Şartları: Uygulama içi "Ayarlar > Kullanım Şartları"
• Çerez Politikası: Uygulama içi "Ayarlar > Çerez Politikası"
• KVKK: www.kvkk.gov.tr
• ALO 198: Kişisel Verileri Koruma Kurumu hattı''',
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Aydınlatma metnini okudum ve bilgilendirildim.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Anladım, Devam Et',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
