import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/di/app_dependencies.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/applications/presentation/pages/job_application_form_page.dart';
import '../features/applications/presentation/pages/job_applications_page.dart';
import '../features/applications/presentation/providers/job_application_view_model.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/providers/auth_view_model.dart';
import '../features/auth/domain/entities/auth_session.dart';
import '../features/dashboard/presentation/pages/home_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/providers/profile_view_model.dart';

class StarterApp extends StatefulWidget {
  const StarterApp({required this.dependencies, super.key});
  final AppDependencies dependencies;

  @override
  State<StarterApp> createState() => _StarterAppState();
}

class _StarterAppState extends State<StarterApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() => setState(() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: AppConstants.appName,
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    themeMode: _themeMode,
    home: _AuthGate(
      dependencies: widget.dependencies,
      onToggleTheme: _toggleTheme,
    ),
  );
}

class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.dependencies, required this.onToggleTheme});
  final AppDependencies dependencies;
  final VoidCallback onToggleTheme;
  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final AuthViewModel _auth = widget.dependencies.locator
      .get<AuthViewModel>();

  @override
  void initState() {
    super.initState();
    _auth.restoreSession();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _auth,
    builder: (context, _) {
      return switch (_auth.status) {
        AuthStatus.restoring => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        AuthStatus.signedIn => _AppShell(
          dependencies: widget.dependencies,
          session: _auth.session!,
          onToggleTheme: widget.onToggleTheme,
        ),
        _ => LoginPage(viewModel: _auth),
      };
    },
  );
}

class _AppShell extends StatefulWidget {
  const _AppShell({
    required this.dependencies,
    required this.session,
    required this.onToggleTheme,
  });
  final AppDependencies dependencies;
  final AuthSession session;
  final VoidCallback onToggleTheme;
  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = widget.dependencies.locator.get<AuthViewModel>();
    final jobs = widget.dependencies.locator.get<JobApplicationViewModel>();
    final profile = widget.dependencies.locator.get<ProfileViewModel>();
    final email = widget.session.email;
    final pages = [
      HomePage(
        viewModel: jobs,
        email: email,
        onAdd: () => _openForm(context, jobs),
        onViewApplications: () => setState(() => _selectedIndex = 1),
      ),
      JobApplicationsPage(viewModel: jobs),
      ProfilePage(viewModel: profile),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Jobtrail',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.5),
            ),
            actions: [
              if (wide)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Center(
                    child: Text(
                      email,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              IconButton(
                onPressed: widget.onToggleTheme,
                tooltip: Theme.of(context).brightness == Brightness.dark
                    ? 'Switch to light theme'
                    : 'Switch to dark theme',
                icon: Icon(
                  Theme.of(context).brightness == Brightness.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
              ),
              IconButton(
                onPressed: () async {
                  jobs.reset();
                  await auth.signOut();
                },
                tooltip: 'Sign out',
                icon: const Icon(Icons.logout_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Row(
            children: [
              if (wide)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: Text('Overview'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.work_outline_rounded),
                      selectedIcon: Icon(Icons.work_rounded),
                      label: Text('Applications'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: Text('Profile'),
                    ),
                  ],
                ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: pages,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: null,
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) =>
                      setState(() => _selectedIndex = index),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.grid_view_outlined),
                      selectedIcon: Icon(Icons.grid_view_rounded),
                      label: 'Overview',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.work_outline_rounded),
                      selectedIcon: Icon(Icons.work_rounded),
                      label: 'Applications',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.person_outline_rounded),
                      selectedIcon: Icon(Icons.person_rounded),
                      label: 'Profile',
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _openForm(
    BuildContext context,
    JobApplicationViewModel jobs,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => JobApplicationFormPage(viewModel: jobs),
      ),
    );
  }
}
