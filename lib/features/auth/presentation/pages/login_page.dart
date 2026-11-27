import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/primary_button.dart';
import '../providers/auth_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.viewModel, super.key});
  final AuthViewModel viewModel;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailFieldKey = GlobalKey<FormFieldState<String>>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _registering = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_registering && _password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The passwords do not match.')),
      );
      return;
    }
    if (_registering) {
      await widget.viewModel.register(
        email: _email.text.trim(),
        password: _password.text,
      );
    } else {
      await widget.viewModel.signIn(
        email: _email.text.trim(),
        password: _password.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 820;
          return Row(
            children: [
              if (wide) const Expanded(child: _WelcomePanel()),
              Expanded(
                flex: wide ? 1 : 2,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390),
                      child: AnimatedBuilder(
                        animation: widget.viewModel,
                        builder: (context, _) => Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const BrandMark(),
                              const SizedBox(height: 54),
                              Text(
                                _registering
                                    ? 'Make space for\nyour next move.'
                                    : 'Welcome back.',
                                style: const TextStyle(
                                  fontSize: 31,
                                  height: 1.12,
                                  letterSpacing: -1.2,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _registering
                                    ? 'Create a private account to keep your search yours.'
                                    : 'Sign in and keep your search moving.',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 30),
                              const _Label('Email address'),
                              const SizedBox(height: 8),
                              TextFormField(
                                key: _emailFieldKey,
                                controller: _email,
                                onChanged: (_) => widget.viewModel.clearError(),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) {
                                  if (_emailFieldKey.currentState?.validate() ??
                                      false) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_passwordFocusNode);
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: 'you@email.com',
                                  prefixIcon: Icon(
                                    Icons.mail_outline_rounded,
                                    size: 20,
                                  ),
                                ),
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  final valid = RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  ).hasMatch(email);
                                  return valid
                                      ? null
                                      : 'Enter a valid email address.';
                                },
                              ),
                              const SizedBox(height: 18),
                              const _Label('Password'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _password,
                                focusNode: _passwordFocusNode,
                                onChanged: (_) => widget.viewModel.clearError(),
                                obscureText: _obscure,
                                textInputAction: _registering
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                onFieldSubmitted: _registering
                                    ? (_) => FocusScope.of(
                                        context,
                                      ).requestFocus(_confirmPasswordFocusNode)
                                    : (_) => _submit(),
                                decoration: InputDecoration(
                                  hintText: 'At least 6 characters',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.length < 6
                                    ? 'Use at least 6 characters.'
                                    : null,
                              ),
                              if (_registering) ...[
                                const SizedBox(height: 18),
                                const _Label('Confirm password'),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _confirmPassword,
                                  focusNode: _confirmPasswordFocusNode,
                                  onChanged: (_) => widget.viewModel.clearError(),
                                  obscureText: _obscure,
                                  onFieldSubmitted: (_) => _submit(),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your password again',
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      size: 20,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Confirm your password.';
                                    }
                                    if (value != _password.text) {
                                      return 'Passwords do not match.';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              if (widget.viewModel.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text(
                                    widget.viewModel.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 22),
                              PrimaryButton(
                                label: _registering
                                    ? 'Create account'
                                    : 'Sign in',
                                isLoading:
                                    widget.viewModel.status ==
                                    AuthStatus.loading,
                                onPressed: _submit,
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: TextButton(
                                  onPressed: () => setState(() {
                                    _registering = !_registering;
                                    widget.viewModel.clearError();
                                  }),
                                  child: Text(
                                    _registering
                                        ? 'Already have an account? Sign in'
                                        : 'New here? Create an account',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Center(
                                child: Text(
                                  'Your application details are private to your account.',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 13,
      color: AppColors.ink,
    ),
  );
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFFEAF1E9),
    child: Stack(
      children: [
        Positioned(
          right: -100,
          top: -60,
          child: Container(
            width: 400,
            height: 400,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFDCE9DC),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandMark(),
              const Spacer(),
              Container(
                width: 72,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'A clearer path\nfrom application\nto offer.',
                style: TextStyle(
                  fontSize: 46,
                  height: 1.06,
                  letterSpacing: -2,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Give every role a place. Keep the details,\nfollow-ups and progress close.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.muted,
                ),
              ),
              const Spacer(),
              const Text(
                'YOUR JOB SEARCH, IN GOOD ORDER',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
