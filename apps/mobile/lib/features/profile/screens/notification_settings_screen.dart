import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(userPreferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: prefs.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                SwitchListTile(
                  title: const Text('Price Drop Alerts'),
                  value: prefs.notifyPriceDrops,
                  onChanged: (value) => ref
                      .read(userPreferencesProvider.notifier)
                      .update({'notify_price_drops': value}),
                ),
                SwitchListTile(
                  title: const Text('Lowest Price Ever'),
                  value: prefs.notifyLowestEver,
                  onChanged: (value) => ref
                      .read(userPreferencesProvider.notifier)
                      .update({'notify_lowest_ever': value}),
                ),
                SwitchListTile(
                  title: const Text('Ending Soon Alerts'),
                  value: prefs.notifyEndingSoon,
                  onChanged: (value) => ref
                      .read(userPreferencesProvider.notifier)
                      .update({'notify_ending_soon': value}),
                ),
                SwitchListTile(
                  title: const Text('Weekly Digest'),
                  value: prefs.notifyWeeklyDigest,
                  onChanged: (value) => ref
                      .read(userPreferencesProvider.notifier)
                      .update({'notify_weekly_digest': value}),
                ),
                SwitchListTile(
                  title: const Text('AI Recommendations'),
                  value: prefs.notifyAiRecommendations,
                  onChanged: (value) => ref
                      .read(userPreferencesProvider.notifier)
                      .update({'notify_ai_recommendations': value}),
                ),
                ListTile(
                  title: const Text('Max notifications per day'),
                  subtitle: Slider(
                    min: 1,
                    max: 20,
                    divisions: 19,
                    value: prefs.maxNotificationsPerDay.toDouble(),
                    label: prefs.maxNotificationsPerDay.toString(),
                    onChanged: (value) => ref
                        .read(userPreferencesProvider.notifier)
                        .update({'max_notifications_per_day': value.round()}),
                  ),
                ),
              ],
            ),
    );
  }
}
