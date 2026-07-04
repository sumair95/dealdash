import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/product_model.dart';
import '../../auth/providers/auth_provider.dart';

class SearchFilters {
  const SearchFilters({
    this.retailerId,
    this.categoryId,
    this.minDiscount,
    this.maxPrice,
    this.sort = SearchSort.bestDiscount,
  });

  final String? retailerId;
  final String? categoryId;
  final double? minDiscount;
  final double? maxPrice;
  final SearchSort sort;

  SearchFilters copyWith({
    String? retailerId,
    bool clearRetailerId = false,
    String? categoryId,
    bool clearCategoryId = false,
    double? minDiscount,
    double? maxPrice,
    SearchSort? sort,
  }) {
    return SearchFilters(
      retailerId: clearRetailerId ? null : (retailerId ?? this.retailerId),
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      minDiscount: minDiscount ?? this.minDiscount,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
    );
  }
}

enum SearchSort { bestDiscount, lowestPrice, newest }

class SearchState {
  const SearchState({
    this.query = '',
    this.results = const [],
    this.filters = const SearchFilters(),
    this.isLoading = false,
    this.recentSearches = const [],
    this.showPaywall = false,
    this.error,
  });

  final String query;
  final List<ProductModel> results;
  final SearchFilters filters;
  final bool isLoading;
  final List<String> recentSearches;
  final bool showPaywall;
  final String? error;

  SearchState copyWith({
    String? query,
    List<ProductModel>? results,
    SearchFilters? filters,
    bool? isLoading,
    List<String>? recentSearches,
    bool? showPaywall,
    String? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      filters: filters ?? this.filters,
      isLoading: isLoading ?? this.isLoading,
      recentSearches: recentSearches ?? this.recentSearches,
      showPaywall: showPaywall ?? this.showPaywall,
      error: error,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier(this._supabase, this._ref) : super(const SearchState()) {
    _loadRecent();
  }

  final SupabaseService _supabase;
  final Ref _ref;
  Timer? _debounce;

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final recent = prefs.getStringList('recent_searches') ?? [];
    state = state.copyWith(recentSearches: recent);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query, error: null);
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () => search(),
    );
  }

  void setFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
    search();
  }

  Future<void> search() async {
    final query = state.query.trim();
    if (query.isEmpty) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    final user = _ref.read(userProvider).valueOrNull;
    if (user != null && !user.isPremium) {
      final gate = await _supabase.checkFreemiumGate(
        userId: user.id,
        query: query,
      );
      if (gate['allowed'] != true) {
        state = state.copyWith(showPaywall: true, isLoading: false);
        return;
      }
    }

    state = state.copyWith(isLoading: true, showPaywall: false);
    try {
      final results = await _supabase.searchProducts(
        query: query,
        categoryId: state.filters.categoryId,
        retailerId: state.filters.retailerId,
        minDiscount: state.filters.minDiscount,
        maxPrice: state.filters.maxPrice,
      );
      final prefs = await SharedPreferences.getInstance();
      final recent = [query, ...state.recentSearches.where((s) => s != query)].take(8).toList();
      await prefs.setStringList('recent_searches', recent);
      state = state.copyWith(results: results, recentSearches: recent, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.read(supabaseServiceProvider), ref);
});
