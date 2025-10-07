import 'dart:developer' as developer;
import 'package:elysia/main.dart';
import 'package:elysia/providers/auth_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/utiltities/navigations/navigation.dart';

class ProfileLandingScreen extends ConsumerWidget {
  const ProfileLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ListTile(
          //   leading: const Icon(Icons.person_outline),
          //   title: const Text("View Profile"),
          //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //   onTap: () {
          //     // TODO: Navigate to Profile details
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.settings_outlined),
          //   title: const Text("View Settings"),
          //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //   onTap: () {
          //     // TODO: Navigate to Settings
          //   },
          // ),
          // ListTile(
          //   leading: const Icon(Icons.notifications_outlined),
          //   title: const Text("Notifications"),
          //   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          //   onTap: () {
          //     // TODO: Navigate to Notifications
          //   },
          // ),
          // SwitchListTile(
          //   secondary: const Icon(Icons.brightness_6_outlined),
          //   title: Text(
          //     themeMode == ThemeMode.dark ? "Dark theme" : "Light theme",
          //   ),
          //   value: themeMode == ThemeMode.light,
          //   onChanged: (value) {
          //     ref.read(themeModeProvider.notifier).state = value
          //         ? ThemeMode.light
          //         : ThemeMode.dark;
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Log out", style: TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              developer.log('🔴 Log out pressed', name: 'ProfilePage');
              try {
                // Reset auth state
                ref.read(authStateProvider.notifier).signOut();
                NavigationService.navigateToLogin();
              } catch (e) {
                developer.log('❌ Sign out error: $e', name: 'ProfilePage');
              }
            },
          ),
        ],
      ),
    );
  }
}
