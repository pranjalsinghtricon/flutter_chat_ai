import 'dart:convert';
import 'dart:developer' as developer;
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Map<String, dynamic>? _userInfo;

  bool get isLoggedIn => _userInfo != null;
  Map<String, dynamic>? get userInfo => _userInfo;
  String? get currentUserId => _userInfo?['id'];

  Future<bool> initialize() async {
    final storedToken = await getStoredAccessToken();
    if (storedToken != null) {
      _userInfo ??= {};
      _userInfo!['accessToken'] = storedToken;
      developer.log("🔄 Restored access token from storage", name: "AuthService");
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> signIn() async {
    try {
      developer.log('🚀 Starting Cognito Hosted UI sign-in', name: 'AuthService');
      const clientId = "clientId"; // replace with real app client id if needed
      final res = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.oidc("Azure-SSO", clientId),
        options: const SignInWithWebUIOptions(
          pluginOptions: CognitoSignInWithWebUIPluginOptions(
            isPreferPrivateSession: true,
          ),
        ),
      );

      if (res.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
        final tokens = session.userPoolTokensResult.valueOrNull;

        _userInfo = {
          "id": user.userId,
          "username": user.username,
          "idToken": tokens?.idToken.raw,
          "accessToken": tokens?.accessToken.raw,
          "refreshToken": tokens?.refreshToken,
        };

        if (tokens?.accessToken != null) {
          await saveAccessToken(tokens!.accessToken.raw);
        }

        developer.log('✅ Sign-in successful -> ${jsonEncode(_userInfo)}',
            name: 'AuthService');
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

  Future<bool> fetchUserProfile() async {
    try {
      final token = getAccessToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('https://stream-api-qa.iiris.com/v2/ai/profile/self'),
        headers: {
          'accept': 'application/json',
          'authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('✅ Profile Response: $jsonResponse', name: 'AuthService');
        final data = jsonResponse['data'] as List<dynamic>;
        if (data.isNotEmpty) {
          final userDoc = data[0]['doc'];
          _userInfo?['full_name'] = userDoc['full_name'] ?? 'Unknown Name';
        }
        return true;
      } else {
        developer.log('⚠ Failed to fetch profile: ${response.statusCode}',
            name: 'AuthService');
        return false;
      }
    } catch (e, st) {
      developer.log('❌ Error fetching profile: $e', name: 'AuthService');
      developer.log('$st', name: 'AuthService');
      return false;
    }
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
    developer.log('🔐 Token saved: $token', name: 'AuthService');
  }

  Future<String?> getStoredAccessToken() async {
    developer.log('🔐 Get Stored Access token: ', name: 'AuthService');
    return await _storage.read(key: 'access_token');
  }

  Future<void> signOut() async {
    try {
      developer.log('🔴 Starting sign-out', name: 'AuthService');
      await Amplify.Auth.signOut(
        options: const SignOutOptions(globalSignOut: true),
      );
      _userInfo = null;
      await _storage.delete(key: 'access_token');
      developer.log('✅ Signed out and token cleared', name: 'AuthService');
    } catch (e, st) {
      developer.log('⚠ Sign-out error: $e', name: 'AuthService');
      developer.log('$st', name: 'AuthService');
    }
  }

  String? getAccessToken() => _userInfo?['accessToken'] as String?;
}
