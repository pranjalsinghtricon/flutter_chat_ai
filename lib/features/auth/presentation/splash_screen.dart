import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/features/auth/presentation/login.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
import 'package:elysia/main.dart';
import 'package:elysia/providers/auth_service_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  void _navigate(BuildContext context, Widget page) {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.isInitialized && !authState.isLoading) {
        if (authState.isLoggedIn) {
          _navigate(context, const MainLayout(child: ChatScreen()));
        } else {
          _navigate(context, const LoginPage());
        }
      }
    });

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
