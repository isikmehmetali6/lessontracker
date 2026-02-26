import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../add_course/add_course_screen.dart';

class HomeFAB extends StatelessWidget {
  const HomeFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const AddCourseScreen()),
          );
        },
        backgroundColor: AppColors.textPrimaryLight,
        elevation: 8,
        child: const Icon(Icons.add, size: 32, color: AppColors.primary),
      ),
    );
  }
}
