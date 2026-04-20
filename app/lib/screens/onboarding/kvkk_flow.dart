import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import 'aydinlatma_screen.dart';
import 'acik_riza_screen.dart';

class KvkkOnboardingFlow extends StatefulWidget {
  final VoidCallback onComplete;

  const KvkkOnboardingFlow({super.key, required this.onComplete});

  @override
  State<KvkkOnboardingFlow> createState() => _KvkkOnboardingFlowState();
}

class _KvkkOnboardingFlowState extends State<KvkkOnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skipAndComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'kvkk_consent_timestamp',
      DateTime.now().millisecondsSinceEpoch,
    );
    await prefs.setBool('consent_declined', true);
    await prefs.setBool('consent_camera', false);
    await prefs.setBool('consent_audio', false);
    await prefs.setBool('consent_ocr', false);
    await prefs.setBool('consent_notifications', false);
    await prefs.setBool('consent_cloud_backup', false);
    if (mounted) {
      widget.onComplete();
    }
  }

  Future<void> _resetConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('kvkk_consent_timestamp');
    await prefs.remove('consent_declined');
    await prefs.remove('consent_camera');
    await prefs.remove('consent_audio');
    await prefs.remove('consent_ocr');
    await prefs.remove('consent_notifications');
    await prefs.remove('consent_cloud_backup');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('KVKK onayı sıfırlandı - uygulamayı yeniden açın'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: [
              AydinlatmaScreen(onContinue: _goToNextPage),
              AcikRizaScreen(
                onConsentGiven: widget.onComplete,
                onSkip: _skipAndComplete,
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: _resetConsent,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.red.withValues(alpha: 0.7),
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '🔄 Reset',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _skipAndComplete,
                    style: TextButton.styleFrom(
                      foregroundColor: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    child: const Text('Atla'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageIndicator(0, isDark),
                const SizedBox(width: 8),
                _buildPageIndicator(1, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, bool isDark) {
    final isActive = _currentPage >= index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : (isDark ? Colors.white24 : Colors.black26),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
