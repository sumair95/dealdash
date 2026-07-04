import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/onboarding/screens/category_selection_screen.dart';
import '../../features/onboarding/screens/store_selection_screen.dart';
import '../../features/product/screens/product_detail_screen.dart';
import '../../features/profile/screens/notification_settings_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/subscription_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/subscription/screens/paywall_screen.dart';
import '../../features/watchlist/screens/watchlist_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final status = authState.valueOrNull?.status;
      final location = state.matchedLocation;
      final isAuthRoute = location.startsWith('/login') ||
          location.startsWith('/register') ||
          location.startsWith('/forgot-password') ||
          location.startsWith('/onboarding') ||
          location == '/splash';

      if (status == AuthStatus.loading) {
        return location == '/splash' ? null : '/splash';
      }
      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/login';
      }
      if (status == AuthStatus.authenticated &&
          (location == '/login' || location == '/register' || location == '/splash')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(
        path: '/onboarding/stores',
        builder: (_, __) => const StoreSelectionScreen(),
      ),
      GoRoute(
        path: '/onboarding/categories',
        builder: (_, __) => const CategorySelectionScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeDashboard()),
          GoRoute(path: '/home/search', builder: (_, __) => const SearchScreen()),
          GoRoute(path: '/home/watchlist', builder: (_, __) => const WatchlistScreen()),
          GoRoute(path: '/home/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/subscription/paywall',
        builder: (_, __) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/profile/notifications',
        builder: (_, __) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/subscription',
        builder: (_, __) => const SubscriptionScreen(),
      ),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
