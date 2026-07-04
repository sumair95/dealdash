import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/category_model.dart';
import '../../shared/models/price_history_model.dart';
import '../../shared/models/product_model.dart';
import '../../shared/models/promotion_model.dart';
import '../../shared/models/retailer_model.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/watchlist_model.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  User? get currentAuthUser => client.auth.currentUser;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    return client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => client.auth.signOut();

  Future<void> resetPassword(String email) {
    return client.auth.resetPasswordForEmail(email);
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final userId = currentAuthUser?.id;
    if (userId == null) return null;
    final data = await client.from('users').select().eq('id', userId).maybeSingle();
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  Future<List<PromotionModel>> getTodayDeals({int limit = 50}) async {
    final data = await client.rpc('get_today_deals', params: {'p_limit': limit});
    return (data as List<dynamic>)
        .map((e) => PromotionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> searchProducts({
    required String query,
    String? categoryId,
    String? retailerId,
    double? minDiscount,
    double? maxPrice,
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await client.rpc('search_products', params: {
      'p_query': query,
      'p_category_id': categoryId,
      'p_retailer_id': retailerId,
      'p_min_discount': minDiscount,
      'p_max_price': maxPrice,
      'p_limit': limit,
      'p_offset': offset,
    });
    return (data as List<dynamic>)
        .map((e) => ProductModel.fromJson({
              'id': e['product_id'],
              'name': e['product_name'],
              'brand': e['brand'],
              'image_url': e['image_url'],
            }))
        .toList();
  }

  Future<Map<String, dynamic>> getProductDetail(String productId) async {
    final product = await client.from('products').select().eq('id', productId).single();
    final promotions = await client
        .from('price_history')
        .select(
          'id, regular_price, sale_price, discount_pct, promotion_type, promotion_ends_at, scraped_at, retailer_products!inner(product_url, retailers(id, name, logo_url))',
        )
        .eq('retailer_products.product_id', productId)
        .eq('is_active', true);

    final history = await client
        .from('price_history')
        .select(
          'id, retailer_product_id, regular_price, sale_price, discount_pct, promotion_type, scraped_at, retailer_products!inner(retailers(name))',
        )
        .eq('retailer_products.product_id', productId)
        .order('scraped_at', ascending: false)
        .limit(200);

    return {
      'product': ProductModel.fromJson(product),
      'promotions': promotions,
      'history': history,
    };
  }

  Future<List<WatchlistModel>> getWatchlist(String userId) async {
    final data = await client
        .from('watchlist')
        .select('*, products(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List<dynamic>)
        .map((e) => WatchlistModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToWatchlist({
    required String userId,
    required String productId,
    double? targetPrice,
  }) async {
    await client.from('watchlist').insert({
      'user_id': userId,
      'product_id': productId,
      'target_price': targetPrice,
    });
  }

  Future<void> removeFromWatchlist(String watchlistId) async {
    await client.from('watchlist').delete().eq('id', watchlistId);
  }

  Future<List<RetailerModel>> getRetailers() async {
    final data = await client.from('retailers').select().eq('is_active', true).order('name');
    return (data as List<dynamic>)
        .map((e) => RetailerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final data = await client.from('categories').select().eq('is_active', true).order('display_order');
    return (data as List<dynamic>)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateUserPreferences(String userId, Map<String, dynamic> prefs) async {
    await client.from('user_preferences').update(prefs).eq('user_id', userId);
  }

  Future<Map<String, dynamic>> checkFreemiumGate({
    required String userId,
    String? query,
    int? resultCount,
  }) async {
    final response = await client.functions.invoke(
      'check-freemium-gate',
      body: {
        'user_id': userId,
        'query': query,
        'result_count': resultCount,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<String?> createStripeCheckout({
    required String userId,
    required String successUrl,
    required String cancelUrl,
  }) async {
    final response = await client.functions.invoke(
      'stripe-create-checkout',
      body: {
        'user_id': userId,
        'success_url': successUrl,
        'cancel_url': cancelUrl,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['checkout_url'] as String?;
  }

  Future<void> updateFcmToken(String userId, String token) async {
    await client.from('users').update({
      'fcm_token': token,
      'fcm_token_updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  List<PriceHistoryModel> mapPriceHistory(List<dynamic> rows) {
    return rows.map((row) {
      final map = row as Map<String, dynamic>;
      final retailer = map['retailer_products']?['retailers'];
      return PriceHistoryModel.fromJson({
        ...map,
        'retailer_name': retailer?['name'],
      });
    }).toList();
  }
}
