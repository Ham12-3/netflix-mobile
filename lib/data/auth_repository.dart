import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> currentUser();
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  });
  Future<AppUser> signIn({required String email, required String password});
  Future<void> signOut();
}

class DemoAuthRepository implements AuthRepository {
  static const _currentKey = 'demo_current_user';
  static const _usersKey = 'demo_users';

  @override
  Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_currentKey);
    if (raw == null) return null;
    return AppUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final normalized = email.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    final users = _readUsers(prefs);
    if (users.containsKey(normalized)) {
      throw AuthException('An account already exists for that email.');
    }
    if (password.length < 6) {
      throw AuthException('Use at least 6 characters for your password.');
    }

    final user = AppUser(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      email: normalized,
      displayName: displayName.trim().isEmpty ? null : displayName.trim(),
    );
    users[normalized] = {'password': password, 'user': user.toJson()};
    await prefs.setString(_usersKey, jsonEncode(users));
    await prefs.setString(_currentKey, jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final users = _readUsers(prefs);
    final record = users[email.trim().toLowerCase()];
    if (record == null || record['password'] != password) {
      throw AuthException('Email or password was not recognized.');
    }
    final user = AppUser.fromJson(record['user'] as Map<String, dynamic>);
    await prefs.setString(_currentKey, jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentKey);
  }

  Map<String, dynamic> _readUsers(SharedPreferences prefs) {
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<AppUser?> currentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fromSupabaseUser(user);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'display_name': displayName.trim()},
    );
    final user = response.user;
    if (user == null) {
      throw AuthException('Check your email to finish creating your account.');
    }
    if (response.session == null) {
      throw AuthException(
        'Account created. Check your email to confirm it, then log in.',
      );
    }
    await _client.from('profiles').upsert({
      'id': user.id,
      'display_name': displayName.trim(),
    });
    return _fromSupabaseUser(user);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw AuthException('Email or password was not recognized.');
    }
    return _fromSupabaseUser(user);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  AppUser _fromSupabaseUser(User user) {
    final name = user.userMetadata?['display_name'] as String?;
    return AppUser(id: user.id, email: user.email ?? '', displayName: name);
  }
}
