import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_svg_icon_button.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_dropdown.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_dropdown_item.dart';
import 'package:flutter_chat_ai/features/chat/application/chat_controller.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatControllerProvider);

    // Auto-scroll to bottom when new message is added
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Builder(
          builder: (context) {
            return SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomSvgIconButton(
                    assetPath: 'assets/logo/Elysia-logo.svg',
                    size: 30,
                    iconColor: Colors.blue,
                    backgroundColor: Colors.white,
                    tooltip: "Open Elysia",
                    onPressed: () {
                      print("Elysia logo clicked!");
                    },
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AppBarIconButton(
                          icon: Icons.menu,
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                        const SizedBox(width: 8),
                        _AppBarIconButton(
                          icon: Icons.chat_bubble_outline,
                          onTap: () {
                            // New chat logic
                          },
                        ),
                        const SizedBox(width: 8),
                        _AppBarIconButton(
                          icon: Icons.history,
                          onTap: () {
                            // History logic
                          },
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Stack(
                      children: [
                        CustomTextDropdown(
                          buttonText: 'AR',
                          items: [
                            CustomDropdownItem(
                              icon: Icons.settings,
                              iconColor: Colors.blue,
                              label: 'View Settings',
                              onSelected: () {
                                // Do something!
                              },
                            ),
                            CustomDropdownItem(
                              icon: Icons.notifications,
                              iconColor: Colors.red,
                              label: 'Notifications',
                              onSelected: () {
                                // Do something!
                              },
                            ),
                            CustomDropdownItem(
                              icon: Icons.logout,
                              iconColor: Colors.black54,
                              label: 'Log Out',
                              onSelected: () {
                                // Do something!
                              },
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const WelcomeMessage()
                : ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return MessageBubble(message: msg);
              },
            ),
          ),
          ChatInputField(),
        ],
      ),
    );
  }
}

class WelcomeMessage extends StatelessWidget {
  const WelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Good afternoon.",
            style: TextStyle(
              fontSize: 18,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "How can I assist you today?",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          const SuggestedPrompt(
              "How will One Informa improve career mobility within Informa?"),
          const SuggestedPrompt(
              "Generate 5 catchy titles for a new journal in neuroscience"),
          const SuggestedPrompt(
              "Draft email to suppliers about new payment terms"),
          const SuggestedPrompt("How will One Informa be measured?"),
          const SizedBox(height: 8),
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
            child: const Text(
              "🛡️ Your personal and company data are protected in this chat",
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestedPrompt extends ConsumerWidget {
  final String text;
  const SuggestedPrompt(this.text, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () {
          ref.read(chatControllerProvider.notifier).sendMessage(text);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.message, size: 18, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const DrawerHeader(
              child: Text(
                'Elysia AI',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Chat History'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to history screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade200,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: Colors.blue),
        ),
      ),
    );
  }
}
