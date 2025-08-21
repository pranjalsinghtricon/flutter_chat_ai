import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_chat_ai/common_ui_components/buttons/custom_icon_text_outlined_button.dart';
import 'package:flutter_chat_ai/common_ui_components/expandable_tile/custom_expandable_tile.dart';
import 'package:flutter_chat_ai/features/chat/application/chat_controller.dart';
import 'package:flutter_chat_ai/features/chat/presentation/chat_screen.dart';

class GlobalAppDrawer extends ConsumerWidget {
  const GlobalAppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatHistoryProvider);

    // Group chats
    final now = DateTime.now();
    final today = chats.where((chat) =>
    chat.updatedOn.day == now.day &&
        chat.updatedOn.month == now.month &&
        chat.updatedOn.year == now.year).toList();

    final last7Days = chats.where((chat) =>
    chat.updatedOn.isAfter(now.subtract(const Duration(days: 7))) &&
        chat.updatedOn.isBefore(now.subtract(const Duration(days: 1)))).toList();

    final last30Days = chats.where((chat) =>
    chat.updatedOn.isAfter(now.subtract(const Duration(days: 30))) &&
        !last7Days.contains(chat) &&
        !today.contains(chat)).toList();

    final archived = chats.where((chat) => chat.isArchived).toList();

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomIconTextOutlinedButton(
                assetPath: 'assets/icons/icon-new-topic.svg',
                text: "New Chat",
                onPressed: () {
                  ref.read(chatControllerProvider.notifier).resetChat();
                  ref.read(chatHistoryProvider.notifier).addNewChat("New Conversation");

                  Navigator.pop(context);

                  // Prevent duplicate navigation
                  if (ModalRoute.of(context)?.settings.name != '/chat') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        settings: const RouteSettings(name: '/chat'),
                        builder: (_) => const MainLayout(
                          child: ChatScreen(),
                        ),
                      ),
                    );
                  }
                },

              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Chat History",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),

            // Expandable groups
            CustomExpandableTile(
              title: "Today's",
              items: today.map((chat) => chat.title).toList(),
            ),
            CustomExpandableTile(
              title: "Last 7 days",
              items: last7Days.map((chat) => chat.title).toList(),
            ),
            CustomExpandableTile(
              title: "Last 30 days",
              items: last30Days.map((chat) => chat.title).toList(),
            ),
            CustomExpandableTile(
              title: "Archived Chats",
              items: archived.map((chat) => chat.title).toList(),
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
