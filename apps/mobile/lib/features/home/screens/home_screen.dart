import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/ad_service.dart';
import '../../../shared/widgets/ad_banner_widget.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../providers/home_provider.dart';
import '../widgets/deal_card.dart';
import '../widgets/deal_card_horizontal.dart';
import '../widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final index = location.contains('/search')
        ? 1
        : location.contains('/watchlist')
            ? 2
            : location.contains('/profile')
                ? 3
                : 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: child,
      bottomNavigationBar: AppBottomNav(currentIndex: index),
    );
  }
}

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dealsAsync = ref.watch(homeDealsProvider);
    final endingSoonAsync = ref.watch(endingSoonDealsProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final banner = ref.read(adServiceProvider).loadBannerAd(isPremium: isPremium);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.todaysBestDeals,
        showLogo: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Badge(label: Text('0'), child: Icon(Icons.notifications_none)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeDealsProvider);
          await ref.read(homeDealsProvider.future);
        },
        child: dealsAsync.when(
          loading: () => ListView(
            children: const [
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ShimmerBox(height: 48),
              ),
              SizedBox(height: 16),
              ShimmerBox(height: 220, width: 220),
            ],
          ),
          error: (e, _) => ErrorWidgetView(
            message: e.toString(),
            onRetry: () => ref.invalidate(homeDealsProvider),
          ),
          data: (deals) {
            if (deals.isEmpty) {
              return const EmptyStateWidget(
                title: 'No deals yet',
                subtitle: 'Check back soon for fresh Australian savings.',
                icon: Icons.local_offer_outlined,
              );
            }
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () => context.push('/home/search'),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: AppColors.textSecondary),
                          SizedBox(width: 12),
                          Text(AppStrings.searchHint),
                        ],
                      ),
                    ),
                  ),
                ),
                const SectionHeader(title: AppStrings.todaysBestDeals),
                SizedBox(
                  height: 320,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: deals.length,
                    itemBuilder: (_, index) => DealCard(deal: deals[index]),
                  ),
                ),
                const SectionHeader(title: AppStrings.trendingDiscounts),
                ...deals.take(6).map((deal) => DealCardHorizontal(deal: deal)),
                const SectionHeader(title: AppStrings.endingSoon),
                endingSoonAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: ShimmerBox(height: 120),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (endingSoon) => Column(
                    children: endingSoon
                        .take(4)
                        .map((deal) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: DealCard(deal: deal, compact: true),
                            ))
                        .toList(),
                  ),
                ),
                if (!isPremium)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: AdBannerWidget(bannerAd: banner)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
