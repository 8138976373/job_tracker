import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../applications/domain/entities/job_application.dart';
import '../../../applications/presentation/providers/job_application_view_model.dart';
import '../../../applications/presentation/widgets/status_badge.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.viewModel,
    required this.email,
    required this.onAdd,
    required this.onViewApplications,
    super.key,
  });
  final JobApplicationViewModel viewModel;
  final String email;
  final VoidCallback onAdd;
  final VoidCallback onViewApplications;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, _) {
      final items = widget.viewModel.items;
      final firstName = widget.email
          .split('@')
          .first
          .split(RegExp(r'[._-]'))
          .first;
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          Text(
            _friendlyDate(DateTime.now()),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Your next move, ${_capitalize(firstName)}.',
            style: const TextStyle(
              fontSize: 28,
              letterSpacing: -1,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 22),
          _WelcomeCard(total: widget.viewModel.totalItems, onAdd: widget.onAdd),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.work_outline_rounded,
                  label: 'Applications',
                  value: '${widget.viewModel.totalItems}',
                  tint: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: Icons.forum_outlined,
                  label: 'Interviews',
                  value: '${widget.viewModel.summary?.interviews ?? 0}',
                  tint: const Color(0xFFF0EAFE),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  icon: Icons.stars_outlined,
                  label: 'Offers',
                  value: '${widget.viewModel.summary?.offers ?? 0}',
                  tint: const Color(0xFFFFF1D8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SectionTitle(
            title: 'Recent applications',
            actionLabel: 'View all',
            onAction: widget.onViewApplications,
          ),
          const SizedBox(height: 6),
          if (widget.viewModel.isLoading && items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (widget.viewModel.errorMessage != null && items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.viewModel.errorMessage!,
                style: const TextStyle(color: AppColors.danger),
              ),
            )
          else if (items.isEmpty)
            const _GettingStartedCard()
          else
            ...items.take(5).map((item) => _RecentApplication(item: item)),
          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: PrimaryButton(
                label: 'Add an application',
                onPressed: widget.onAdd,
              ),
            ),
          const SizedBox(height: 20),
        ],
      );
    },
  );
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.total, required this.onAdd});
  final int total;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.primaryDark,
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'One thoughtful step\nat a time.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.12,
                  letterSpacing: -.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: AppColors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Text(
          'Keep your roles, conversations and next steps in one calm place.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .76),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 17),
        Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.amber,
              size: 18,
            ),
            const SizedBox(width: 7),
            Text(
              '$total ${total == 1 ? 'opportunity' : 'opportunities'} in your tracker',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add role'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ],
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tint,
  });
  final IconData icon;
  final String label, value;
  final Color tint;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 33,
          height: 33,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 17, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
      ],
    ),
  );
}

class _RecentApplication extends StatelessWidget {
  const _RecentApplication({required this.item});
  final JobApplication item;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.accent,
          child: Text(
            item.company.isEmpty ? '?' : item.company[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.position,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.company} · ${item.location}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ),
        StatusBadge(status: item.status),
      ],
    ),
  );
}

class _GettingStartedCard extends StatelessWidget {
  const _GettingStartedCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      children: [
        Icon(Icons.lightbulb_outline_rounded, color: AppColors.amber),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Start with one role you are excited about. Add the portal, experience range and link so you can pick it up later.',
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
        ),
      ],
    ),
  );
}

String _capitalize(String value) =>
    value.isEmpty ? 'there' : '${value[0].toUpperCase()}${value.substring(1)}';
String _friendlyDate(DateTime date) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
}
