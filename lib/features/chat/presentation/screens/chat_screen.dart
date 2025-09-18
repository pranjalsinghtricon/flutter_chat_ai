// chat_screen.dart
import 'package:elysia/features/chat/presentation/widgets/app_shortcut.dart';
import 'package:elysia/features/chat/presentation/widgets/custom_horizontal_scrollanble_card.dart';
import 'package:flutter/material.dart';
import 'package:elysia/features/chat/application/chat_controller.dart';
import 'package:elysia/features/chat/presentation/screens/private_chat.dart';
import 'package:elysia/features/chat/presentation/screens/welcome_message_screen.dart';
import 'package:elysia/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:elysia/features/chat/presentation/widgets/message_bubble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.isPrivate = false});
  final bool isPrivate;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      setState(() {}); // rebuild on input change
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatControllerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    if (messages.isEmpty && !widget.isPrivate)
                      WelcomeMessageScreen(),
                    if (messages.isEmpty && widget.isPrivate)
                      PrivateChatScreen(),
                    if (messages.isNotEmpty)
                      ...messages.map(
                            (msg) => MessageBubble(
                          message: msg,
                          isLast: false,
                        ),
                      ),
                  ],
                ),
              ),
              // if (messages.isEmpty)
              //   if (_inputController.text.isEmpty)
              //     Padding(
              //       padding: const EdgeInsets.symmetric(vertical: 8.0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceAround,
              //         children: const [
              //           AppShortcut(icon: AssetConsts.iconAiImages, label: "AI Images"),
              //           AppShortcut(icon: AssetConsts.iconAiImages, label: "PapagAlo"),
              //           AppShortcut(icon: AssetConsts.iconCareerCoach, label: "Career Coach"),
              //           AppShortcut(icon: AssetConsts.iconMoreApp, label: "More Apps"),
              //         ],
              //       ),
              //     )
              //   else
              //     CustomHorizontalScrollableCard(
              //       items: const [
              //         "Draft email to suppliers about new payment terms",
              //         "Suggest tools and techniques for monitoring projects",
              //         "Suggest tools and techniques",
              //         "Suggest tools and techniques for monitoring projects",
              //         "Generate catchy journal titles",
              //       ],
              //     ),
              ChatInputField(controller: _inputController),
            ],
          ),
        ),
      ),
    );
  }
}
