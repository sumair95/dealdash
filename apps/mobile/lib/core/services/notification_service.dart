import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'supabase_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.read(supabaseServiceProvider));
});

class NotificationService {
  NotificationService(this._supabase);

  final SupabaseService _supabase;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    final userId = _supabase.currentAuthUser?.id;
    if (token != null && userId != null) {
      await _supabase.updateFcmToken(userId, token);
    }
    _messaging.onTokenRefresh.listen((newToken) async {
      final uid = _supabase.currentAuthUser?.id;
      if (uid != null) {
        await _supabase.updateFcmToken(uid, newToken);
      }
    });
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        debugPrint('Foreground notification: ${message.notification?.title}');
      }
    });
  }
}
