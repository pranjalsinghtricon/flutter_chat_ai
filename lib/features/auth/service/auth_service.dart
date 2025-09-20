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
  List<String> _samplePrompts = [];

  bool get isLoggedIn => _userInfo != null;
  Map<String, dynamic>? get userInfo => _userInfo;
  String? get currentUserId => _userInfo?['id'];
  List<String> get samplePrompts => _samplePrompts;

  Future<bool> initialize() async {
    try {
      // Check if user is already signed in with Amplify
      final authSession = await Amplify.Auth.fetchAuthSession();
      if (authSession.isSignedIn) {
        final user = await Amplify.Auth.getCurrentUser();
        final cognitoSession = authSession as CognitoAuthSession;
        final tokens = cognitoSession.userPoolTokensResult.valueOrNull;

        if (tokens?.accessToken != null) {
          _userInfo = {
            "id": user.userId,
            "username": user.username,
            "idToken": tokens?.idToken.raw,
            "accessToken": tokens?.accessToken.raw,
            "refreshToken": tokens?.refreshToken,
          };

          await saveAccessToken(tokens!.accessToken.raw);

          // Fetch profile information
          await fetchUserProfile();

          // ✅ NEW: Fetch sample prompts after profile
          await fetchSamplePrompts();

          developer.log("🔄 User session restored", name: "AuthService");
          return true;
        }
      }

      // Fallback to stored token
      final storedToken = await getStoredAccessToken();
      if (storedToken != null) {
        _userInfo ??= {};
        _userInfo!['accessToken'] = storedToken;

        // Try to fetch profile with stored token
        await fetchUserProfile();

        // ✅ NEW: Fetch sample prompts after profile
        await fetchSamplePrompts();

        developer.log("🔄 Restored access token from storage", name: "AuthService");
        return true;
      }
    } catch (e) {
      developer.log("⚠ Initialize error: $e", name: "AuthService");
      // Clear any corrupted data
      await _storage.delete(key: 'access_token');
      _userInfo = null;
      _samplePrompts = [];
    }

    return false;
  }

  Future<Map<String, dynamic>?> signIn() async {
    try {
      developer.log('🚀 Starting Cognito Hosted UI sign-in', name: 'AuthService');
      const clientId = "1pii8vb7lqo9j6st8p9ke8rjsd";

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

        // Fetch user profile after successful sign-in
        await fetchUserProfile();

        // ✅ NEW: Fetch sample prompts after profile
        await fetchSamplePrompts();

        developer.log('✅ Sign-in successful -> ${jsonEncode(_userInfo)}', name: 'AuthService');
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
          final fullName = userDoc['full_name'] as String?;
          final email = userDoc['email'] as String?;

          // Update user info with profile data
          _userInfo?['full_name'] = fullName ?? 'Unknown Name';
          _userInfo?['email'] = email ?? _userInfo?['username'];
          _userInfo?['profile'] = userDoc;

          developer.log('✅ Profile updated: ${_userInfo?['full_name']}', name: 'AuthService');
        }
        return true;
      } else {
        developer.log('⚠ Failed to fetch profile: ${response.statusCode}', name: 'AuthService');
        return false;
      }
    } catch (e, st) {
      developer.log('❌ Error fetching profile: $e', name: 'AuthService');
      developer.log('$st', name: 'AuthService');
      return false;
    }
  }

  Future<bool> fetchSamplePrompts() async {
    try {
      final token = getAccessToken();
      if (token == null) {
        developer.log('⚠ No access token for sample prompts', name: 'AuthService');
        return false;
      }

      final response = await http.get(
        Uri.parse('https://stream-api-qa.iiris.com/v2/ai/chat/prompts/sample'),
        headers: {
          'accept': 'application/json, text/plain, */*',
          'authorization': 'Bearer $token',
          'origin': 'https://elysia-qa.informa.com',
          'user-agent': 'ElysiaClient/1.0',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('✅ Sample Prompts Response: $jsonResponse', name: 'AuthService');

        final data = jsonResponse['data'] as List<dynamic>;
        _samplePrompts = data.map((item) => item['prompt'] as String).toList();

        developer.log('✅ Sample prompts fetched: ${_samplePrompts.length} prompts', name: 'AuthService');
        return true;
      } else {
        developer.log('⚠ Failed to fetch sample prompts: ${response.statusCode}', name: 'AuthService');
        // Set fallback prompts on API failure
        _samplePrompts = [
          "Draft email to suppliers about new payment terms",
          "Suggest tools and techniques for monitoring projects",
          "Suggest tools and techniques",
          "Generate catchy journal titles",
        ];
        return false;
      }
    } catch (e, st) {
      developer.log('❌ Error fetching sample prompts: $e', name: 'AuthService');
      developer.log('$st', name: 'AuthService');
      // Set fallback prompts on error
      _samplePrompts = [
        "Draft email to suppliers about new payment terms",
        "Suggest tools and techniques for monitoring projects",
        "Suggest tools and techniques",
        "Generate catchy journal titles",
      ];
      return false;
    }
  }

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
    developer.log('🔐 Token saved', name: 'AuthService');
  }

  Future<String?> getStoredAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> signOut() async {
    try {
      developer.log('🔴 Starting sign-out', name: 'AuthService');

      // Sign out from Amplify
      await Amplify.Auth.signOut(
        options: const SignOutOptions(globalSignOut: true),
      );

      // Clear all stored data
      _userInfo = null;
      _samplePrompts = [];
      await _storage.delete(key: 'access_token');
      await _storage.deleteAll(); // Clear all secure storage

      developer.log('✅ Signed out and all data cleared', name: 'AuthService');
    } catch (e, st) {
      developer.log('⚠ Sign-out error: $e', name: 'AuthService');
      developer.log('$st', name: 'AuthService');
      // Force clear data even if sign out fails
      _userInfo = null;
      _samplePrompts = [];
      await _storage.deleteAll();
    }
  }

  String? getAccessToken() => _userInfo?['accessToken'] as String?;

  // Helper method to get display name
  String getDisplayName() {
    if (_userInfo == null) return 'User';

    // Priority: full_name > email > username
    final fullName = _userInfo!['full_name'] as String?;
    if (fullName != null && fullName.isNotEmpty && fullName != 'Unknown Name') {
      return fullName;
    }

    final email = _userInfo!['email'] as String?;
    if (email != null && email.isNotEmpty) {
      // Extract name part from email
      return email.split('@')[0].replaceAll('.', ' ').split('_').last;
    }

    final username = _userInfo!['username'] as String?;
    if (username != null && username.isNotEmpty) {
      // Clean up username (remove Azure-SSO prefix, etc.)
      String cleanUsername = username;
      if (cleanUsername.contains('Azure-SSO_')) {
        cleanUsername = cleanUsername.split('Azure-SSO_').last;
      }
      if (cleanUsername.contains('@')) {
        cleanUsername = cleanUsername.split('@')[0];
      }
      return cleanUsername.replaceAll('.', ' ').replaceAll('_', ' ');
    }

    return 'User';
  }
}