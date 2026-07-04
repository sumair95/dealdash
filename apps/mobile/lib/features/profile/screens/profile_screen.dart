import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Please sign in'));
          }
          final initials = (user.fullName ?? user.email).substring(0, 1).toUpperCase();
          return ListView(
            children: [
              ListTile(
                leading: CircleAvatar(child: Text(initials)),
                title: Text(user.fullName ?? user.email),
                subtitle: Text(user.email),
                trailing: user.isPremium
                    ? const Chip(label: Text('Premium'))
                    : const Chip(label: Text('Free')),
              ),
              ListTile(
                title: const Text('Subscription Status'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile/subscription'),
              ),
              ListTile(
                title: const Text('Notification Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile/notifications'),
              ),
              ListTile(
                title: const Text('Favourite Stores'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/onboarding/stores'),
              ),
              ListTile(
                title: const Text('Favourite Categories'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/onboarding/categories'),
              ),
              ListTile(
                title: const Text('Help & FAQ'),
                onTap: () => launchUrl(Uri.parse(AppConstants.helpUrl)),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: () => launchUrl(Uri.parse(AppConstants.privacyUrl)),
              ),
              ListTile(
                title: const Text(AppStrings.logout),
                onTap: () async {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) context.go('/login');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
