import 'dart:async';
import 'dart:developer' as developer;
import 'package:elysia/features/auth/presentation/login.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../chat/presentation/screens/chat_screen.dart';
import '../../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Show splash for at least 1 sec
    await Future.delayed(const Duration(seconds: 1));
    final FlutterSecureStorage _storage = const FlutterSecureStorage();

    try {
      final session = await Amplify.Auth.fetchAuthSession() as CognitoAuthSession;

      developer.log("🔑 isSignedIn: ${session.isSignedIn}", name: "SplashScreen");

      if (session.isSignedIn) {
        final tokens = session.userPoolTokensResult.valueOrNull;
        developer.log("🟢 ID After Splash Token: ${tokens?.idToken.raw}", name: "SplashScreen");
        developer.log("🟢 Access After Splash Token: ${tokens?.accessToken.raw}", name: "SplashScreen");
        developer.log("🟢 Refresh After Splash Token: ${tokens?.refreshToken}", name: "SplashScreen");

        Future<void> saveAccessToken(String token) async {
          await _storage.write(key: 'access_token', value: token);
          developer.log(
            '🔐 Token saved in secure storage ======================================= : $token',
            name: 'AuthService',
          );
        }

        Future<String?> getStoredAccessToken() async {
          return await _storage.read(key: 'access_token');
        }

        _fadeTo(const MainLayout(child: ChatScreen()));
      } else {
        _fadeTo(const LoginPage());
      }
    } catch (e, st) {
      developer.log("❌ Error fetching session: $e", name: "SplashScreen");
      developer.log("$st", name: "SplashScreen");
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
          return FadeTransition(
            opacity: animation,
            child: child,
          );
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
