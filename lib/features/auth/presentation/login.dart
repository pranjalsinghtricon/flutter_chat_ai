
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:elysia/main.dart';
import 'package:elysia/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../../chat/presentation/screens/chat_screen.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  StreamSubscription? _sub;

  late AnimationController _logoController;
  late AnimationController _contentController;
  late Animation<Offset> _logoSlide;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    developer.log('🔄 LoginPage initialized', name: 'LoginPage');

    _logoController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _logoSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: const Offset(0, 0.0))
            .animate(CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
        ));

    // Content fade in
    _contentController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _contentFade =
        CurvedAnimation(parent: _contentController, curve: Curves.easeIn);

    // Start animations sequentially
    _logoController.forward().whenComplete(() {
      _contentController.forward();
    });

    _logAuthSession();
  }

  Future<void> _logAuthSession() async {
    try {
      final AuthSession session = await Amplify.Auth.fetchAuthSession();
      developer.log(
        '🎨 Auth Session isSignedIn: ${session.isSignedIn}',
        name: 'LoginPage',
      );
      developer.log(
        '🎨 Full Auth Session: $session',
        name: 'LoginPage',
      );
    } catch (e) {
      developer.log(
        '❌ Error fetching auth session: $e',
        name: 'LoginPage',
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            SlideTransition(
              position: _logoSlide,
              child: SvgPicture.asset(
                "assets/logo/logo.svg",
                width: 150,
                height: 150,
              ),
            ),
            const Spacer(),
            FadeTransition(
              opacity: _contentFade,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildLoginContent(authState),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginContent(authState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Welcome to Elysia',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sign in with your Microsoft account',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 48),
        if (authState.error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Authentication Error:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(authState.error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).clearError();
                  },
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ),
        ],
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: authState.isLoading || !authState.isInitialized
                ? null
                : () async {
              developer.log('🔵 Sign in button pressed', name: 'LoginPage');
              await ref.read(authStateProvider.notifier).signIn();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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
                    valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Signing in...'),
              ],
            )
                :  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/logo/microsoft.svg",
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sign in with Microsoft',
                  style: TextStyle(fontSize: 16),
                ),
              ],

            ),
          ),
        ),
        const SizedBox(height: 16),
        if (authState.isLoggedIn) ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: authState.isLoading
                  ? null
                  : () async {
                developer.log('🔴 Sign out button pressed',
                    name: 'LoginPage');
                await ref.read(authStateProvider.notifier).signOut();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
        Text(
          'Debug Mode: Detailed logs in console',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
