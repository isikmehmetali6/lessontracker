import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/moodle_universities.dart';
import '../../../providers/moodle_provider.dart';

/// 3-adımlı Moodle hesap ekleme bottom sheet.
/// Adım 1: Üniversite seç (arama + liste)
/// Adım 2: Kullanıcı adı + şifre gir
/// Adım 3: Bağlantı başarı/hata ekranı
class AddMoodleAccountSheet extends StatefulWidget {
  const AddMoodleAccountSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddMoodleAccountSheet(),
    );
  }

  @override
  State<AddMoodleAccountSheet> createState() => _AddMoodleAccountSheetState();
}

class _AddMoodleAccountSheetState extends State<AddMoodleAccountSheet>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  final _searchController = TextEditingController();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _step = 0; // 0=Üniversite, 1=Giriş, 2=Sonuç
  MoodleUniversity? _selectedUniversity;
  bool _useManualUrl = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _resultError;
  String? _resultMessage;
  String? _resultCoursesFound;

  List<MoodleUniversity> get _filteredUniversities {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return kMoodleUniversities;
    return kMoodleUniversities
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.baseUrl.toLowerCase().contains(q))
        .toList();
  }

  String get _effectiveBaseUrl =>
      _useManualUrl ? _urlController.text.trim() : (_selectedUniversity?.baseUrl ?? '');

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _resultError = null;
    });
    _goToStep(2);

    final provider = context.read<MoodleProvider>();
    final result = await provider.addAccount(
      baseUrl: _effectiveBaseUrl,
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.success) {
        final account = provider.accounts.last;
        final courseCount =
            provider.coursesFor(account.id).length;
        _resultMessage = 'Hoş geldin, ${account.fullName}!';
        _resultCoursesFound =
            '${account.siteTitle} — $courseCount ders bulundu';
        _resultError = null;
      } else {
        _resultError = result.error;
        _resultMessage = null;
        _resultCoursesFound = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _StepDot(active: _step == 0, done: _step > 0, label: '1'),
                _StepLine(done: _step > 0),
                _StepDot(active: _step == 1, done: _step > 1, label: '2'),
                _StepLine(done: _step > 1),
                _StepDot(active: _step == 2, done: false, label: '3'),
              ],
            ),
          ),

          // Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildUniversityPage(theme),
                _buildLoginPage(theme, bottomInset),
                _buildResultPage(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====== ADIM 1: ÜNİVERSİTE ======
  Widget _buildUniversityPage(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Üniversitenizi Seçin',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Moodle hesabınızı bağlamak için üniversitenizi seçin',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              // Arama
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Üniversite ara...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              // Popüler listesi
              ..._filteredUniversities.map((uni) => _UniversityTile(
                    university: uni,
                    selected: _selectedUniversity == uni,
                    onTap: () {
                      setState(() {
                        _selectedUniversity = uni;
                        _useManualUrl = false;
                      });
                      _goToStep(1);
                    },
                  )),
              // Manuel giriş
              _UniversityTile(
                icon: Icons.public_rounded,
                title: 'Manuel URL Gir',
                subtitle: 'Listede olmayan üniversiteler için',
                selected: _useManualUrl,
                onTap: () {
                  setState(() {
                    _useManualUrl = true;
                    _selectedUniversity = null;
                  });
                  _goToStep(1);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  // ====== ADIM 2: GİRİŞ ======
  Widget _buildLoginPage(ThemeData theme, double bottomInset) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Geri butonu
            TextButton.icon(
              onPressed: () => _goToStep(0),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Geri'),
            ),
            const SizedBox(height: 8),

            if (_useManualUrl) ...[
              Text('Moodle URL\'si',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Üniversitenizin Moodle adresini girin',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'Moodle URL\'si',
                  hintText: 'örn. moodle.ogrenci.edu.tr',
                  prefixIcon: const Icon(Icons.link_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'URL gerekli';
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text('Giriş Yapın',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              if (_selectedUniversity != null)
                Row(children: [
                  const Icon(Icons.school_rounded, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_selectedUniversity!.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ]),
              const SizedBox(height: 16),
            ],

            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                prefixIcon: const Icon(Icons.person_rounded),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Kullanıcı adı gerekli' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Şifre gerekli' : null,
            ),
            const SizedBox(height: 8),
            Text(
              '🔒 Şifreniz cihazınızda saklanmaz.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _connect,
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('Bağlan',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== ADIM 3: SONUÇ ======
  Widget _buildResultPage(ThemeData theme) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('Moodle\'a bağlanıyor...',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    if (_resultError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 48, color: theme.colorScheme.error),
            ),
            const SizedBox(height: 20),
            Text('Bağlantı Başarısız',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(_resultError!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => _goToStep(1),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    // Başarı
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded,
                size: 48, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Text('Bağlantı Başarılı! 🎉',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (_resultMessage != null)
            Text(_resultMessage!,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          if (_resultCoursesFound != null)
            Text(_resultCoursesFound!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Harika!',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== YARDIMCI WİDGET'LAR =====

class _StepDot extends StatelessWidget {
  final bool active;
  final bool done;
  final String label;
  const _StepDot({required this.active, required this.done, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = done || active
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: done ? theme.colorScheme.primary : Colors.transparent,
        border: Border.all(color: color, width: 2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: done
            ? Icon(Icons.check_rounded,
                size: 14, color: theme.colorScheme.onPrimary)
            : Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant)),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool done;
  const _StepLine({required this.done});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 2,
        color: done
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}

class _UniversityTile extends StatelessWidget {
  final MoodleUniversity? university;
  final IconData icon;
  final String? title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _UniversityTile({
    this.university,
    this.icon = Icons.school_rounded,
    this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = title ?? university?.name ?? '';
    final url = subtitle ?? university?.baseUrl ?? '';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? theme.colorScheme.primary
                              : null)),
                  Text(url,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded,
                  color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
