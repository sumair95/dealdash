import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';

class DealDashApp extends ConsumerWidget {
  const DealDashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
        scaffoldBackgroundColor: AppColors.backgroundGrey,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
