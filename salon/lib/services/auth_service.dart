import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Stream<UserModel?> get userStream {
    return _client.auth.onAuthStateChange.asyncMap((data) async {
      final user = data.session?.user;
      if (user == null) return null;
      
      final response = await _client
          .from('users')
          .select()
          .eq('uid', user.id)
          .maybeSingle();
          
      if (response != null) {
        return UserModel.fromMap(response);
      }
      return null;
    });
  }

  Future<UserModel?> getUserData(String uid) async {
    final response = await _client
        .from('users')
        .select()
        .eq('uid', uid)
        .maybeSingle();
    return response != null ? UserModel.fromMap(response) : null;
  }

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? address,
    String? gender,
    String role = 'customer',
  }) async {
    try {
      // 1. Create the Auth Account
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      
      final user = response.user;
      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.id,
          name: name,
          email: email,
          phone: phone,
          role: role,
          address: address,
          gender: gender,
        );
        
        // 2. Save/Update the public profile
        // Using upsert ensures that if registration is retried, it won't fail
        await _client.from('users').upsert(newUser.toMap(), onConflict: 'uid');
        
        debugPrint('User record successfully synced to Supabase. Role: $role');
      }
      return response;
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered')) {
        throw 'This email is already registered. Please login instead.';
      }
      debugPrint('Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected Registration Error: $e');
      throw 'Database connection failed. Please check your SQL setup and RLS policies.';
    }
  }

  Future<AuthResponse?> signIn(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      if (e.message.contains('Email not confirmed')) {
        throw 'Please check your email and click the confirmation link, or confirm the user in the Supabase Dashboard.';
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updateProfile(String name, String phone) async {
    final user = _client.auth.currentUser;
    if (user != null) {
      await _client.from('users').update({
        'name': name,
        'phone': phone,
      }).eq('uid', user.id);
    }
  }
}
