import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/retailer_model.dart';

class OnboardingState {
  const OnboardingState({
    this.retailers = const [],
    this.categories = const [],
    this.selectedRetailerIds = const {},
    this.selectedCategoryIds = const {},
    this.isLoading = false,
  });

  final List<RetailerModel> retailers;
  final List<CategoryModel> categories;
  final Set<String> selectedRetailerIds;
  final Set<String> selectedCategoryIds;
  final bool isLoading;

  OnboardingState copyWith({
    List<RetailerModel>? retailers,
    List<CategoryModel>? categories,
    Set<String>? selectedRetailerIds,
    Set<String>? selectedCategoryIds,
    bool? isLoading,
  }) {
    return OnboardingState(
      retailers: retailers ?? this.retailers,
      categories: categories ?? this.categories,
      selectedRetailerIds: selectedRetailerIds ?? this.selectedRetailerIds,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier(this._supabase) : super(const OnboardingState());

  final SupabaseService _supabase;

  Future<void> loadRetailers() async {
    state = state.copyWith(isLoading: true);
    final retailers = await _supabase.getRetailers();
    state = state.copyWith(retailers: retailers, isLoading: false);
  }

  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true);
    final categories = await _supabase.getCategories();
    state = state.copyWith(categories: categories, isLoading: false);
  }

  void toggleRetailer(String id) {
    final next = Set<String>.from(state.selectedRetailerIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedRetailerIds: next);
  }

  void toggleCategory(String id) {
    final next = Set<String>.from(state.selectedCategoryIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedCategoryIds: next);
  }

  Future<void> saveRetailers(String userId) async {
    if (state.selectedRetailerIds.isEmpty) return;
    await _supabase.updateUserPreferences(userId, {
      'favourite_retailer_ids': state.selectedRetailerIds.toList(),
    });
  }

  Future<void> saveCategories(String userId) async {
    if (state.selectedCategoryIds.isEmpty) return;
    await _supabase.updateUserPreferences(userId, {
      'favourite_category_ids': state.selectedCategoryIds.toList(),
    });
  }

  Future<void> saveAllPreferences(String userId) async {
    final updates = <String, dynamic>{};
    if (state.selectedRetailerIds.isNotEmpty) {
      updates['favourite_retailer_ids'] = state.selectedRetailerIds.toList();
    }
    if (state.selectedCategoryIds.isNotEmpty) {
      updates['favourite_category_ids'] = state.selectedCategoryIds.toList();
    }
    if (updates.isEmpty) return;
    await _supabase.updateUserPreferences(userId, updates);
  }

  bool get hasStoreSelection => state.selectedRetailerIds.isNotEmpty;

  bool get hasCategorySelection => state.selectedCategoryIds.isNotEmpty;

  bool get isOnboardingComplete => hasStoreSelection && hasCategorySelection;
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref.read(supabaseServiceProvider));
});
