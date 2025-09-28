import 'package:elysia/common_ui_components/dropdowns/custom_icon_dropdown.dart';
import 'package:elysia/providers/private_chat_provider.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/common_ui_components/buttons/custom_appbar_icon_button.dart';
import 'package:elysia/common_ui_components/buttons/custom_svg_icon_button.dart';
import 'package:elysia/common_ui_components/dropdowns/custom_dropdown.dart';
import 'package:elysia/common_ui_components/dropdowns/custom_dropdown_item.dart';
import 'package:elysia/features/chat/application/chat_controller.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
import 'package:elysia/features/profile/presentation/screens/profile_screen.dart';
import 'package:elysia/main.dart';

class GlobalAppBar extends ConsumerWidget {
  const GlobalAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                            const MainLayout(child: ChatScreen()),
                          ),
                        );
                      },
                    ),
                  ]
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
                        assetPath: AssetConsts.iconPrivateChat,
                        size: 20,
                        backgroundColor: Colors.transparent,
                        iconColor: isPrivate ? const Color(0xFF00A76F) : null,
                        onPressed: () {
                          final notifier = ref.read(privateChatProvider.notifier);
                          notifier.state = !notifier.state;
                          
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainLayout(
                                child: ChatScreen(isPrivate: !isPrivate),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8), // Add spacing between icons
                  // Settings dropdown (with private chat item removed)
                  CustomIconDropdown(
                    icon: Icons.settings_outlined,
                    assetSize: 22,
                    items: [
                      CustomDropdownItem(
                        assetPath: AssetConsts.iconPaperclip,
                        assetSize: 20,
                        label: 'Attach photo',
                        onSelected: () {},
                      ),
                      // Add other dropdown items here if needed
                    ],
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