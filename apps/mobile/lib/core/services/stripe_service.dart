import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:url_launcher/url_launcher.dart';

import 'supabase_service.dart';

final stripeServiceProvider = Provider<StripeService>((ref) {
  return StripeService(ref.read(supabaseServiceProvider));
});

class StripeService {
  StripeService(this._supabase);

  final SupabaseService _supabase;

  Future<void> init() async {
    final publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
    if (publishableKey == null || publishableKey.isEmpty) return;
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  Future<bool> createCheckoutSession(String userId) async {
    final checkoutUrl = await _supabase.createStripeCheckout(
      userId: userId,
      successUrl: 'dealdash://subscription/success',
      cancelUrl: 'dealdash://subscription/cancel',
    );
    if (checkoutUrl == null) return false;
    final uri = Uri.parse(checkoutUrl);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
