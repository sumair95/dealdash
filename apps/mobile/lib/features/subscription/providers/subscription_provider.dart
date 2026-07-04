import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/stripe_service.dart';
import '../../auth/providers/auth_provider.dart';

final subscriptionProvider = FutureProvider<String>((ref) async {
  final user = await ref.watch(userProvider.future);
  return user?.subscriptionStatus ?? 'free';
});

final subscriptionControllerProvider = Provider<SubscriptionController>((ref) {
  return SubscriptionController(ref);
});

class SubscriptionController {
  SubscriptionController(this._ref);

  final Ref _ref;

  Future<bool> startCheckout() async {
    final user = await _ref.read(userProvider.future);
    if (user == null) return false;
    return _ref.read(stripeServiceProvider).createCheckoutSession(user.id);
  }
}
