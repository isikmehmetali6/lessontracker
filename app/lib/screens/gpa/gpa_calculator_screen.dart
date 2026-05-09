import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/course.dart';
import '../../models/grade.dart';
import '../../providers/course_provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';

class GPACalculatorScreen extends StatefulWidget {
  const GPACalculatorScreen({super.key});

  @override
  State<GPACalculatorScreen> createState() => _GPACalculatorScreenState();
}

class _GPACalculatorScreenState extends State<GPACalculatorScreen> {
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

  double _scoreToGPA(double score) {
    if (score >= 90) return 4.0;
    if (score >= 85) return 3.7;
    if (score >= 80) return 3.3;
    if (score >= 75) return 3.0;
    if (score >= 70) return 2.7;
    if (score >= 65) return 2.3;
    if (score >= 60) return 2.0;
    if (score >= 55) return 1.7;
    if (score >= 50) return 1.0;
    return 0.0;
  }

  String _scoreToLetterGrade(double score) {
    if (score >= 90) return 'A';
    if (score >= 85) return 'A-';
    if (score >= 80) return 'B+';
    if (score >= 75) return 'B';
    if (score >= 70) return 'B-';
    if (score >= 65) return 'C+';
    if (score >= 60) return 'C';
    if (score >= 55) return 'D+';
    if (score >= 50) return 'D';
    return 'F';
  }

  Color _gpaToColor(double gpa) {
    if (gpa >= 3.5) return AppColors.green;
    if (gpa >= 3.0) return AppColors.primary;
    if (gpa >= 2.0) return AppColors.orange;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final courses = context.select((CourseProvider p) => p.uniqueCourses);
    final courseProvider = context.read<CourseProvider>();
    final originalCourses = courseProvider.courses;

    // Calculate overall GPA
    double totalWeightedGPA = 0;
    int totalCredits = 0;
    final List<_CourseGPAInfo> courseInfos = [];

    for (final course in courses) {
      // Bütün aynı isimli derslerin notlarını topla
      final matchingCourseIds = originalCourses.where((c) => c.name == course.name).map((c) => c.id).toList();
      List<Grade> allMatchingGrades = [];
      for (final id in matchingCourseIds) {
        allMatchingGrades.addAll(_allGrades[id] ?? []);
      }

      final avg = courseProvider.calculateWeightedAverage(allMatchingGrades);
      final gpa = _scoreToGPA(avg);
      final letter = _scoreToLetterGrade(avg);
      // Determine max credits across the matching courses
      final credits = originalCourses.where((c) => c.name == course.name).map((c) => c.credits).fold(0, (max, current) => current > max ? current : max);

      courseInfos.add(_CourseGPAInfo(
        course: course.copyWith(credits: credits),
        average: avg,
        gpa: gpa,
        letterGrade: letter,
        gradeCount: allMatchingGrades.length,
      ));

      if (allMatchingGrades.isNotEmpty) {
        totalWeightedGPA += gpa * credits;
        totalCredits += credits;
      }
    }

    final overallGPA = totalCredits > 0 ? totalWeightedGPA / totalCredits : 0.0;
    final overallColor = _gpaToColor(overallGPA);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.gpaCalculator,
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            overallColor,
                            overallColor.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: overallColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            loc.overallGPA,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            overallGPA.toStringAsFixed(2),
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '/ 4.00',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMiniStat(loc.totalCredits, '$totalCredits', Colors.white),
                              const SizedBox(width: 24),
                              _buildMiniStat(loc.totalCourses, '${courses.length}', Colors.white),
                              const SizedBox(width: 24),
                              _buildMiniStat(loc.letterGrade, _scoreToLetterGrade(totalCredits > 0 ? (overallGPA / 4.0 * 100) : 0), Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.gpaScale,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildScaleItem('A', '90-100', '4.0', AppColors.green, isDark),
                              _buildScaleItem('B', '75-89', '3.0', AppColors.primary, isDark),
                              _buildScaleItem('C', '60-74', '2.0', AppColors.orange, isDark),
                              _buildScaleItem('F', '0-49', '0.0', AppColors.red, isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      loc.courseBreakdown.toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList.builder(
                    itemCount: courseInfos.length,
                    itemBuilder: (context, index) {
                      return _buildCourseCard(courseInfos[index], isDark, loc);
                    },
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 60)),
              ],
            ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildScaleItem(String grade, String range, String gpa, Color color, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(
              child: Text(grade, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13)),
            ),
          ),
          const SizedBox(height: 4),
          Text(range, style: TextStyle(fontSize: 10, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          Text(gpa, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
        ],
      ),
    );
  }

  Widget _buildCourseCard(_CourseGPAInfo info, bool isDark, AppLocalizations loc) {
    final gpaColor = _gpaToColor(info.gpa);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gpaColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: info.course.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.school, color: info.course.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.course.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info.gradeCount > 0
                      ? '${loc.average}: ${info.average.toStringAsFixed(1)} • ${info.course.credits} ${loc.credits}'
                      : loc.noGradesYet,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: gpaColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  info.letterGrade,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: gpaColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info.gpa.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseGPAInfo {
  final Course course;
  final double average;
  final double gpa;
  final String letterGrade;
  final int gradeCount;

  _CourseGPAInfo({
    required this.course,
    required this.average,
    required this.gpa,
    required this.letterGrade,
    required this.gradeCount,
  });
}
