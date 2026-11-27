import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/application_draft.dart';
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/job_application_repository.dart';
import '../providers/job_application_view_model.dart';

class JobApplicationFormPage extends StatefulWidget {
  const JobApplicationFormPage({
    required this.viewModel,
    this.application,
    super.key,
  });
  final JobApplicationViewModel viewModel;
  final JobApplication? application;

  @override
  State<JobApplicationFormPage> createState() => _JobApplicationFormPageState();
}

class _JobApplicationFormPageState extends State<JobApplicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _position;
  late final TextEditingController _company;
  late final TextEditingController _location;
  late final TextEditingController _experience;
  late final TextEditingController _portal;
  late final TextEditingController _link;
  late final TextEditingController _notes;
  DateTime? _dateApplied;
  late ApplicationStatus _status;

  @override
  void initState() {
    super.initState();
    final item = widget.application;
    _position = TextEditingController(text: item?.position ?? '');
    _company = TextEditingController(text: item?.company ?? '');
    _location = TextEditingController(text: item?.location ?? '');
    _experience = TextEditingController(text: item?.experience ?? '');
    _portal = TextEditingController(text: item?.portal ?? '');
    _link = TextEditingController(text: item?.jobLink ?? '');
    _notes = TextEditingController(text: item?.notes ?? '');
    _dateApplied = item?.dateApplied;
    _status = item?.status ?? ApplicationStatus.saved;
  }

  @override
  void dispose() {
    _position.dispose();
    _company.dispose();
    _location.dispose();
    _experience.dispose();
    _portal.dispose();
    _link.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final value = await showDatePicker(
      context: context,
      initialDate: _dateApplied ?? today,
      firstDate: DateTime(today.year - 10),
      lastDate: DateTime(today.year + 3),
    );
    if (value != null) setState(() => _dateApplied = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final link = _link.text.trim();
    if (link.isNotEmpty) {
      final uri = Uri.tryParse(link);
      if (uri == null ||
          !uri.hasAuthority ||
          !{'http', 'https'}.contains(uri.scheme)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Use a full link that starts with https:// or http://.',
            ),
          ),
        );
        return;
      }
    }
    final draft = ApplicationDraft(
      dateApplied: _dateApplied,
      position: _position.text.trim(),
      company: _company.text.trim(),
      location: _location.text.trim(),
      experience: _experience.text.trim(),
      portal: _portal.text.trim(),
      jobLink: link.isEmpty ? null : link,
      status: _status,
      notes: _notes.text.trim(),
    );
    if (await widget.viewModel.save(draft, current: widget.application) &&
        mounted)
      Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.application == null ? 'Add application' : 'Edit application',
      ),
    ),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          children: [
            const Text(
              'Keep every opportunity in one place.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 22),
            _label('Position'),
            TextFormField(
              controller: _position,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Flutter Developer'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            _label('Company'),
            TextFormField(
              controller: _company,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Company name'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            _label('Location'),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(
                hintText: 'Remote, Cochin, India',
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            _label('Experience'),
            TextFormField(
              controller: _experience,
              decoration: const InputDecoration(hintText: '4+ Years'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            _label('Job portal'),
            TextFormField(
              controller: _portal,
              decoration: const InputDecoration(
                hintText: 'Hirist, LinkedIn, company site',
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            _label('Date applied'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                _dateApplied == null
                    ? 'Choose a date (optional)'
                    : _formatDate(_dateApplied!),
              ),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if (_dateApplied != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() => _dateApplied = null),
                  child: const Text('Clear date'),
                ),
              ),
            const SizedBox(height: 16),
            _label('Status'),
            const SizedBox(height: 8),
            DropdownButtonFormField<ApplicationStatus>(
              value: _status,
              decoration: const InputDecoration(),
              items: ApplicationStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 16),
            _label('Job link'),
            TextFormField(
              controller: _link,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(hintText: 'https://...'),
              maxLength: 2048,
            ),
            const SizedBox(height: 12),
            _label('Notes'),
            TextFormField(
              controller: _notes,
              minLines: 3,
              maxLines: 5,
              maxLength: 2000,
              decoration: const InputDecoration(
                hintText: 'Recruiter, next steps, or anything to remember',
              ),
            ),
            if (widget.viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  widget.viewModel.errorMessage!,
                  style: const TextStyle(color: AppColors.danger),
                ),
              ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: widget.viewModel,
              builder: (context, _) => PrimaryButton(
                label: widget.application == null
                    ? 'Save application'
                    : 'Save changes',
                isLoading: widget.viewModel.isSaving,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;
  Widget _label(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      value,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: AppColors.ink,
      ),
    ),
  );
  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
