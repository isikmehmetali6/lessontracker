import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CourseSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  CourseSliverAppBarDelegate(this.child, {this.height = 66.0});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: child,
    );
  }

  @override
  bool shouldRebuild(CourseSliverAppBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
