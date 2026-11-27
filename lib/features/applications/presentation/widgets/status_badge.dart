import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/job_application.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});
  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      ApplicationStatus.saved => (const Color(0xFFF0F2F1), AppColors.muted),
      ApplicationStatus.applied => (
        const Color(0xFFE7F0FF),
        const Color(0xFF315D9A),
      ),
      ApplicationStatus.assessment => (
        const Color(0xFFFFF1D8),
        const Color(0xFF916316),
      ),
      ApplicationStatus.interview => (
        const Color(0xFFF0EAFE),
        const Color(0xFF6642A1),
      ),
      ApplicationStatus.offer => (
        const Color(0xFFE5F2E9),
        AppColors.primaryDark,
      ),
      ApplicationStatus.rejected => (const Color(0xFFFDEAE7), AppColors.danger),
      ApplicationStatus.withdrawn => (const Color(0xFFF0F2F1), AppColors.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
