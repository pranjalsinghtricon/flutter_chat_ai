import 'package:elysia/common_ui_components/dropdowns/custom_icon_dropdown.dart';
import 'package:elysia/providers/private_chat_provider.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/common_ui_components/buttons/custom_svg_icon_button.dart';
import 'package:elysia/common_ui_components/dropdowns/custom_dropdown_item.dart';
import 'package:elysia/features/chat/application/chat_controller.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
import 'package:elysia/main.dart';

class GlobalAppBar extends ConsumerWidget {
  const GlobalAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = ref.watch(privateChatProvider);
    
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
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
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.menu),
                        color: Theme.of(context).colorScheme.onSurface,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                  CustomSvgIconButton(
                    assetPath: AssetConsts.elysiaNamedLogo,
                    size: 25,
                    backgroundColor: Colors.transparent,
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         const MainLayout(child: ChatScreen()),
                      //   ),
                      //);
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Private chat toggle button
                  Consumer(
                    builder: (context, ref, _) {
                      final isPrivate = ref.watch(privateChatProvider);
                      return CustomSvgIconButton(
                        assetPath: isPrivate
                            ? AssetConsts.iconPrivateChatTick
                            : AssetConsts.iconPrivateChat,
                        size: isPrivate ? 20 : 20,
                        backgroundColor: Colors.transparent,
                        iconColor: isPrivate ? ColorConst.primaryColor : ColorConst.primaryDarkBlack,
                        onPressed: () async {
                          // Toggle private chat state
                          final notifier = ref.read(
                            privateChatProvider.notifier,
                          );
                          notifier.state = !notifier.state;

                          // Reset chat controller state to clear current chat
                          final chatController = ref.read(
                            chatControllerProvider.notifier,
                          );
                          chatController.resetChatViewOnly();

                          // Start a fresh chat session
                          await chatController.startNewChat();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                settings: const RouteSettings(name: '/chat'),
                                pageBuilder: (context, animation, secondaryAnimation) => MainLayout(
                                  child: ChatScreen(isPrivate: !isPrivate),
                                ),
                                transitionsBuilder:
                                    (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                transitionDuration: const Duration(milliseconds: 300),
                              ),
                            );
                          }
                        },
                      );

                    },
                  ),
                  // const SizedBox(width: 8), // Add spacing between icons
                  // // Settings dropdown (with private chat item removed)
                  // CustomIconDropdown(
                  //   icon: Icons.settings_outlined,
                  //   assetSize: 22,
                  //   items: [
                  //     CustomDropdownItem(
                  //       assetPath: AssetConsts.iconPaperclip,
                  //       assetSize: 20,
                  //       label: 'Attach photo',
                  //       onSelected: () {},
                  //     ),
                  //     // Add other dropdown items here if needed
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
        ),
        if (isPrivate)
          Container(
            width: double.infinity,
            height: 32,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
              color:ColorConst.primaryColor.withAlpha((0.1 * 255).toInt()),
              // border: Border(
              //   bottom: BorderSide(
              //     color: ColorConst.primaryColor.withOpacity(0.1),
              //   ),
              // ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: ColorConst.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'You are now in a private chat',
                  style: TextStyle(
                    color: ColorConst.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
      ),
    );
  }
}
