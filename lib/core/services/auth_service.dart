import 'dart:developer' as developer;
import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:aad_oauth/model/failure.dart';
import 'package:aad_oauth/model/token.dart';
import 'package:flutter/material.dart';
import 'package:elysia/main.dart' show navigatorKey;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late AadOAuth _oauth;
  bool _isInitialized = false;
  String? _currentUserId;
  Map<String, dynamic>? _userInfo;

  bool get isInitialized => _isInitialized;
  String? get currentUserId => _currentUserId;
  Map<String, dynamic>? get userInfo => _userInfo;
  bool get isLoggedIn => _currentUserId != null;

  Future<bool> initialize() async {
    try {
      developer.log('🔧 Initializing AadOAuth...', name: 'AuthService');

      final config = Config(
        tenant: "common",
        clientId: "2653a923-5d3a-47c3-bd01-49217fb38c8f",
        scope: "openid profile offline_access User.Read",
        redirectUri: "msauth.com.tricon.elysia://auth",
        navigatorKey: navigatorKey, // ✅ use the same global key
        loader: const Center(child: CircularProgressIndicator()),
      );

      _oauth = AadOAuth(config);
      _isInitialized = true;

      developer.log('✅ AadOAuth initialized', name: 'AuthService');
      return true;
    } catch (e, st) {
      developer.log('❌ AadOAuth init failed: $e', name: 'AuthService');
      developer.log('StackTrace: $st', name: 'AuthService');
      _isInitialized = false;
      return false;
    }
  }

  Future<Map<String, dynamic>?> signIn() async {
    try {
      developer.log('🚀 Starting Microsoft sign-in...', name: 'AuthService');
      final result = await _oauth.login();

      return result.fold((Failure f) {
        developer.log('❌ Sign-in failed: ${f.toString()}', name: 'AuthService');
        return null;
      }, (Token t) {
        developer.log('🎯 Token acquired', name: 'AuthService');
        _currentUserId = "dummy-${DateTime.now().millisecondsSinceEpoch}";
        _userInfo = {
          "id": _currentUserId,
          "accessToken": t.accessToken,
          "refreshToken": t.refreshToken,
          "idToken": t.idToken,
          "tokenType": t.tokenType,
          "expiresIn": t.expiresIn.toString(),
        };
        developer.log('✅ Sign-in successful -> $_userInfo', name: 'AuthService');
        return _userInfo;
      });
    } catch (e, st) {
      developer.log('❌ Sign-in exception: $e', name: 'AuthService');
      developer.log('StackTrace: $st', name: 'AuthService');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _oauth.logout();
      _clearUserData();
      developer.log('✅ Signed out successfully', name: 'AuthService');
    } catch (e) {
      developer.log('⚠ Sign-out error: $e', name: 'AuthService');
      _clearUserData();
    }
  }

  void _clearUserData() {
    _currentUserId = null;
    _userInfo = null;
    developer.log('🧹 Cleared user data', name: 'AuthService');
  }
}
