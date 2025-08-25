import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/application/chat_controller.dart';
import '../features/chat/data/models/chat_model.dart';
import '../common_ui_components/buttons/custom_icon_text_outlined_button.dart';
import '../common_ui_components/expandable_tile/custom_expandable_tile.dart';

class GlobalAppDrawer extends ConsumerWidget {
  const GlobalAppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatHistoryProvider);
    final now = DateTime.now();

    List<ChatHistory> today(List<ChatHistory> list) => list.where((c) =>
    c.updatedOn.year == now.year && c.updatedOn.month == now.month && c.updatedOn.day == now.day && !c.isArchived).toList();

    List<ChatHistory> last7(List<ChatHistory> list) => list.where((c) {
      final d = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      return c.updatedOn.isAfter(now.subtract(const Duration(days: 7))) && c.updatedOn.isBefore(d) && !c.isArchived;
    }).toList();

    List<ChatHistory> last30(List<ChatHistory> list) => list.where((c) =>
    c.updatedOn.isAfter(now.subtract(const Duration(days: 30))) && !c.isArchived && !today(list).contains(c) && !last7(list).contains(c)).toList();

    final archived = chats.where((c) => c.isArchived).toList();

    void openChat(ChatHistory chat) async {
      Navigator.pop(context);
      await ref.read(chatControllerProvider.notifier).loadSession(chat.sessionId);
      if (ModalRoute.of(context)?.settings.name != '/chat') {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/chat'),
            builder: (_) => const MainLayout(child: ChatScreen()),
          ),
        );
      }
    }

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
                text: 'New Chat',
                onPressed: () async {
                  final sessionId = await ref.read(chatControllerProvider.notifier).startNewChat();
                  await ref.read(chatControllerProvider.notifier).loadSession(sessionId);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  if (ModalRoute.of(context)?.settings.name != '/chat') {
                    // ignore: use_build_context_synchronously
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
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Chat History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
            ),
            CustomExpandableTile(title: "Today's", items: today(chats), onTapItem: openChat),
            CustomExpandableTile(title: 'Last 7 days', items: last7(chats), onTapItem: openChat),
            CustomExpandableTile(title: 'Last 30 days', items: last30(chats), onTapItem: openChat),
            CustomExpandableTile(title: 'Archived Chats', items: archived, onTapItem: openChat),
            const Divider(),
            ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), onTap: () => Navigator.pop(context)),
            ListTile(leading: const Icon(Icons.person), title: const Text('Profile'), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}
