// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:frendly/core/services/storage/user_session_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// // provider
// final tokenServiceProvider = Provider<TokenService>((ref) {
//   return TokenService(prefs: ref.read(sharedPreferencesProvider));
// });

// class TokenService {
//   static const String _tokenKey = 'auth_token';
//   final SharedPreferences _prefs;

//   TokenService({required SharedPreferences prefs}) : _prefs = prefs;

//   // Save token
//   Future<void> saveToken(String token) async {
//     await _prefs.setString(_tokenKey, token);
//   }

//   // Get token
//   Future<String?> getToken() async {
//     return _prefs.getString(_tokenKey);
//   }

//   // Remove token (for logout)
//   Future<void> removeToken() async {
//     await _prefs.remove(_tokenKey);
//   }
// }

// EASIEST FIX - Just replace your TokenService with this

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frendly/core/services/storage/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

// provider
final tokenServiceProvider = Provider<TokenService>((ref) {
  return TokenService(prefs: ref.read(sharedPreferencesProvider));
});

class TokenService {
  static const String _tokenKey = 'auth_token';
  final SharedPreferences _prefs;

  TokenService({required SharedPreferences prefs}) : _prefs = prefs;

  // UPDATED: Save token to BOTH SharedPreferences AND Hive
  Future<void> saveToken(String token) async {
    // Save to SharedPreferences (your existing storage)
    await _prefs.setString(_tokenKey, token);

    // NEW: Also save to Hive for DioClient API calls
    try {
      final authBox = await Hive.openBox('auth_box');
      await authBox.put('token', token);
      print('✅ Token saved to both storages');
      print('Token: ${token.substring(0, 30)}...');
    } catch (e) {
      print('⚠️ Error saving token to Hive: $e');
    }
  }

  // Get token (from SharedPreferences)
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  // NEW: Get token from Hive (for verification)
  Future<String?> getTokenFromHive() async {
    try {
      final authBox = await Hive.openBox('auth_box');
      return authBox.get('token');
    } catch (e) {
      print('Error getting token from Hive: $e');
      return null;
    }
  }

  // UPDATED: Remove token from BOTH storages
  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);

    // NEW: Also remove from Hive
    try {
      final authBox = await Hive.openBox('auth_box');
      await authBox.delete('token');
      await authBox.delete('current_user');
      print('✅ Token removed from both storages');
    } catch (e) {
      print('⚠️ Error removing token from Hive: $e');
    }
  }
}
