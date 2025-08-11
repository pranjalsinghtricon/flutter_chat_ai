import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_icon_button.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_dropdown_item.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_icon_dropdown.dart';
import 'package:flutter_chat_ai/features/chat/application/chat_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatInputField extends ConsumerStatefulWidget {
  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatControllerProvider.notifier).sendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(

        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 14.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 120,
                    ),
                    child: Scrollbar(
                      child: TextField(
                        controller: _controller,
                        maxLength: 2000,
                        maxLines: null,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'Ask Elysia anything',
                          counterText: '',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),

                ),
                Row(
                  children: [
                    CustomIconDropdown(
                      icon: Icons.grid_view,
                      iconColor: Colors.grey,
                      items: [
                        CustomDropdownItem(
                          icon: Icons.lock_outline, // or Icons.security
                          iconColor: Colors.black54,
                          label: 'Private chat',
                          onSelected: () {
                            // Handle private chat
                          },
                        ),
                        CustomDropdownItem(
                          icon: Icons.attach_file,
                          iconColor: Colors.black54,
                          label: 'Attach file',
                          onSelected: () {
                            // Handle attach file
                          },
                        ),
                        CustomDropdownItem(
                          icon: Icons.source, // or use Icons.insert_drive_file
                          iconColor: Colors.black54,
                          label: 'Add sources',
                          onSelected: () {
                            // Handle add sources
                          },
                        ),
                        CustomDropdownItem(
                          icon: Icons.bookmark_border, // or Icons.save_alt
                          iconColor: Colors.black54,
                          label: 'Saved prompts',
                          onSelected: () {
                            // Handle saved prompts
                          },
                        ),
                        CustomDropdownItem(
                          icon: Icons.autorenew, // rotating arrows
                          iconColor: Colors.black54,
                          label: 'Change Model',
                          onSelected: () {
                            // Handle change model
                          },
                        ),
                        CustomDropdownItem(
                          icon: Icons.language,
                          iconColor: Colors.black54,
                          label: 'Change Language',
                          onSelected: () {
                            // Handle change language
                          },
                        ),
                      ],
                    ),

                    SizedBox(width: 8),

                    Text(
                      '${_controller.text.length}/2000',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),

                    CustomIconButton(
                      svgAsset: 'assets/icons/like.svg',
                      svgColor: Colors.blue,
                      toolTip: 'Like',
                      onPressed: () {
                        print('Liked!');
                      },
                    ),

                    Spacer(), // pushes the arrow to the far right

                    IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.arrow_forward),
                      color: Colors.teal,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                )

              ],
            ),
          ),

           SizedBox(height: 4),

          Padding(
            padding:  EdgeInsets.only(top: 5),
            child: Text(
              'Elysia responses may be inaccurate. Know more about how your data is processed here.',
              style: TextStyle(
                  fontSize: 12, color: Colors.grey
              ),
            ),
          )
        ],
      ),
    );

  }
}