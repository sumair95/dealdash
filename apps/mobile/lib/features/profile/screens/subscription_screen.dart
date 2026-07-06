import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (user) {
          if (user == null) return const Center(child: Text('Please sign in'));
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current plan: ${user.subscriptionStatus}'),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Premium features'),
                        SizedBox(height: 8),
                        Text('Unlimited searches'),
                        Text('Unlimited price alerts'),
                        Text('Full price history'),
                        Text('No advertisements'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Price: ${AppConstants.premiumPriceLabel}'),
                const Spacer(),
                if (!user.isPremium)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/subscription/paywall'),
                      child: const Text('Upgrade to Premium'),
                    ),
                  )
                else
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Cancel Subscription'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
