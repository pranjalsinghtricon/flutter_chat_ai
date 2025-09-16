import 'package:amplify_flutter/amplify_flutter.dart';
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ===== Top blue header with logo =====
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: const BoxDecoration(
              color: Color(0xFFE6F5FF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/logo/logo.svg",
                  width: 70,
                  height: 70,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Elysia",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ===== Welcome Text =====
          const Text(
            "Welcome to Elysia",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),

          // ===== Sign In Button =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: authState.isLoading || !authState.isInitialized
                    ? null
                    : () async {
                  developer.log('🔵 Sign in button pressed',
                      name: 'LoginPage');
                  await ref.read(authStateProvider.notifier).signIn();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Signing in...'),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'Sign in with Microsoft',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // ===== Terms and Privacy Text =====
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Text(
              "By continuing, you agree to our Terms of privacy policy",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
