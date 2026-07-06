import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../../onboarding/providers/onboarding_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  var _agreed = false;
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_agreed) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).signUp(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
      final userId = ref.read(supabaseServiceProvider).currentAuthUser?.id;
      if (userId != null) {
        await ref.read(onboardingProvider.notifier).saveAllPreferences(userId);
      }
      if (!mounted) return;
      if (ref.read(onboardingProvider.notifier).isOnboardingComplete) {
        context.go('/home');
      } else {
        context.go('/onboarding/stores');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = Validators.passwordStrength(_passwordController.text);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.registerTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: Validators.fullName,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (_) => setState(() {}),
                validator: Validators.password,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: strength / 4),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                decoration: const InputDecoration(labelText: 'Confirm password'),
                obscureText: true,
                validator: (value) =>
                    Validators.confirmPassword(value, _passwordController.text),
              ),
              CheckboxListTile(
                value: _agreed,
                onChanged: (value) => setState(() => _agreed = value ?? false),
                title: Wrap(
                  children: [
                    const Text('I agree to the '),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(AppConstants.termsUrl)),
                      child: const Text('Terms', style: TextStyle(decoration: TextDecoration.underline)),
                    ),
                    const Text(' and '),
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(AppConstants.privacyUrl)),
                      child: const Text('Privacy Policy', style: TextStyle(decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
