import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lesson_tracker/l10n/app_localizations.dart';
import '../../providers/course_provider.dart';
import '../../models/course.dart';
import '../../models/grade.dart';
import '../../core/theme/app_colors.dart';

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({super.key});

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  Map<String, List<Grade>> _courseGrades = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final provider = context.read<CourseProvider>();
    final grades = <String, List<Grade>>{};
    for (final course in provider.courses) {
      final courseGrades = await provider.loadCourseGrades(course.id);
      grades[course.id] = courseGrades;
    }
    if (mounted) {
      setState(() {
        _courseGrades = grades;
        _isLoading = false;
      });
    }
  }

  double _calculateAverage(List<Grade> grades) {
    if (grades.isEmpty) return 0;
    double totalWeighted = 0;
    double totalWeight = 0;
    for (final g in grades) {
      totalWeighted += (g.score / g.maxScore) * 100 * g.weight;
      totalWeight += g.weight;
    }
    return totalWeight > 0 ? totalWeighted / totalWeight : 0;
  }

  String _letterGrade(double avg) {
    if (avg >= 90) return 'A';
    if (avg >= 85) return 'A-';
    if (avg >= 80) return 'B+';
    if (avg >= 75) return 'B';
    if (avg >= 70) return 'B-';
    if (avg >= 65) return 'C+';
    if (avg >= 60) return 'C';
    if (avg >= 55) return 'C-';
    if (avg >= 50) return 'D';
    return 'F';
  }

  double _gradePoint(String letter) {
    switch (letter) {
      case 'A': return 4.0;
      case 'A-': return 3.7;
      case 'B+': return 3.3;
      case 'B': return 3.0;
      case 'B-': return 2.7;
      case 'C+': return 2.3;
      case 'C': return 2.0;
      case 'C-': return 1.7;
      case 'D': return 1.0;
      default: return 0.0;
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;
    final courses = context.watch<CourseProvider>().courses;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.transcriptTitle),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(isDark, courses),
    );
  }

  Widget _buildContent(bool isDark, List<Course> courses) {
    double totalGradePoints = 0;
    int totalCredits = 0;

    final rows = <_TranscriptRow>[];
    for (final course in courses) {
      final grades = _courseGrades[course.id] ?? [];
      final avg = _calculateAverage(grades);
      final letter = grades.isEmpty ? '-' : _letterGrade(avg);
      final gp = grades.isEmpty ? 0.0 : _gradePoint(letter);

      if (grades.isNotEmpty) {
        totalGradePoints += gp * course.credits;
        totalCredits += course.credits;
      }

      rows.add(_TranscriptRow(
        courseName: course.name,
        credits: course.credits,
        average: avg,
        letterGrade: letter,
        gradePoint: gp,
        status: course.status,
      ));
    }

    final gpa = totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildTableHeader(isDark),
                    const Divider(height: 1),
                    ...rows.map((r) => _buildTableRow(isDark, r)),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildSummaryBar(isDark, gpa, totalCredits),
      ],
    );
  }

  Widget _buildTableHeader(bool isDark) {
    final loc = AppLocalizations.of(context)!;
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(loc.courseHeader, style: style)),
          SizedBox(width: 40, child: Text(loc.crHeader, style: style, textAlign: TextAlign.center)),
          SizedBox(width: 50, child: Text(loc.avgHeader, style: style, textAlign: TextAlign.center)),
          SizedBox(width: 40, child: Text(loc.gradeHeader, style: style, textAlign: TextAlign.center)),
          SizedBox(width: 40, child: Text(loc.gpHeader, style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildTableRow(bool isDark, _TranscriptRow row) {
    final loc = AppLocalizations.of(context)!;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.courseName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  row.status == 'active' ? loc.inProgress : row.status.toUpperCase(),
                  style: TextStyle(fontSize: 10, color: subColor),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '${row.credits}',
              style: TextStyle(fontSize: 14, color: textColor),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              row.letterGrade == '-' ? '-' : '${row.average.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 14, color: textColor),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              row.letterGrade,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _gradeColor(row.letterGrade),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              row.letterGrade == '-' ? '-' : row.gradePoint.toStringAsFixed(1),
              style: TextStyle(fontSize: 14, color: textColor),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Color _gradeColor(String letter) {
    if (letter.startsWith('A')) return AppColors.emerald;
    if (letter.startsWith('B')) return Colors.blue;
    if (letter.startsWith('C')) return AppColors.orange;
    if (letter.startsWith('D')) return AppColors.red;
    if (letter == 'F') return AppColors.red;
    return Colors.grey;
  }

  Widget _buildSummaryBar(bool isDark, double gpa, int totalCredits) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.overallGpa,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    gpa.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.totalCreditsLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  '$totalCredits',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TranscriptRow {
  final String courseName;
  final int credits;
  final double average;
  final String letterGrade;
  final double gradePoint;
  final String status;

  _TranscriptRow({
    required this.courseName,
    required this.credits,
    required this.average,
    required this.letterGrade,
    required this.gradePoint,
    required this.status,
  });
}
