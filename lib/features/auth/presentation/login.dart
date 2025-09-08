import 'package:elysia/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;
import '../../chat/presentation/screens/chat_screen.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  void initState() {
    super.initState();
    developer.log('🔄 LoginPage initialized', name: 'LoginPage');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    developer.log('🎨 Building LoginPage - Auth State: ${authState.isLoggedIn ? "Logged In" : "Logged Out"}', name: 'LoginPage');

    // Navigate to chat screen if already logged in
    if (authState.isLoggedIn && authState.userInfo != null) {
      developer.log('✅ User already logged in, navigating to chat...', name: 'LoginPage');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elysia Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Title
            const Icon(
              Icons.login,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),

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
              'Sign in with your Microsoft account to continue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),

            // Debug Info
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
                    Text(
                      authState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
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

            // Initialization Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: authState.isInitialized ? Colors.green.shade50 : Colors.orange.shade50,
                border: Border.all(
                  color: authState.isInitialized ? Colors.green.shade200 : Colors.orange.shade200,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    authState.isInitialized ? Icons.check_circle : Icons.pending,
                    color: authState.isInitialized ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    authState.isInitialized
                        ? 'MSAL Initialized Successfully'
                        : 'Initializing MSAL...',
                    style: TextStyle(
                      color: authState.isInitialized ? Colors.green.shade700 : Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // User Info (if logged in)
            if (authState.isLoggedIn && authState.userInfo != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Logged in as:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('ID: ${authState.userInfo!['id'] ?? 'N/A'}'),
                    Text('Username: ${authState.userInfo!['username'] ?? 'N/A'}'),
                    Text('Name: ${authState.userInfo!['name'] ?? 'N/A'}'),
                  ],
                ),
              ),
            ],

            // Sign In Button
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Signing in...'),
                  ],
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.microwave),
                    SizedBox(width: 8),
                    Text(
                      'Sign in with Microsoft',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sign Out Button (if logged in)
            if (authState.isLoggedIn) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                    developer.log('🔴 Sign out button pressed', name: 'LoginPage');
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

            // Debug Info
            Text(
              'Debug Mode: Detailed logs in console',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}