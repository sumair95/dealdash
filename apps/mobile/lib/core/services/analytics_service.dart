import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  Mixpanel? _mixpanel;

  Future<void> init() async {
    final token = dotenv.env['MIXPANEL_TOKEN'];
    if (token == null || token.isEmpty) return;
    _mixpanel = await Mixpanel.init(token, trackAutomaticEvents: true);
  }

  Future<void> track(String event, [Map<String, dynamic>? props]) async {
    if (_mixpanel == null) {
      if (kDebugMode) {
        debugPrint('Analytics: $event ${props ?? {}}');
      }
      return;
    }
    await _mixpanel!.track(event, properties: props);
  }

  Future<void> trackSearch(String query, int resultCount) =>
      track('search', {'query': query, 'result_count': resultCount});

  Future<void> trackProductView(String productId, String productName) =>
      track('product_view', {'product_id': productId, 'product_name': productName});

  Future<void> trackAddToWatchlist(String productId) =>
      track('add_to_watchlist', {'product_id': productId});

  Future<void> trackNotificationTap(String notificationId) =>
      track('notification_tap', {'notification_id': notificationId});

  Future<void> trackSubscribeIntent() => track('subscribe_intent');

  Future<void> trackSubscribeSuccess() => track('subscribe_success');

  Future<void> trackAdImpression(String adUnit) =>
      track('ad_impression', {'ad_unit': adUnit});
}
