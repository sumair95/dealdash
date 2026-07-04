import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../shared/models/promotion_model.dart';
import '../../auth/providers/auth_provider.dart';

final homeDealsProvider = FutureProvider<List<PromotionModel>>((ref) async {
  ref.keepAlive();
  return ref.read(supabaseServiceProvider).getTodayDeals();
});

final homeProvider = homeDealsProvider;

final trendingDealsProvider = FutureProvider<List<PromotionModel>>((ref) async {
  final deals = await ref.watch(homeDealsProvider.future);
  return deals.take(10).toList();
});

final endingSoonDealsProvider = FutureProvider<List<PromotionModel>>((ref) async {
  final deals = await ref.watch(homeDealsProvider.future);
  final now = DateTime.now();
  return deals
      .where((d) => d.promotionEndsAt != null && d.promotionEndsAt!.isAfter(now))
      .toList()
    ..sort((a, b) => a.promotionEndsAt!.compareTo(b.promotionEndsAt!));
});

final isPremiumProvider = Provider<bool>((ref) {
  final user = ref.watch(userProvider).valueOrNull;
  return user?.isPremium ?? false;
});
