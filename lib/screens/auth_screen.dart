import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../state/providers.dart';
import '../theme/app_theme.dart';

enum AuthMode { login, signup }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.mode});

  final AuthMode mode;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  late final AuthController _auth;

  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _auth = ref.read(authControllerProvider);
    _auth.addListener(_authChanged);
  }

  @override
  void dispose() {
    _auth.removeListener(_authChanged);
    _email.dispose();
    _password.dispose();
    _displayName.dispose();
    super.dispose();
  }

  void _authChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isSignup = widget.mode == AuthMode.signup;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.flame,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.play_arrow_rounded),
                ),
                const SizedBox(width: 12),
                const Text(
                  AppConfig.appName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 52),
            Text(
              isSignup ? 'Create your account' : 'Welcome back',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              AppConfig.hasSupabaseConfig
                  ? 'Sign in to stream the curated legal catalog.'
                  : 'Demo mode is active. Use a fresh local account for this emulator build.',
              style: const TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (isSignup) ...[
                    TextFormField(
                      controller: _displayName,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Display name',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (!text.contains('@')) return 'Enter a valid email.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _hidePassword = !_hidePassword);
                        },
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if ((value ?? '').length < 6) {
                        return 'Use at least 6 characters.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            if (_auth.error != null) ...[
              const SizedBox(height: 14),
              Text(_auth.error!, style: const TextStyle(color: AppTheme.gold)),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _auth.isLoading ? null : _submit,
              icon: _auth.isLoading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(isSignup ? Icons.person_add_alt : Icons.login),
              label: Text(isSignup ? 'Sign up' : 'Log in'),
            ),
            if (!AppConfig.hasSupabaseConfig) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _auth.isLoading ? null : _useDemoAccount,
                icon: const Icon(Icons.flash_on_outlined),
                label: const Text('Use demo account'),
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(isSignup ? '/login' : '/signup'),
              child: Text(
                isSignup
                    ? 'Already have an account? Log in'
                    : 'New here? Create an account',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authControllerProvider);
    final ok = widget.mode == AuthMode.signup
        ? await auth.signUp(_email.text, _password.text, _displayName.text)
        : await auth.signIn(_email.text, _password.text);
    if (ok && mounted) {
      context.go('/home');
    }
  }

  Future<void> _useDemoAccount() async {
    const email = 'demo@luma.local';
    const password = 'password123';
    final auth = ref.read(authControllerProvider);
    var ok = await auth.signIn(email, password);
    if (!ok) {
      ok = await auth.signUp(email, password, 'Demo Viewer');
    }
    if (ok && mounted) {
      context.go('/home');
    }
  }
}
