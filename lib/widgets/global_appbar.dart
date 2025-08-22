import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_appbar_icon_button.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_svg_icon_button.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_dropdown.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_dropdown_item.dart';
import 'package:flutter_chat_ai/features/chat/application/chat_controller.dart';
import 'package:flutter_chat_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter_chat_ai/features/profile/presentation/screens/profile_screen.dart';

class GlobalAppBar extends ConsumerWidget {
  const GlobalAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomAppbarIconButton(
                    assetPath: 'assets/icons/icon-new-topic.svg',
                    size: 25,
                    iconColor: Colors.blue,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      final chatHistory = ref.read(chatHistoryProvider);
                      final isOnWelcomeScreen =
                          chatHistory.isEmpty;

                      if (isOnWelcomeScreen) return;

                      ref.read(chatControllerProvider.notifier).resetChat();
                      ref.read(chatHistoryProvider.notifier)
                          .addNewChat("New Conversation");

                      if (ModalRoute.of(context)?.settings.name != '/chat') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: '/chat'),
                            builder: (_) => const MainLayout(child: ChatScreen()),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  CustomAppbarIconButton(
                    assetPath: 'assets/icons/icon-history.svg',
                    size: 25,
                    iconColor: Colors.blue,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ],
              ),
            ),
            CustomSvgIconButton(
              assetPath: 'assets/logo/Elysia-logo.svg',
              size: 30,
              backgroundColor: Colors.transparent,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const MainLayout(child: ChatScreen()),
                  ),
                );
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CustomTextDropdown(
                buttonText: 'AR',
                items: [
                  CustomDropdownItem(
                    icon: Icons.person,
                    iconColor: Colors.black87,
                    label: 'Profile',
                    onSelected: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const MainLayout(child: ProfileScreen()),
                        ),
                      );
                    },
                  ),
                  CustomDropdownItem(
                    icon: Icons.settings,
                    iconColor: Colors.black87,
                    label: 'View Settings',
                    onSelected: () {},
                  ),
                  CustomDropdownItem(
                    icon: Icons.notifications,
                    iconColor: Colors.black87,
                    label: 'Notifications',
                    onSelected: () {},
                  ),
                  CustomDropdownItem(
                    icon: Icons.logout,
                    iconColor: Colors.black87,
                    label: 'Log Out',
                    onSelected: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}