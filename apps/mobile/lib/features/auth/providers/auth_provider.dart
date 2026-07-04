import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/user_model.dart';
import '../../../core/services/supabase_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated, error }

class AuthStateModel {
  const AuthStateModel({
    required this.status,
    this.user,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
}

final authProvider = StreamProvider<AuthStateModel>((ref) async* {
  final supabase = ref.watch(supabaseServiceProvider);
  yield const AuthStateModel(status: AuthStatus.loading);

  await for (final state in supabase.authStateChanges) {
    final session = state.session;
    if (session == null) {
      yield const AuthStateModel(status: AuthStatus.unauthenticated);
      continue;
    }
    try {
      final profile = await supabase.getCurrentUserProfile();
      yield AuthStateModel(status: AuthStatus.authenticated, user: profile);
    } catch (e) {
      yield AuthStateModel(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
});

final userProvider = FutureProvider<UserModel?>((ref) async {
  final auth = ref.watch(authProvider).valueOrNull;
  if (auth?.status != AuthStatus.authenticated) return null;
  return ref.read(supabaseServiceProvider).getCurrentUserProfile();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(supabaseServiceProvider));
});

class AuthRepository {
  AuthRepository(this._supabase);

  final SupabaseService _supabase;

  Future<void> signIn(String email, String password) =>
      _supabase.signIn(email: email, password: password);

  Future<void> signUp(String fullName, String email, String password) =>
      _supabase.signUp(email: email, password: password, fullName: fullName);

  Future<void> signOut() => _supabase.signOut();

  Future<void> resetPassword(String email) => _supabase.resetPassword(email);
}
