import 'package:elysia/providers/private_chat_provider.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/features/chat/application/saved_prompt_controller.dart';
import 'package:elysia/common_ui_components/snackbar/custom_snackbar.dart';

class CustomUserQueryCard extends ConsumerWidget {
  final String message;

  const CustomUserQueryCard({Key? key, required this.message})
      : super(key: key);

  Future<void> savePrompt(BuildContext context, WidgetRef ref, String prompt) async {
    try {
      await ref.read(savedPromptControllerProvider.notifier).savePrompt(prompt);
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          showCustomSnackBar(
            context: context,
            message: 'Prompt saved successfully',
            icon: Icons.bookmark_added_outlined,
          );
        }
      });
    } catch (e) {
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          showCustomSnackBar(
            context: context,
            message: 'Error saving prompt: $e',
            icon: Icons.error_outline,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = ref.watch(privateChatProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isPrivate)
            InkWell(
              onTap: () => savePrompt(context, ref, message),
              child: const Icon(Icons.bookmark_border, size: 20, color: Colors.black54),
            ),
          if (!isPrivate)
            const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: ColorConst.primaryChatQueryResponse,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
