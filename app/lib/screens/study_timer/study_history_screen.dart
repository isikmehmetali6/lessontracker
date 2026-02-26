import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../repositories/study_session_repository.dart';
import '../../models/study_session.dart';
import '../../providers/course_provider.dart';

class StudyHistoryScreen extends StatefulWidget {
  const StudyHistoryScreen({super.key});

  @override
  State<StudyHistoryScreen> createState() => _StudyHistoryScreenState();
}

class _StudyHistoryScreenState extends State<StudyHistoryScreen> {
  final _sessionRepo = StudySessionRepository();
  List<StudySession> _sessions = [];
  bool _isLoading = true;
  int _selectedRange = 7; // days

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: _selectedRange));
    _sessions = await _sessionRepo.getStudySessionsBetween(start, now);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final courses = context.select((CourseProvider p) => p.courses);

    // Toplam istatistikler
    final workSessions = _sessions.where((s) => s.sessionType == 'work').toList();
    final totalMinutes = workSessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final totalHours = totalMinutes / 60;
    final avgPerDay = _selectedRange > 0 ? totalMinutes / _selectedRange : 0.0;

    // Günlük dağılım (chart data)
    final dailyData = <String, int>{};
    for (var i = _selectedRange - 1; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final key = '${day.month}/${day.day}';
      dailyData[key] = 0;
    }
    for (final s in workSessions) {
      final key = '${s.startedAt.month}/${s.startedAt.day}';
      dailyData[key] = (dailyData[key] ?? 0) + s.durationMinutes;
    }

    // Ders bazlı dağılım
    final courseMinutes = <String?, int>{};
    for (final s in workSessions) {
      courseMinutes[s.courseId] = (courseMinutes[s.courseId] ?? 0) + s.durationMinutes;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Study History',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Range selector
                  Row(
                    children: [
                      _buildRangeChip('7D', 7, isDark),
                      const SizedBox(width: 8),
                      _buildRangeChip('14D', 14, isDark),
                      const SizedBox(width: 8),
                      _buildRangeChip('30D', 30, isDark),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '${totalHours.toStringAsFixed(1)}h',
                          'Total Study',
                          Icons.timer,
                          AppColors.primary,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          '${workSessions.length}',
                          'Sessions',
                          Icons.repeat,
                          AppColors.orange,
                          isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          '${avgPerDay.toStringAsFixed(0)}m',
                          'Avg/Day',
                          Icons.trending_up,
                          AppColors.green,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Daily chart
                  _buildSectionTitle('Daily Study Time', isDark),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: dailyData.isEmpty
                        ? const Center(child: Text('No data yet'))
                        : BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: (dailyData.values.isEmpty ? 60 : dailyData.values.reduce((a, b) => a > b ? a : b).toDouble()) * 1.2,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '${rod.toY.toInt()}m',
                                      const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final keys = dailyData.keys.toList();
                                      if (value.toInt() < keys.length) {
                                        // Show every nth label to avoid crowding
                                        final step = keys.length > 10 ? 3 : (keys.length > 5 ? 2 : 1);
                                        if (value.toInt() % step != 0) return const SizedBox();
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            keys[value.toInt()],
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: const FlGridData(show: false),
                              barGroups: dailyData.entries.toList().asMap().entries.map((e) {
                                return BarChartGroupData(
                                  x: e.key,
                                  barRods: [
                                    BarChartRodData(
                                      toY: e.value.value.toDouble(),
                                      color: AppColors.primary,
                                      width: _selectedRange > 14 ? 6 : 12,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Course breakdown
                  if (courseMinutes.isNotEmpty) ...[
                    _buildSectionTitle('By Course', isDark),
                    const SizedBox(height: 12),
                    ...courseMinutes.entries.map((entry) {
                      final course = entry.key != null
                          ? courses.cast<dynamic>().firstWhere(
                                (c) => c.id == entry.key,
                                orElse: () => null,
                              )
                          : null;
                      final name = course?.name ?? 'General';
                      final color = course?.color ?? Colors.grey;
                      final mins = entry.value;
                      final pct = totalMinutes > 0 ? (mins / totalMinutes * 100) : 0.0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            Text(
                              '${mins}m',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${pct.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  // Recent sessions
                  const SizedBox(height: 24),
                  _buildSectionTitle('Recent Sessions', isDark),
                  const SizedBox(height: 12),
                  if (workSessions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.timer_off, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No study sessions yet.\nStart a Pomodoro timer!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ...workSessions.take(20).map((s) {
                    final course = s.courseId != null
                        ? courses.cast<dynamic>().firstWhere((c) => c.id == s.courseId, orElse: () => null)
                        : null;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_stories, size: 20, color: course?.color ?? Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              course?.name ?? 'General',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                          Text(
                            '${s.durationMinutes}m',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${s.startedAt.month}/${s.startedAt.day} ${s.startedAt.hour.toString().padLeft(2, '0')}:${s.startedAt.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildRangeChip(String label, int days, bool isDark) {
    final isSelected = _selectedRange == days;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedRange = days);
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      ),
    );
  }
}
