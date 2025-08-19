import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_appbar_icon_button.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_icon_text_outlined_button.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_svg_icon_button.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_dropdown.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_dropdown_item.dart';
import 'package:flutter_chat_ai/common_ui_components/expandable_tile/custom_expandable_tile.dart';
import 'package:flutter_chat_ai/features/chat/application/chat_controller.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/chat_screens/private_chat.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/chat_screens/welcome_message_screen.dart';
import 'package:flutter_chat_ai/features/profile/presentation/profile_screen.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.isPrivate = false});
  final bool isPrivate;

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
                    // iconColor: Colors.blue,
                    backgroundColor: Colors.transparent,
                    // tooltip: "Open Elysia",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(),
                        ),
                      );
                    },
                  ),
                  // SvgPicture.asset(
                  //   'assets/logo/Elysia-logo.svg',
                  //   width: 30,
                  //   height: 30,
                  // ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //don't remove
                        // Align(
                        //   alignment: Alignment.centerLeft,
                        //   child: IconButton(
                        //     icon: Icon(Icons.menu, color: Colors.blue, size: 30),
                        //     onPressed: () {
                        //       Scaffold.of(context).openDrawer();
                        //     },
                        //   ),
                        // ),

                        CustomAppbarIconButton(
                          assetPath: 'assets/icons/icon-new-topic.svg',
                          size: 25,
                          iconColor: Colors.blue,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            ref.read(chatControllerProvider.notifier).resetChat();
                            // Ensure the screen rebuilds from welcome state
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const ChatScreen()),
                            );
                          },

                        ),
                        SizedBox(width: 10,),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Stack(
                      children: [
                        CustomTextDropdown(
                          buttonText: 'AR',
                          items: [
                            CustomDropdownItem(
                              icon: Icons.person,
                              iconColor: Colors.teal,
                              label: 'Profile',
                              onSelected: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(),
                                  ),
                                );
                              },
                            ),
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? widget.isPrivate
                  ? const PrivateChatScreen()
                  : const WelcomeMessageScreen()
                  : ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return MessageBubble(message: msg);
                },
              ),
            ), // stays same for both

            ChatInputField(),
          ],
        ),
      ),

    );
  }
}

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CustomIconTextOutlinedButton(
                icon: Icons.add,
                text: "New Chat",
                onPressed: () {
                  ref.read(chatControllerProvider.notifier).resetChat();
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ChatScreen()),
                  );
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

            // Expandable Categories
            CustomExpandableTile(
              title: "Today",
              // leadingIcon: Icons.today,
              items: [
                "Informa AI assistant Elysia on ...",
                "Catch up meeting notes",
                "Draft supplier email",
              ],
            ),
            CustomExpandableTile(
              title: "Last 7 days",
              // leadingIcon: Icons.calendar_view_week,
              items: [
                "Neuroscience journal titles",
                "Project kickoff discussion",
              ],
            ),
            CustomExpandableTile(
              title: "Last 30 days",
              // leadingIcon: Icons.calendar_month,
              items: [
                "Career mobility plan",
                "Team retrospective",
                "Monthly review summary",
              ],
            ),
            CustomExpandableTile(
              title: "Archived Chats",
              // leadingIcon: Icons.archive,
              items: [
                "Old supplier contract discussion",
                "AI product brainstorming",
              ],
            ),

            const Divider(),

            // Settings
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}


