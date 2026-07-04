import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../auth/providers/auth_provider.dart';

class UserPreferencesState {
  const UserPreferencesState({
    this.notifyPriceDrops = true,
    this.notifyLowestEver = true,
    this.notifyEndingSoon = true,
    this.notifyWeeklyDigest = true,
    this.notifyAiRecommendations = true,
    this.maxNotificationsPerDay = 10,
    this.isLoading = true,
  });

  final bool notifyPriceDrops;
  final bool notifyLowestEver;
  final bool notifyEndingSoon;
  final bool notifyWeeklyDigest;
  final bool notifyAiRecommendations;
  final int maxNotificationsPerDay;
  final bool isLoading;

  UserPreferencesState copyWith({
    bool? notifyPriceDrops,
    bool? notifyLowestEver,
    bool? notifyEndingSoon,
    bool? notifyWeeklyDigest,
    bool? notifyAiRecommendations,
    int? maxNotificationsPerDay,
    bool? isLoading,
  }) {
    return UserPreferencesState(
      notifyPriceDrops: notifyPriceDrops ?? this.notifyPriceDrops,
      notifyLowestEver: notifyLowestEver ?? this.notifyLowestEver,
      notifyEndingSoon: notifyEndingSoon ?? this.notifyEndingSoon,
      notifyWeeklyDigest: notifyWeeklyDigest ?? this.notifyWeeklyDigest,
      notifyAiRecommendations:
          notifyAiRecommendations ?? this.notifyAiRecommendations,
      maxNotificationsPerDay:
          maxNotificationsPerDay ?? this.maxNotificationsPerDay,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfilePreferencesNotifier extends StateNotifier<UserPreferencesState> {
  ProfilePreferencesNotifier(this._supabase, this._userId)
      : super(const UserPreferencesState()) {
    load();
  }

  final SupabaseService _supabase;
  final String _userId;

  Future<void> load() async {
    final data = await _supabase.client
        .from('user_preferences')
        .select()
        .eq('user_id', _userId)
        .maybeSingle();
    if (data == null) {
      state = state.copyWith(isLoading: false);
      return;
    }
    state = UserPreferencesState(
      notifyPriceDrops: data['notify_price_drops'] as bool? ?? true,
      notifyLowestEver: data['notify_lowest_ever'] as bool? ?? true,
      notifyEndingSoon: data['notify_ending_soon'] as bool? ?? true,
      notifyWeeklyDigest: data['notify_weekly_digest'] as bool? ?? true,
      notifyAiRecommendations:
          data['notify_ai_recommendations'] as bool? ?? true,
      maxNotificationsPerDay: data['max_notifications_per_day'] as int? ?? 10,
      isLoading: false,
    );
  }

  Future<void> update(Map<String, dynamic> patch) async {
    await _supabase.updateUserPreferences(_userId, patch);
    state = state.copyWith(
      notifyPriceDrops: patch['notify_price_drops'] as bool? ?? state.notifyPriceDrops,
      notifyLowestEver:
          patch['notify_lowest_ever'] as bool? ?? state.notifyLowestEver,
      notifyEndingSoon:
          patch['notify_ending_soon'] as bool? ?? state.notifyEndingSoon,
      notifyWeeklyDigest:
          patch['notify_weekly_digest'] as bool? ?? state.notifyWeeklyDigest,
      notifyAiRecommendations: patch['notify_ai_recommendations'] as bool? ??
          state.notifyAiRecommendations,
      maxNotificationsPerDay: patch['max_notifications_per_day'] as int? ??
          state.maxNotificationsPerDay,
    );
  }
}

final userPreferencesProvider =
    StateNotifierProvider<ProfilePreferencesNotifier, UserPreferencesState>((ref) {
  final user = ref.watch(userProvider).valueOrNull;
  return ProfilePreferencesNotifier(
    ref.read(supabaseServiceProvider),
    user?.id ?? '',
  );
});

final profileProvider = userProvider;
