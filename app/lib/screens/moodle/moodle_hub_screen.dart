import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/moodle_provider.dart';
import 'tabs/moodle_assignments_tab.dart';
import 'tabs/moodle_announcements_tab.dart';
import 'tabs/moodle_calendar_tab.dart';
import 'tabs/moodle_courses_tab.dart';
import 'tabs/moodle_grades_tab.dart';
import 'tabs/moodle_messages_tab.dart';
import 'widgets/add_moodle_account_sheet.dart';
import 'moodle_accounts_screen.dart';
import '../../core/theme/app_colors.dart';

/// Moodle Hub — 5 sekmeli ana Moodle ekranı.
/// HomeScreen'in IndexedStack'ine 5. eleman olarak eklenir.
class MoodleHubScreen extends StatefulWidget {
  const MoodleHubScreen({super.key});

  @override
  State<MoodleHubScreen> createState() => _MoodleHubScreenState();
}

class _MoodleHubScreenState extends State<MoodleHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    ('Dersler', Icons.menu_book_rounded),
    ('Ödevler', Icons.assignment_rounded),
    ('Notlar', Icons.grade_rounded),
    ('Duyurular', Icons.notifications_rounded),
    ('Takvim', Icons.calendar_today_rounded),
    ('Mesajlar', Icons.mail_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<MoodleProvider>();

    // Hiç hesap yoksa onboarding
    if (!provider.isLoading && !provider.hasAccounts) {
      return _buildEmptyState(context, theme, provider);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 110, // Sadece başlık ve TabBar sığacak kadar
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Moodle',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (provider.accounts.isNotEmpty)
                  Text(
                    '${provider.accounts.length} hesap · '
                    '${provider.allCourses.length} ders · '
                    '${provider.unreadCount} okunmamış',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            actions: [
              // Sync butonu
              if (provider.isAnySyncing)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))),
                )
              else
                IconButton(
                  icon: const Icon(Icons.sync_rounded),
                  tooltip: 'Tümünü Yenile',
                  onPressed: () => provider.syncAll(),
                ),
              // Hesapları yönet
              IconButton(
                icon: const Icon(Icons.manage_accounts_rounded),
                tooltip: 'Hesapları Yönet',
                onPressed: () => _openAccountsScreen(context),
              ),
              // Hesap ekle
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.person_add_rounded),
                  tooltip: 'Hesap Ekle',
                  onPressed: () => _showAddAccount(context),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _tabs.map((t) {
                final (label, icon) = t;
                // Duyurular sekmesinde badge
                Widget tab = Tab(
                  icon: Icon(icon, size: 18),
                  text: label,
                  iconMargin: const EdgeInsets.only(bottom: 2),
                );
                if (label == 'Duyurular' && provider.unreadCount > 0) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 18),
                        const SizedBox(width: 4),
                        Text(label),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${provider.unreadCount}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (label == 'Mesajlar' && provider.unreadMessageCount > 0) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 18),
                        const SizedBox(width: 4),
                        Text(label),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${provider.unreadMessageCount}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return tab;
              }).toList(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            MoodleCoursesTab(),
            MoodleAssignmentsTab(),
            MoodleGradesTab(),
            MoodleAnnouncementsTab(),
            MoodleCalendarTab(),
            MoodleMessagesTab(),
          ],
        ),
      ),
      // Hesap yönetimi FAB
      floatingActionButton: FloatingActionButton.small(
        heroTag: 'moodle_add_account',
        onPressed: () => _showAddAccount(context),
        tooltip: 'Moodle Hesabı Ekle',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  // Hiç hesap yok — boş durum onboarding
  Widget _buildEmptyState(
      BuildContext context, ThemeData theme, MoodleProvider provider) {
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Moodle',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_rounded),
            tooltip: 'Hesapları Yönet',
            onPressed: () => _openAccountsScreen(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Moodle\'ı Bağla',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Üniversitenizin Moodle sistemiyle bağlantı kurarak derslerinizi, '
                'ödevlerinizi, notlarınızı ve duyurularınızı tek yerden takip edin.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Özellik kartları
              _FeatureRow(
                icon: Icons.assignment_rounded,
                title: 'Ödevler & Tarihler',
                subtitle: 'Son teslim tarihlerini kaçırma',
              ),
              _FeatureRow(
                icon: Icons.grade_rounded,
                title: 'Notlar',
                subtitle: 'Tüm sınav sonuçlarını tek yerde gör',
              ),
              _FeatureRow(
                icon: Icons.notifications_rounded,
                title: 'Duyurular',
                subtitle: 'Hocalarının paylaşımlarını anında gör',
              ),
              _FeatureRow(
                icon: Icons.people_rounded,
                title: 'Çoklu Hesap',
                subtitle: 'Birden fazla üniversite desteği',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => _showAddAccount(context),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: const Text(
                    'Moodle Hesabı Ekle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '🔒 Şifreniz asla cihazınızda saklanmaz',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAccountsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MoodleAccountsScreen(),
      ),
    );
  }

  Future<void> _showAddAccount(BuildContext context) async {
    final added = await AddMoodleAccountSheet.show(context);
    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Moodle hesabı başarıyla bağlandı!'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureRow(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text(subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
