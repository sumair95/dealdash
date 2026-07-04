import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../shared/models/price_history_model.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/models/promotion_model.dart';

class ProductDetailState {
  const ProductDetailState({
    this.product,
    this.promotions = const [],
    this.history = const [],
    this.isOnWatchlist = false,
    this.watchlistId,
    this.isLoading = true,
    this.error,
  });

  final ProductModel? product;
  final List<PromotionModel> promotions;
  final List<PriceHistoryModel> history;
  final bool isOnWatchlist;
  final String? watchlistId;
  final bool isLoading;
  final String? error;

  ProductDetailState copyWith({
    ProductModel? product,
    List<PromotionModel>? promotions,
    List<PriceHistoryModel>? history,
    bool? isOnWatchlist,
    String? watchlistId,
    bool? isLoading,
    String? error,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      promotions: promotions ?? this.promotions,
      history: history ?? this.history,
      isOnWatchlist: isOnWatchlist ?? this.isOnWatchlist,
      watchlistId: watchlistId ?? this.watchlistId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  ProductDetailNotifier(this._supabase, this.productId) : super(const ProductDetailState()) {
    load();
  }

  final SupabaseService _supabase;
  final String productId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final detail = await _supabase.getProductDetail(productId);
      final product = detail['product'] as ProductModel;
      final promotionsRaw = detail['promotions'] as List<dynamic>;
      final historyRaw = detail['history'] as List<dynamic>;

      final promotions = promotionsRaw.map((row) {
        final map = row as Map<String, dynamic>;
        final rp = map['retailer_products'] as Map<String, dynamic>;
        final retailer = rp['retailers'] as Map<String, dynamic>;
        return PromotionModel.fromJson({
          'id': map['id'],
          'product_id': product.id,
          'product_name': product.name,
          'brand': product.brand,
          'image_url': product.imageUrl,
          'retailer_id': retailer['id'],
          'retailer_name': retailer['name'],
          'retailer_logo': retailer['logo_url'],
          'regular_price': map['regular_price'],
          'sale_price': map['sale_price'],
          'discount_pct': map['discount_pct'],
          'promotion_type': map['promotion_type'],
          'promotion_ends_at': map['promotion_ends_at'],
          'product_url': rp['product_url'],
        });
      }).toList();

      state = state.copyWith(
        product: product,
        promotions: promotions,
        history: _supabase.mapPriceHistory(historyRaw),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final productDetailProvider = StateNotifierProvider.family<
    ProductDetailNotifier, ProductDetailState, String>((ref, productId) {
  return ProductDetailNotifier(ref.read(supabaseServiceProvider), productId);
});
