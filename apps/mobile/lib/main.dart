import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/services/ad_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/stripe_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl != null &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey != null &&
      supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey, // ignore: deprecated_member_use
    );
  }

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase platform files are configured during native setup.
  }

  final sentryDsn = dotenv.env['SENTRY_DSN'];
  if (sentryDsn != null && sentryDsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.2;
      },
      appRunner: () => _runApp(),
    );
    return;
  }

  await _runApp();
}

Future<void> _runApp() async {
  final container = ProviderContainer();
  for (final init in [
    () => container.read(analyticsServiceProvider).init(),
    () => container.read(adServiceProvider).init(),
    () => container.read(stripeServiceProvider).init(),
    () => container.read(notificationServiceProvider).init(),
  ]) {
    try {
      await init();
    } catch (error, stackTrace) {
      debugPrint('Optional service init failed: $error\n$stackTrace');
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const DealDashApp(),
    ),
  );
}
