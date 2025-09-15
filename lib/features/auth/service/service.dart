// Service.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Map<String, dynamic>? _userInfo;

  bool get isInitialized => true; // Amplify configured in main
  bool get isLoggedIn => _userInfo != null;
  Map<String, dynamic>? get userInfo => _userInfo;
  String? get currentUserId => _userInfo?['id'];

  Future<bool> initialize() async => true;

  /// Sign in using Cognito Hosted UI with Azure AD as IdP
  Future<Map<String, dynamic>?> signIn() async {
    try {
      developer.log('🚀 Starting Cognito Hosted UI sign-in', name: 'AuthService');

      // Replace provider and clientId with values in your Cognito setup
      const clientId = "clientId"; // replace with real app client id if needed

      final res = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.oidc("Azure-SSO", clientId),
      );

      if (res.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
        final tokens = session.userPoolTokensResult.valueOrNull;

        _userInfo = {
          "id": user.userId,
          "username": user.username,
          "idToken": tokens?.idToken.raw,        // JsonWebToken → String
          "accessToken": tokens?.accessToken.raw, // JsonWebToken → String
          "refreshToken": tokens?.refreshToken,   // Already String
        };

        // Save the access token securely
        if (tokens?.accessToken != null) {
          await saveAccessToken(tokens!.accessToken.raw);
        }

        developer.log(
          '✅ Sign-in successful -> ${jsonEncode(_userInfo)}',
          name: 'AuthService',
        );

        return _userInfo;
      }

      developer.log('⚠ Sign-in cancelled or failed', name: 'AuthService');
      return null;
    } catch (e, st) {
      developer.log('❌ Sign-in error: $e', name: 'AuthService');
      developer.log('$st', name: 'AuthService');
      return null;
    }
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
    developer.log(
      'Token saved in secure storage ========================================= : $token',
      name: 'AuthService File',
    );
  }

  Future<String?> getStoredAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> signOut() async {
    try {
      developer.log('🔴 Starting sign-out', name: 'AuthService');
      await Amplify.Auth.signOut(
        options: const SignOutOptions(globalSignOut: true),
      );
      _userInfo = null;
      developer.log('✅ Signed out from Cognito + Azure AD', name: 'AuthService');
    } catch (e, st) {
      developer.log('⚠ Sign-out error: $e', name: 'AuthService');
      developer.log('$st', name: 'AuthService');
    }
  }

  /// Helper to get access token (from memory, if available)
  String? getAccessToken() => _userInfo?['accessToken'] as String?;
}
