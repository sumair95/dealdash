import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
    Future.delayed(const Duration(milliseconds: AppConstants.splashMinDurationMs), _routeNext);
  }

  void _routeNext() {
    if (!mounted) return;
    final auth = ref.read(authProvider).valueOrNull;
    if (auth?.status == AuthStatus.authenticated) {
      context.go('/home');
    } else if (auth?.status == AuthStatus.unauthenticated) {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFEAF2F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(Icons.local_offer, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 20),
                  Text(AppConstants.appName, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(AppStrings.splashTagline),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
