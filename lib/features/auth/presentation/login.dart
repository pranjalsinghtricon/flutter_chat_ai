import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:elysia/core/constants/color_constants.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
import 'package:elysia/main.dart';
import 'package:elysia/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as developer;

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState.isLoggedIn && authState.userInfo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainLayout(child: ChatScreen()),
          ),
        );
      });
    }

    _logAuthSession();

    return Scaffold(
      backgroundColor: const Color(0xFFE6F5FF), // light blue background
      body: Stack(
        children: [
          // ===== White arc bottom =====
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6, // increased
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(170), // smoother + deeper arc
                ),
              ),
            ),
          ),

          Column(
            children: [
              // ===== Blue part (Logo + Elysia) =====
              Expanded(
                flex: 8,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/logo/logo.svg",
                        width: 38,
                        height: 38,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Elysia",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 200),
              // ===== White part (Welcome + Button + Terms) =====
              Expanded(
                flex: 6, // increased from 6
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                          authState.isLoading || !authState.isInitialized
                              ? null
                              : () async {
                            developer.log('🔵 Sign in button pressed',
                                name: 'LoginPage');
                            await ref
                                .read(authStateProvider.notifier)
                                .signIn();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F80A8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            elevation: 0,
                          ),
                          child: authState.isLoading
                              ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Signing in...'),
                            ],
                          )
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.login, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Sign in with Microsoft',
                                style: TextStyle(fontSize: 16,
                                    color: ColorConst.primaryWhite),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        "By continuing, you agree to our Terms of privacy policy",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
