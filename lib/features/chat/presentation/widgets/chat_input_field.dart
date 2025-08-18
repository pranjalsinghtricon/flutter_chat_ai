import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/buttons/custom_icon_button.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_dropdown_item.dart';
import 'package:flutter_chat_ai/common_ui_components/dropdowns/custom_icon_dropdown.dart';
import 'package:flutter_chat_ai/features/chat/application/chat_controller.dart';
import 'package:flutter_chat_ai/features/chat/presentation/chat_screen.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/chat_screens/private_chat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatInputField extends ConsumerStatefulWidget {
  const ChatInputField({super.key});

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final _controller = TextEditingController();
  File? _attachedFile;   // <- stores attached file

  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty || _attachedFile != null) {
      ref.read(chatControllerProvider.notifier).sendMessage(text);
      _controller.clear();

      setState(() {
        _attachedFile = null; // clear file after sending
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachedFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [



          // ✅ Chat Input Container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (_attachedFile != null)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    margin: const EdgeInsets.only(left: 2.0, right: 2.0, top: 2.0, bottom: 4.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file, color: Colors.teal, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _attachedFile!.path.split('/').last, // file name
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.check_circle, color: Colors.green, size: 18),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 18),
                          onPressed: () {
                            setState(() {
                              _attachedFile = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),




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
                      assetPath: 'assets/icons/icon-chat-options.svg',
                      assetSize: 20,
                      iconColor: Colors.black54,
                      items: [
                        CustomDropdownItem(
                          assetPath: 'assets/icons/icon-private-chat.svg',
                          assetSize: 20,
                          iconColor: Colors.black54,
                          label: 'Private chat',
                          onSelected: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatScreen(isPrivate: true),
                              ),
                            );
                          },
                        ),
                        CustomDropdownItem(
                          assetPath: 'assets/icons/icon-paperclip.svg',
                          assetSize: 20,
                          label: 'Attach file',
                          iconColor: Colors.red,
                          onSelected: _pickFile,
                        ),
                        CustomDropdownItem(
                          assetPath: 'assets/icons/icon-google-document.svg',
                          assetSize: 20,
                          iconColor: Colors.red,
                          label: 'Add sources',
                          onSelected: () {},
                        ),
                        CustomDropdownItem(
                          assetPath: 'assets/icons/icon-google-bookmark.svg',
                          assetSize: 20,
                          iconColor: Colors.black54,
                          label: 'Saved prompts',
                          onSelected: () {},
                        ),
                        CustomDropdownItem(
                          assetPath: 'assets/icons/icon-change-model.svg',
                          assetSize: 20,
                          iconColor: Colors.black54,
                          label: 'Change model',
                          onSelected: () {},
                        ),
                        CustomDropdownItem(
                          assetPath: 'assets/icons/icon-language.svg',
                          assetSize: 20,
                          iconColor: Colors.black54,
                          label: 'Change language',
                          onSelected: () {},
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

                    Spacer(),

                    CustomIconButton(
                      svgAsset: 'assets/icons/icon-send.svg',
                      svgColor: Colors.teal,
                      toolTip: 'Send',
                      onPressed: _send,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 4),

          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              'Elysia responses may be inaccurate. Know more about how your data is processed here.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}
