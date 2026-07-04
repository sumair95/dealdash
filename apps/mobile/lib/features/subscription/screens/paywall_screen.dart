import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../providers/subscription_provider.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.paywallTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text('Unlimited searches'),
                const Text('Unlimited price alerts'),
                const Text('Full 12-month price history'),
                const Text('Priority AI alerts'),
                const Text('No advertisements'),
                const SizedBox(height: 16),
                Text(
                  AppConstants.premiumPriceLabel,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(subscriptionControllerProvider).startCheckout();
                  },
                  child: const Text(AppStrings.subscribeNow),
                ),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(AppStrings.maybeLater),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
