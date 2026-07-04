import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../shared/models/watchlist_model.dart';
import '../../auth/providers/auth_provider.dart';

final watchlistProvider = FutureProvider<List<WatchlistModel>>((ref) async {
  final user = await ref.watch(userProvider.future);
  if (user == null) return [];
  return ref.read(supabaseServiceProvider).getWatchlist(user.id);
});

final watchlistControllerProvider = Provider<WatchlistController>((ref) {
  return WatchlistController(ref);
});

class WatchlistController {
  WatchlistController(this._ref);

  final Ref _ref;

  Future<void> add(String productId, {double? targetPrice}) async {
    final user = await _ref.read(userProvider.future);
    if (user == null) return;
    await _ref.read(supabaseServiceProvider).addToWatchlist(
          userId: user.id,
          productId: productId,
          targetPrice: targetPrice,
        );
    _ref.invalidate(watchlistProvider);
  }

  Future<void> remove(String watchlistId) async {
    await _ref.read(supabaseServiceProvider).removeFromWatchlist(watchlistId);
    _ref.invalidate(watchlistProvider);
  }
}
