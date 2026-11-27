import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/career_profile.dart';
import '../providers/profile_view_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({required this.viewModel, super.key});
  final ProfileViewModel viewModel;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields = {
    for (final key in _keys) key: TextEditingController(),
  };
  static const _keys = [
    'position',
    'company',
    'companyDetails',
    'currentCtc',
    'expectedCtc',
    'experienceYears',
    'experienceDetails',
    'currentLocation',
    'expectedLocations',
  ];
  bool _hydrated = false;
  DateTime? _experienceStartDate;

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _hydrate(CareerProfile p) {
    _fields['position']!.text = p.position;
    _fields['company']!.text = p.company;
    _fields['companyDetails']!.text = p.companyDetails;
    _fields['currentCtc']!.text = p.currentCtc;
    _fields['expectedCtc']!.text = p.expectedCtc;
    _fields['experienceYears']!.text = p.experienceYears;
    _experienceStartDate = p.experienceStartDate;
    _fields['experienceDetails']!.text = p.experienceDetails.join('\n');
    _fields['currentLocation']!.text = p.currentLocation;
    _fields['expectedLocations']!.text = p.expectedLocations.join(', ');
    _hydrated = true;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.viewModel,
    builder: (context, _) {
      if (!_hydrated && !widget.viewModel.isLoading) {
        _hydrate(widget.viewModel.profile);
      }
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          _ProfileHero(complete: _completion),
          const SizedBox(height: 22),
          if (widget.viewModel.isLoading && !_hydrated)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _SectionCard(
                    icon: Icons.badge_outlined,
                    title: 'Your next role',
                    subtitle: 'Help tailor your search to what you want.',
                    children: [
                      _input(
                        'position',
                        'Target position',
                        'e.g. Senior Product Designer',
                        Icons.work_outline_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.apartment_rounded,
                    title: 'Where you are today',
                    subtitle: 'Your current role and compensation.',
                    children: [
                      _input(
                        'company',
                        'Current company',
                        'Company name',
                        Icons.domain_rounded,
                      ),
                      _input(
                        'companyDetails',
                        'Role & company details',
                        'Title, team, work arrangement or other context',
                        Icons.notes_rounded,
                        lines: 3,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _input(
                              'currentCtc',
                              'Current CTC',
                              'e.g. ₹18 LPA',
                              Icons.payments_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _input(
                              'expectedCtc',
                              'Expected CTC',
                              'e.g. ₹24 LPA',
                              Icons.trending_up_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.timeline_rounded,
                    title: 'Experience',
                    subtitle:
                        'Capture your career journey with a little detail.',
                    children: [
                      _experienceField(),
                      _input(
                        'experienceDetails',
                        'Employment history',
                        'One role per line — title · company · dates · key focus',
                        Icons.format_list_bulleted_rounded,
                        lines: 5,
                      ),
                      const _Hint(
                        text:
                            'Example: Product Designer · Northstar · 2022–present · Led mobile redesign',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.place_outlined,
                    title: 'Location preferences',
                    subtitle:
                        'Where you live and where you are open to working.',
                    children: [
                      _input(
                        'currentLocation',
                        'Current location',
                        'City, country',
                        Icons.my_location_rounded,
                      ),
                      _input(
                        'expectedLocations',
                        'Preferred locations',
                        'Separate locations with commas',
                        Icons.map_outlined,
                        lines: 2,
                      ),
                    ],
                  ),
                  if (widget.viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        widget.viewModel.errorMessage!,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: widget.viewModel.isSaving ? null : _save,
                      icon: widget.viewModel.isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: Text(
                        widget.viewModel.isSaving
                            ? 'Saving profile…'
                            : 'Save profile',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Your career profile is saved to your account and available across devices.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
        ],
      );
    },
  );

  double get _completion {
    final filled = [
      'position',
      'company',
      'currentCtc',
      'expectedCtc',
      'experienceYears',
      'currentLocation',
      'expectedLocations',
    ].where((k) => _fields[k]!.text.trim().isNotEmpty).length;
    return filled / 7;
  }

  Widget _input(
    String key,
    String label,
    String hint,
    IconData icon, {
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: TextFormField(
      controller: _fields[key],
      onChanged: (_) => setState(() {}),
      maxLines: lines,
      textCapitalization: key.contains('location')
          ? TextCapitalization.words
          : TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: lines == 1 ? Icon(icon, size: 19) : null,
        alignLabelWithHint: lines > 1,
      ),
    ),
  );

  Widget _experienceField() => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: TextFormField(
      controller: _fields['experienceYears'],
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: 'Total experience',
        hintText: 'e.g. 6 years 4 months',
        prefixIcon: const Icon(Icons.schedule_rounded, size: 19),
        suffixIcon: IconButton(
          tooltip: 'Calculate from career start date',
          onPressed: _chooseExperienceStartDate,
          icon: const Icon(Icons.calendar_month_rounded),
        ),
        helperText: _experienceStartDate == null
            ? 'Choose your career start date to calculate automatically.'
            : 'Calculated from ${_dateLabel(_experienceStartDate!)}',
      ),
    ),
  );

  Future<void> _chooseExperienceStartDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _experienceStartDate ?? today,
      firstDate: DateTime(today.year - 60),
      lastDate: today,
      helpText: 'When did your career begin?',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _experienceStartDate = DateUtils.dateOnly(picked);
      _fields['experienceYears']!.text = _formatExperience(
        _experienceStartDate!,
        today,
      );
    });
  }

  String _formatExperience(DateTime start, DateTime end) {
    var months = (end.year - start.year) * 12 + end.month - start.month;
    if (end.day < start.day) months--;
    if (months < 0) months = 0;
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years == 0) {
      return '$remainingMonths ${remainingMonths == 1 ? 'month' : 'months'}';
    }
    if (remainingMonths == 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    }
    return '$years ${years == 1 ? 'year' : 'years'} $remainingMonths ${remainingMonths == 1 ? 'month' : 'months'}';
  }

  String _dateLabel(DateTime date) =>
      '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final f = _fields;
    final p = CareerProfile(
      position: f['position']!.text.trim(),
      company: f['company']!.text.trim(),
      companyDetails: f['companyDetails']!.text.trim(),
      currentCtc: f['currentCtc']!.text.trim(),
      expectedCtc: f['expectedCtc']!.text.trim(),
      experienceYears: f['experienceYears']!.text.trim(),
      experienceStartDate: _experienceStartDate,
      experienceDetails: f['experienceDetails']!.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      currentLocation: f['currentLocation']!.text.trim(),
      expectedLocations: f['expectedLocations']!.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );
    final ok = await widget.viewModel.save(p);
    if (ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved to your account')));
    }
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.complete});
  final double complete;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primaryDark, Color(0xFF237A57)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.amber,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'CAREER PROFILE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Make your next move\nfeel like yours.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            height: 1.12,
            fontWeight: FontWeight.w800,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Keep your career story and search preferences together.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .78),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 19),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: complete,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: .2),
                  color: AppColors.amber,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(complete * 100).round()}% complete',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });
  final IconData icon;
  final String title, subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF38453E)
            : AppColors.border,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ...children,
      ],
    ),
  );
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 0, bottom: 5),
    child: Text(
      text,
      style: const TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4),
    ),
  );
}
