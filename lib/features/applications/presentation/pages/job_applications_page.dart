import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_title.dart';
import '../../domain/entities/job_application.dart';
import '../providers/job_application_view_model.dart';
import '../widgets/status_badge.dart';
import 'job_application_form_page.dart';

class JobApplicationsPage extends StatefulWidget {
  const JobApplicationsPage({required this.viewModel, super.key});
  final JobApplicationViewModel viewModel;

  @override
  State<JobApplicationsPage> createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _edit(JobApplication? item) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => JobApplicationFormPage(
          viewModel: widget.viewModel,
          application: item,
        ),
      ),
    );
  }

  Future<void> _delete(JobApplication item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete application?'),
        content: Text(
          'Remove ${item.position} at ${item.company}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final deleted = await widget.viewModel.delete(item.id);
      if (mounted && !deleted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.viewModel.errorMessage ??
                  'Could not delete this application.',
            ),
          ),
        );
    }
  }

  Future<void> _openLink(String? value) async {
    if (value == null || value.isEmpty) return;
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the job link.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, _) {
      final viewModel = widget.viewModel;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Applications',
                  style: TextStyle(
                    fontSize: 29,
                    letterSpacing: -1,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _edit(null),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add role'),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${viewModel.totalItems} opportunities you are tracking',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: viewModel.setSearch,
            decoration: const InputDecoration(
              hintText: 'Search company, role, location or portal',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: viewModel.statusFilter == null,
                  onTap: () => viewModel.setStatusFilter(null),
                ),
                ...ApplicationStatus.values.map(
                  (status) => _FilterChip(
                    label: status.label,
                    selected: viewModel.statusFilter == status,
                    onTap: () => viewModel.setStatusFilter(status),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          SectionTitle(
            title: 'Your pipeline',
            actionLabel: viewModel.isLoading
                ? 'Loading…'
                : '${viewModel.totalItems} total',
          ),
          const SizedBox(height: 7),
          Expanded(
            child: viewModel.isLoading && viewModel.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : viewModel.errorMessage != null && viewModel.items.isEmpty
                ? _ErrorState(
                    message: viewModel.errorMessage!,
                    onRetry: () => viewModel.load(),
                  )
                : viewModel.items.isEmpty
                ? const _EmptyState()
                : LayoutBuilder(
                    builder: (context, constraints) => RefreshIndicator(
                      onRefresh: () => viewModel.load(),
                      child: constraints.maxWidth >= 1050
                          ? _desktopTable(viewModel)
                          : _mobileList(viewModel),
                    ),
                  ),
          ),
        ],
      );
    },
  );

  Widget _desktopTable(JobApplicationViewModel viewModel) => ListView(
    padding: const EdgeInsets.only(bottom: 20),
    children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            AppColors.accent.withValues(alpha: .55),
          ),
          columns: const [
            DataColumn(label: Text('DATE APPLIED')),
            DataColumn(label: Text('POSITION / COMPANY')),
            DataColumn(label: Text('LOCATION')),
            DataColumn(label: Text('EXPERIENCE')),
            DataColumn(label: Text('PORTAL')),
            DataColumn(label: Text('JOB LINK')),
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('NOTES')),
            DataColumn(label: Text('ACTIONS')),
          ],
          rows: viewModel.items
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(Text(_date(item.dateApplied))),
                    DataCell(
                      SizedBox(
                        width: 210,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.position,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              item.company,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(Text(item.location)),
                    DataCell(Text(item.experience)),
                    DataCell(Text(item.portal)),
                    DataCell(
                      item.jobLink == null
                          ? const Text('—')
                          : TextButton.icon(
                              onPressed: () => _openLink(item.jobLink),
                              icon: const Icon(
                                Icons.open_in_new_rounded,
                                size: 15,
                              ),
                              label: const Text('Open'),
                            ),
                    ),
                    DataCell(StatusBadge(status: item.status)),
                    DataCell(
                      SizedBox(
                        width: 180,
                        child: Text(
                          item.notes.isEmpty ? '—' : item.notes,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.jobLink != null)
                            IconButton(
                              onPressed: () => _openLink(item.jobLink),
                              tooltip: 'Open job link',
                              icon: const Icon(
                                Icons.open_in_new_rounded,
                                size: 18,
                              ),
                            ),
                          IconButton(
                            onPressed: () => _edit(item),
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit_outlined, size: 18),
                          ),
                          IconButton(
                            onPressed: () => _delete(item),
                            tooltip: 'Delete',
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
      if (viewModel.hasMore)
        Center(
          child: TextButton.icon(
            onPressed: viewModel.isLoading ? null : viewModel.loadMore,
            icon: const Icon(Icons.expand_more_rounded),
            label: const Text('Load more applications'),
          ),
        ),
    ],
  );

  Widget _mobileList(JobApplicationViewModel viewModel) => ListView.separated(
    padding: const EdgeInsets.only(bottom: 20),
    itemCount: viewModel.items.length + (viewModel.hasMore ? 1 : 0),
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      if (index == viewModel.items.length)
        return Center(
          child: TextButton.icon(
            onPressed: viewModel.isLoading ? null : viewModel.loadMore,
            icon: const Icon(Icons.expand_more_rounded),
            label: const Text('Load more'),
          ),
        );
      final item = viewModel.items[index];
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.position,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.company,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: item.status),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _Meta(
                  icon: Icons.calendar_today_outlined,
                  value: _date(item.dateApplied),
                ),
                _Meta(icon: Icons.location_on_outlined, value: item.location),
                _Meta(icon: Icons.work_outline_rounded, value: item.experience),
                _Meta(icon: Icons.language_rounded, value: item.portal),
              ],
            ),
            if (item.notes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  item.notes,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            const Divider(height: 22),
            Row(
              children: [
                if (item.jobLink != null)
                  TextButton.icon(
                    onPressed: () => _openLink(item.jobLink),
                    icon: const Icon(Icons.open_in_new_rounded, size: 17),
                    label: const Text('Job post'),
                  ),
                const Spacer(),
                IconButton(
                  onPressed: () => _edit(item),
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: () => _delete(item),
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  String _date(DateTime? value) => value == null
      ? '—'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: selected ? Colors.white : AppColors.muted,
      ),
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.value});
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: AppColors.muted),
      const SizedBox(width: 5),
      Text(value, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.work_outline_rounded,
                  color: colors.onPrimaryContainer,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your next opportunity starts here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Add a role to keep the details and follow-ups together.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.danger),
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
        ),
      ],
    ),
  );
}
