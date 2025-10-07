import 'package:elysia/features/chat/presentation/widgets/app_shortcut.dart';
import 'package:elysia/providers/auth_service_provider.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:elysia/features/chat/application/chat_controller.dart';

class WelcomeMessageScreen extends ConsumerWidget {
  const WelcomeMessageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final userFullName =
        authState.userInfo?['full_name'] ??
        authState.userInfo?['username'] ??
        'User';

    // return Padding(
    //   padding: const EdgeInsets.all(24.0),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       const Text(
    //         'Good afternoon.',
    //         style: TextStyle(
    //           fontSize: 20,
    //           color: ColorConst.primaryColor,
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //       const SizedBox(height: 5),
    //       const Text(
    //         'How can I assist you today?',
    //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    //       ),
    //       const SizedBox(height: 5),
    //       const _SuggestedPrompt('How are you'),
    //       const _SuggestedPrompt('Generate 5 catchy titles for a new journal in neuroscience'),
    //       const _SuggestedPrompt('Draft email to suppliers about new payment terms'),
    //       const _SuggestedPrompt('How will One Informa be measured?'),
    //       const SizedBox(height: 8),
    //       Padding(
    //         padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
    //         child: Row(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             SvgPicture.asset(
    //               AssetConsts.iconShield,
    //               width: 25,
    //               height: 25,
    //               colorFilter: ColorFilter.mode(
    //                 Theme.of(context).colorScheme.onSurface,
    //                 BlendMode.srcIn,
    //               ),
    //             ),
    //             const SizedBox(width: 6),
    //             const Expanded(
    //               child: Text(
    //                 'Your personal and company data are protected in this chat',
    //                 style: TextStyle(
    //                   fontSize: 13,
    //                   fontWeight: FontWeight.w500,
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );

    return Container(
      height:
          MediaQuery.of(context).size.height * 0.6, // Give it explicit height
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Hi $userFullName,",
              style:  TextStyle(
                fontFamily: 'Aleo',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                color: ColorConst.primaryBlack,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: const Text(
              "How can I assist you today?",
              style: TextStyle(
                fontFamily: 'Aleo',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: ColorConst.primaryBlack,
              ),
            ),
          ),
          // const SizedBox(height: 16),
          // const _SuggestedPrompt('How will One Informa improve career mobility within Informa?'),
          // const _SuggestedPrompt('Generate 5 catchy titles for a new journal in neuroscience'),
          // const _SuggestedPrompt('Draft email to suppliers about new payment terms'),
          // const _SuggestedPrompt('How will One Informa be measured?'),
          // const SizedBox(height: 16),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     SvgPicture.asset(
          //       AssetConsts.iconShield,
          //       width: 22,
          //       height: 22,
          //       colorFilter: ColorFilter.mode(
          //         Theme.of(context).colorScheme.onSurface,
          //         BlendMode.srcIn,
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     const Expanded(
          //       child: Text(
          //         'Your personal and company data are protected in this chat',
          //         style: TextStyle(
          //           fontSize: 13,
          //           fontWeight: FontWeight.w500,
          //         ),
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}

// Alternative solution - modify your ChatScreen's ListView section:
/*
In your ChatScreen, replace this section:

Expanded(
  child: ListView(
    controller: _scrollController,
    padding: const EdgeInsets.all(8.0),
    children: [
      if (messages.isEmpty && !widget.isPrivate)
        WelcomeMessageScreen(),
      // ... rest of your children
    ],
  ),
),

With this:

Expanded(
  child: messages.isEmpty && !widget.isPrivate
      ? WelcomeMessageScreen() // Show welcome screen directly without ListView
      : ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(8.0),
          children: [
            if (messages.isEmpty && widget.isPrivate)
              PrivateChatScreen(),
            if (messages.isNotEmpty)
              ...messages.asMap().entries.map(
                    (entry) {
                  final index = entry.key;
                  final msg = entry.value;
                  final isLast = index == messages.length - 1;

                  return MessageBubble(
                    message: msg,
                    isLast: isLast,
                    showPrivacyStatement: isLast && !isStreaming && !msg.isUser,
                  );
                },
              ),
          ],
        ),
),
*/

class _SuggestedPrompt extends ConsumerWidget {
  final String text;
  const _SuggestedPrompt(this.text, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: InkWell(
        onTap: () =>
            ref.read(chatControllerProvider.notifier).sendMessage(text, ref),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF444444) : Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // SvgPicture.asset(
              //   AssetConsts.iconSampleChat,
              //   width: 20,
              //   height: 20,
              // ),
              SvgPicture.asset(
                AssetConsts.iconSampleChat,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
