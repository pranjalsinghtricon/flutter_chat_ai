import 'package:elysia/common_ui_components/dropdowns/custom_icon_dropdown.dart';
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
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 8),
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
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: CustomIconDropdown(
                icon: Icons.settings_outlined,
                assetSize: 22,
                items: [
                  CustomDropdownItem(
                    assetPath: AssetConsts.iconPrivateChat,
                    assetSize: 20,
                    label: 'Private chat',
                    onSelected: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainLayout(
                            child: ChatScreen(isPrivate: true),
                          ),
                        ),
                      );
                    },
                  ),
                  CustomDropdownItem(
                    assetPath: AssetConsts.iconPaperclip,
                    assetSize: 20,
                    label: 'Attach photo',
                    onSelected: () {},
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
