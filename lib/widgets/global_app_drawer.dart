import 'dart:developer' as developer;
import 'package:elysia/providers/auth_service_provider.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:elysia/features/auth/presentation/login.dart';
import 'package:elysia/features/profile/presentation/screens/profile_landing_screen.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/application/chat_controller.dart';
import '../features/chat/data/models/chat_model.dart';
import '../common_ui_components/expandable_tile/custom_expandable_tile.dart';
import 'dart:developer' as developer;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class GlobalAppDrawer extends ConsumerWidget {
  const GlobalAppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatHistoryProvider);
    final themeMode = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateProvider);

// 🔎 Debugging output
    developer.log("AuthState -------- ----- - -- - - : $authState", name: "LoginPage");
    developer.log("AuthState.userInfo ------ - - -- -- -- - - --  -: ${authState.userInfo}", name: "LoginPage");

    final userFullName =
        authState.userInfo?['full_name'] ??
            authState.userInfo?['username'] ??
            'User';

    String getInitials(String name) {
      final parts = name.trim().split(' ');
      if (parts.isEmpty) return '';
      if (parts.length == 1) return parts[0][0].toUpperCase();
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }

    // Cache the current route name to avoid unsafe ancestor lookup
    final currentRouteName = ModalRoute.of(context)?.settings.name;

    void openChat(ChatHistory chat) async {
      Navigator.of(context, rootNavigator: true).pop();
      await ref.read(chatControllerProvider.notifier).loadSession(chat.sessionId);
      if (currentRouteName != '/chat') {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(
            settings: const RouteSettings(name: '/chat'),
            builder: (_) => const MainLayout(child: ChatScreen()),
          ),
        );
      }
    }

    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(12.0),
                  //   child: TextField(
                  //     decoration: InputDecoration(
                  //       hintText: "Search",
                  //       prefixIcon: const Icon(Icons.search),
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(12.0),
                  //   child: CustomIconTextOutlinedButton(
                  //     assetPath: 'assets/icons/icon-new-topic.svg',
                  //     text: 'New Chat',
                  //     onPressed: () async {
                  //       final sessionId = await ref
                  //           .read(chatControllerProvider.notifier)
                  //           .startNewChat();
                  //       await ref
                  //           .read(chatControllerProvider.notifier)
                  //           .loadSession(sessionId);
                  //       Navigator.pop(context);
                  //       if (ModalRoute.of(context)?.settings.name != '/chat') {
                  //         Navigator.pushReplacement(
                  //           context,
                  //           MaterialPageRoute(
                  //             settings: const RouteSettings(name: '/chat'),
                  //             builder: (_) =>
                  //             const MainLayout(child: ChatScreen()),
                  //           ),
                  //         );
                  //       }
                  //     },
                  //   ),
                  // ),

                  InkWell(
                    onTap: () async {
                      final sessionId = await ref
                          .read(chatControllerProvider.notifier)
                          .startNewChat();
                      await ref
                          .read(chatControllerProvider.notifier)
                          .loadSession(sessionId);
                      Navigator.pop(context);
                      if (ModalRoute.of(context)?.settings.name != '/chat') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/chat'),
                            builder: (_) =>
                            const MainLayout(child: ChatScreen()),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            AssetConsts.iconNewTopic,
                            width: 20,
                            height: 20,
                            color: const Color(0xFF525A5C),
                          ),
                          const SizedBox(width: 20),
                          const Text(
                            'New Chat',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFDADADA), thickness: 1, height: 1),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/icon-history.svg',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 20),
                        const Text(
                          'Chat History',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // CustomExpandableTile(
                  // const Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //   child: Text(
                  //     'Chat History',
                  //     style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 16
                  //     ),
                  //   ),
                  // ),
                  if (chats?.today.isNotEmpty ?? false)
                    CustomExpandableTile(
                      title: "Today's",
                      items: chats!.today,
                      onTapItem: openChat,
                    ),
                  if (chats?.yesterday.isNotEmpty ?? false)
                    CustomExpandableTile(
                      title: "Yesterday",
                      items: chats!.yesterday,
                      onTapItem: openChat,
                    ),
                  if (chats?.last7.isNotEmpty ?? false)
                    CustomExpandableTile(
                      title: "Last 7 days",
                      items: chats!.last7,
                      onTapItem: openChat,
                    ),
                  if (chats?.last30.isNotEmpty ?? false)
                    CustomExpandableTile(
                      title: "Last 30 days",
                      items: chats!.last30,
                      onTapItem: openChat,
                    ),
                  if (chats?.archived.isNotEmpty ?? false)
                    CustomExpandableTile(
                      title: "Archived Chats",
                      items: chats!.archived,
                      onTapItem: openChat,
                    ),
                  // const Divider(),
                  // ListTile(
                  //   leading: Icon(
                  //     Icons.settings,
                  //     color: Theme.of(context).colorScheme.onSurface,
                  //   ),
                  //   title: Text(
                  //     'Settings',
                  //     style: TextStyle(
                  //       color: Theme.of(context).colorScheme.onSecondary,
                  //     ),
                  //   ),
                  //   onTap: () => Navigator.pop(context),
                  // ),
                  // ListTile(
                  //   leading: Icon(
                  //     Icons.person,
                  //     color: Theme.of(context).colorScheme.onSurface,
                  //   ),
                  //   title: Text(
                  //     'Profile',
                  //     style: TextStyle(
                  //       color: Theme.of(context).colorScheme.onSecondary,
                  //     ),
                  //   ),
                  //   onTap: () => Navigator.pop(context),
                  // ),
                  // ListTile(
                  //   leading: Icon(
                  //     Icons.logout,
                  //     color: Theme.of(context).colorScheme.onSurface,
                  //   ),
                  //   title: Text(
                  //     'Sign Out',
                  //     style: TextStyle(
                  //       color: Theme.of(context).colorScheme.onSecondary,
                  //     ),
                  //   ),
                  //   onTap: () async {
                  //     developer.log('🔴 Sign out button pressed', name: 'GlobalAppDrawer');
                  //
                  //     try {
                  //       SignOutResult result = await Amplify.Auth.signOut();
                  //       developer.log('✅ Sign out result: ${result.toString()}', name: 'GlobalAppDrawer');
                  //     } catch (e) {
                  //       developer.log('❌ Sign out error: $e', name: 'GlobalAppDrawer');
                  //     }
                  //
                  //     // Reset auth state
                  //     ref.read(authStateProvider.notifier).signOut();
                  //
                  //     Navigator.pop(context); // Close drawer
                  //     Navigator.pushReplacement(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const LoginPage(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  //
                  // ListTile(
                  //   leading: Icon(Icons.article_outlined),
                  //   title: Text(
                  //     "Manage Content",
                  //     style: TextStyle(
                  //       color: Theme.of(context).colorScheme.onSecondary,
                  //     ),
                  //   ),
                  // ),
                  //
                  //  ListTile(
                  //   leading: Icon(Icons.help_outline),
                  //   title: Text(
                  //     "Help",
                  //     style: TextStyle(
                  //       color: Theme.of(context).colorScheme.onSecondary,
                  //     ),),
                  // ),

                ],
              ),
            ),
            const Divider(color: Color(0xFFDADADA), thickness: 1, height: 1),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: ColorConst.primaryColor,
                child: Text(getInitials(userFullName)),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userFullName,
                    style: const TextStyle(
                      color: ColorConst.primaryBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileLandingScreen(),
                  ),
                );
              },
            ),
            // SwitchListTile(
            //   title: Text(
            //     "Dark Mode",
            //     style: TextStyle(
            //       color: Theme.of(context).colorScheme.onSecondary,
            //     ),
            //   ),
            //   secondary: Icon(
            //     Icons.brightness_6,
            //     color: Theme.of(context).colorScheme.onSurface,
            //   ),
            //   value: themeMode == ThemeMode.dark,
            //   onChanged: (value) {
            //     ref.read(themeModeProvider.notifier).state =
            //     value ? ThemeMode.dark : ThemeMode.light;
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                developer.log('🔴 Sign out pressed', name: 'GlobalAppDrawer');
                await ref.read(authStateProvider.notifier).signOut();
                Navigator.pop(context); // Close drawer
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}