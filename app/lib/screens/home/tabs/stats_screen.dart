import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/grade.dart';
import '../../../../providers/course_provider.dart';
import '../../course_detail/course_detail_screen.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, List<Grade>> _allGrades = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<CourseProvider>();
    final grades = await provider.loadAllGrades();
    if (mounted) {
      setState(() {
        _allGrades = grades;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final courseProvider = context.read<CourseProvider>();
    final originalCourses = courseProvider.courses;
    final courses = courseProvider.uniqueCourses;

    // --- Calculation Logic ---
    
    // Map to store avg score per course for chart and list
    final Map<String, double> courseAverages = {};

    for (final course in courses) {
      // Bütün aynı isimli derslerin notlarını topla
      final matchingCourseIds = originalCourses.where((c) => c.name == course.name).map((c) => c.id).toList();
      List<Grade> allMatchingGrades = [];
      for (final id in matchingCourseIds) {
        allMatchingGrades.addAll(_allGrades[id] ?? []);
      }
      
      final avg = courseProvider.calculateWeightedAverage(allMatchingGrades);
      courseAverages[course.id] = avg;
    }

    // 2. Absence Risks
    final atRiskCourses = courses.where((c) {
      if (c.absenceLimit == 0) return false;
      return (c.currentAbsences / c.absenceLimit) >= 0.7; // 70% limit warning
    }).toList();

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Text(
              l10n.statistics,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Absence Risk Warning
        if (atRiskCourses.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.atRisk,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...atRiskCourses.map((c) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: AppColors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "${c.name} (${c.currentAbsences}/${c.absenceLimit})",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),

        // Chart Section
        if (courses.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.coursePerformance,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => isDark ? AppColors.surfaceDark : Colors.white,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${courses[group.x.toInt()].name}\n',
                                TextStyle(
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: rod.toY.round().toString(),
                                    style: TextStyle(
                                      color: courses[group.x.toInt()].color,
                                    ),
                                  ),
                                ],
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
                                if (value.toInt() >= courses.length) return const SizedBox();
                                final name = courses[value.toInt()].name;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    name.length >= 3 ? name.substring(0, 3).toUpperCase() : name.toUpperCase(),
                                    style: TextStyle(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: courses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final course = entry.value;
                          final avg = courseAverages[course.id] ?? 0;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: avg,
                                color: course.color,
                                width: 16,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 100,
                                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Detailed Course Breakdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.courseBreakdown,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final course = courses[index];
                  final avg = courseAverages[course.id] ?? 0;
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseDetailScreen(course: course),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                           BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: course.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.school, color: course.color),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${l10n.averageShort}: ${avg.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.absences(course.currentAbsences, course.absenceLimit),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: course.isAbsenceLimitExceeded 
                                      ? AppColors.red 
                                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: 80,
                                height: 6,
                                child: LinearProgressIndicator(
                                  value: course.absenceLimit > 0 ? (course.currentAbsences / course.absenceLimit) : 0,
                                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    course.isAbsenceLimitExceeded ? AppColors.red : AppColors.primary
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: courses.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }



}
