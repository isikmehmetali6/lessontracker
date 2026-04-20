import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Kullanım Şartları',
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
              'Kullanım Şartları',
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
              title: '1. Kabul Şartları',
              content:
                  '''LessonTracker uygulamasını kullanarak, bu kullanım şartlarını kabul etmiş sayılırsınız. Şartları kabul etmiyorsanız, lütfen uygulamayı kullanmayın.''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '2. Kişisel Kullanım Amacı',
              content:
                  '''LessonTracker, kişisel verimlilik ve ders takibi amacıyla tasarlanmış bir uygulamadır. 5846 sayılı Fikir ve Sanat Eserleri Kanunu (FSK) kapsamında:

• Uygulamaya yüklediğiniz notlar ve içerikler kendi kişisel notlarınız olmalıdır
• Telifli materyalleri (ders kitapları, makaleler, sunumlar vb.) izinsiz yüklememelisiniz
• OCR özelliğini kullanırken, öğretim görevlisinden sözlü izin aldığınızı beyan etmeniz gerekmektedir
• Yüklenen içeriklerin telif hakları size aittir veya içerikleri kullanma hakkına sahip olmalısınız''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '3. Yasadışı Kullanım Yasağı',
              content: '''Aşağıdaki kullanımlar yasaktır:

• Telif haklarıyla korunan materyallerin izinsiz depolanması veya dağıtılması
• Başkalarının özel notlarını izinsiz kaydetmek
• Uygulamayı yasadışı faaliyetler için kullanmak
• Başkalarının gizliliğini ihlal eden içerikler yüklemek
• Kötü niyetli yazılım veya zararlı içerikler yüklemek''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '4. Telif Hakkı Sorumluluğu',
              content:
                  '''• Uygulamaya yüklediğiniz içeriklerin telif hakları size aittir
• Telifli materyallerin izinsiz kullanımından doğabilecek sorumluluk tamamen size aittir
• Üçüncü taraf içeriklerini yüklemeden önce gerekli izinleri almanız gerekmektedir
• LessonTracker, kullanıcıların yüklediği içeriklerin telif haklarını kontrol etmez ve sorumlu tutulamaz''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '5. Filigran ve Koruma',
              content: '''Yasal uyumluluk kapsamında:

• Dışa aktarılan PDF dosyalarına otomatik filigran eklenir
• Kamera ile çekilen görüntülere ders adı, kullanıcı adı ve tarih bilgisi eklenir
• Filigranlar kaldırılamaz veya değiştirilemez
• Filigranlı içerikler "Kişisel Kullanım" amacıyla işaretlenir''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '6. Hesap ve Güvenlik',
              content: '''• Hesabınızın güvenliğinden siz sorumlusunuz
• Google hesabınız ile giriş yapıyorsanız, bu hesabın güvenliğini sağlamanız gerekmektedir
• Hesabınızda yetkisiz erişim tespit ederseniz derhal bizimle iletişime geçin
• Hesabınızı başkalarıyla paylaşmayın''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '7. Hizmet Değişiklikleri',
              content:
                  '''LessonTracker, hizmetini önceden haber vermeksizin değiştirme veya sonlandırma hakkını saklı tutar. Önemli değişiklikler olması durumunda sizi bilgilendirmeye çalışacağız.''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '8. Sorumluluk Sınırlaması',
              content:
                  '''LessonTracker, uygulamanın kullanımından kaynaklanan doğrudan veya dolaylı zararlardan sorumlu değildir. Uygulamayı "olduğu gibi" kullanırsınız.''',
            ),
            const SizedBox(height: 20),
            _buildSection(
              isDark: isDark,
              title: '9. İletişim',
              content:
                  '''Kullanım şartları hakkında sorularınız için lessontracker@example.com adresinden bize ulaşabilirsiniz.''',
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
