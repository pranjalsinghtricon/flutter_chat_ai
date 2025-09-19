import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:elysia/providers/auth_service_provider.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
import 'package:elysia/main.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as developer;

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _logoMovedUp = false;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    // Animate logo upwards after 1s
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _logoMovedUp = true;
      });
    });

    // Show welcome + button after 2s
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showContent = true;
      });
    });

    _logAuthSession();
  }

  Future<void> _logAuthSession() async {
    try {
      final AuthSession session = await Amplify.Auth.fetchAuthSession();
      developer.log('🔑 Auth Session isSignedIn: ${session.isSignedIn}',
          name: 'LoginPage');
    } catch (e) {
      developer.log('❌ Error fetching auth session: $e', name: 'LoginPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final screenHeight = MediaQuery.of(context).size.height;

    const double logoSize = 100;
    final double initialTop = (screenHeight / 2) - (logoSize / 2); // center
    final double targetTop = screenHeight * 0.15; // move up

    if (authState.isLoggedIn && authState.userInfo != null) {
      print('User logged in ${authState}, heyy ${authState} ===== ${authState.userInfo}');
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await ref.read(authServiceProvider).fetchUserProfile();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainLayout(child: ChatScreen()),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: ColorConst.elysiaBackgroundBlue,
      body: Stack(
        children: [
          // === Half Circular White Background ===
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(900, 400),
                  topRight: Radius.elliptical(900, 400),
                ),
              ),
            ),
          ),

          // === Animated Logo ===
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            top: _logoMovedUp ? targetTop : initialTop,
            left: 0,
            right: 0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 800),
              scale: _logoMovedUp ? 0.5 : 1.0,
              curve: Curves.easeInOut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetConsts.elysiaLogo,
                    width: logoSize,
                    height: logoSize,
                  ),
                ],
              ),
            ),
          ),

          // === Content Fade-In ===
          AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: _showContent ? 1 : 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Welcome to Elysia",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: authState.isLoading || !authState.isInitialized
                            ? null
                            : () async {
                          developer.log('🔵 Sign in button pressed',
                              name: 'LoginPage');
                          await ref.read(authStateProvider.notifier).signIn();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F80A8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        icon: authState.isLoading
                            ? const SizedBox.shrink()
                            : SvgPicture.asset(
                          AssetConsts.microsoftLogo,
                        ),
                        label: authState.isLoading
                            ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Signing in...'),
                          ],
                        )
                            : const Text(
                          'Sign in with Microsoft',
                          style: TextStyle(
                            fontSize: 16,
                            color: ColorConst.primaryWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
