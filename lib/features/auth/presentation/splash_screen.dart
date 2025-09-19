import 'dart:async';
import 'dart:developer' as developer;
import 'package:elysia/features/auth/presentation/login.dart';
import 'package:elysia/features/auth/service/service.dart';
import 'package:elysia/features/chat/data/repositories/chat_repository.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../chat/presentation/screens/chat_screen.dart';
import '../../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final ChatRepository _chatRepository = ChatRepository();

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;
      developer.log("🔑 isSignedIn: ${session.isSignedIn} ${Amplify.Auth.fetchAuthSession()}", name: "SplashScreen");

      if (session.isSignedIn) {
        final tokens = session.userPoolTokensResult.valueOrNull;

        if (tokens?.accessToken != null) {
          await _authService.saveAccessToken(tokens!.accessToken.raw);
        }

        developer.log("🟢 ID Token: ${tokens?.idToken.raw}", name: "SplashScreen");
        developer.log("🟢 Access Token: ${tokens?.accessToken.raw}", name: "SplashScreen");
        developer.log("🟢 Refresh Token: ${tokens?.refreshToken}", name: "SplashScreen");

        developer.log("✅ ========= User Profile Fetched: 1 ", name: "SplashScreen");
        developer.log("✅ ========= User Profile Fetched: 2 ", name: "SplashScreen");
        developer.log("✅ ========= User Profile Fetched: 3 ", name: "SplashScreen");

        // 🔹 Only navigate if API returns true
        final success = await _authService.fetchUserProfile();
        developer.log("✅ ========= User Profile Fetched: 100 ", name: "SplashScreen");
        if (success) {
          developer.log("✅ ========= User Profile Fetched 101: Success ", name: "SplashScreen");

          try {
            final chats = await _chatRepository.fetchChatsFromApi();
            developer.log("✅ ========= Prefetched chats 102: today=${chats.today.length}", name: "SplashScreen");
          } catch (e) {
            developer.log("⚠ ======== Failed to prefetch chats 103: $e", name: "SplashScreen");
          }
          _fadeTo(const MainLayout(child: ChatScreen()));
        } else {
          developer.log("✅ ========= User Profile Fetched: 201 ", name: "SplashScreen");
          _fadeTo(const LoginPage());
        }
      } else {
        developer.log("✅ ========= User Profile Fetched: 202 ", name: "SplashScreen");
        _fadeTo(const LoginPage());
      }
    } catch (e, st) {
      developer.log("❌ Error fetching session: $e", name: "SplashScreen");
      developer.log("$st", name: "SplashScreen");

      // Try restoring from secure storage
      final storedToken = await _authService.getStoredAccessToken();
      if (storedToken != null) {
        developer.log("🔄 Restored access token from storage 108", name: "SplashScreen");

        // 🔹 Only navigate if API returns true
        final success = await _authService.fetchUserProfile();
        if (success) {
          _fadeTo(const MainLayout(child: ChatScreen()));
        } else {
          _fadeTo(const LoginPage());
        }
        return;
      }

      _fadeTo(const LoginPage());
    }
  }


  void _fadeTo(Widget page) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 700),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.elysiaBackgroundBlue,
      body: Center(
        child: SvgPicture.asset(
          AssetConsts.elysiaLogo,
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
