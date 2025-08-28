import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/features/chat/application/chat_controller.dart';
import 'package:flutter_chat_ai/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/show_language_change_dialog.dart';
import 'package:flutter_chat_ai/features/chat/presentation/widgets/show_model_change_dialog.dart';
import 'package:flutter_chat_ai/infrastructure/consts/asset_consts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../common_ui_components/buttons/custom_icon_button.dart';
import '../../../../common_ui_components/dropdowns/custom_dropdown_item.dart';
import '../../../../common_ui_components/dropdowns/custom_icon_dropdown.dart';
import '../../../../main.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatInputField extends ConsumerStatefulWidget {
  const ChatInputField({super.key});

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  final _controller = TextEditingController();
  File? _attachedFile;
  String _fileStatus = 'none';

  Future<void> _launchUrl() async {
    final url = Uri.parse('https://your-link.com');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isNotEmpty || _attachedFile != null) {
      ref.read(chatControllerProvider.notifier).sendMessage(text);
      _controller.clear();
      setState(() {
        _attachedFile = null;
        _fileStatus = 'none';
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachedFile = File(result.files.single.path!);
        _fileStatus = 'uploading';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _fileStatus = 'uploaded');
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() => _fileStatus = 'done');
        });
      });
    }
  }

  Widget _buildFileStatusWidget() {
    Widget icon;
    switch (_fileStatus) {
      case 'uploading':
        icon = const Icon(Icons.hourglass_top, color: Colors.grey, size: 18);
        break;
      case 'uploaded':
        icon = const Icon(Icons.check_circle, color: Colors.green, size: 18);
        break;
      case 'done':
        icon = GestureDetector(
          onTap: () => setState(() {
            _attachedFile = null;
            _fileStatus = 'none';
          }),
          child: const Icon(Icons.close, color: Colors.red, size: 18),
        );
        break;
      default:
        icon = const Icon(
          Icons.insert_drive_file,
          color: Colors.teal,
          size: 20,
        );
    }

    return SizedBox(width: 24, height: 24, child: Center(child: icon));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                if (_attachedFile != null)
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: const EdgeInsets.only(
                      left: 2.0,
                      right: 2.0,
                      top: 2.0,
                      bottom: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.insert_drive_file,
                          color: Colors.teal,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _attachedFile!.path.split('/').last,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildFileStatusWidget(),
                      ],
                    ),
                  ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 14.0,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
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
                      assetPath: AssetConsts.iconChatOptions,
                      assetSize: 20,
                      iconColor: Colors.black54,
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
                          label: 'Attach file',
                          iconColor: Colors.red,
                          onSelected: _pickFile,
                        ),
                        CustomDropdownItem(
                          assetPath: AssetConsts.iconGoogleDocument,
                          assetSize: 20,
                          iconColor: Colors.red,
                          label: 'Add sources',
                          onSelected: () {},
                        ),
                        CustomDropdownItem(
                          assetPath: AssetConsts.iconGoogleBookmark,
                          assetSize: 20,
                          iconColor: Colors.black54,
                          label: 'Saved prompts',
                          onSelected: () {},
                        ),
                        CustomDropdownItem(
                          assetPath: AssetConsts.iconChangeModel,
                          assetSize: 20,
                          iconColor: Colors.black54,
                          label: 'Change model',
                          onSelected: () => showModelChangeDialog(context),
                        ),
                        CustomDropdownItem(
                          assetPath: AssetConsts.iconLanguage,
                          assetSize: 20,
                          iconColor: Colors.black54,
                          label: 'Change language',
                          onSelected: () => showLanguageChangeDialog(context),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${_controller.text.length}/2000',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ColorConst.primaryColor,
                      ),
                    ),
                    CustomIconButton(
                      svgAsset: AssetConsts.iconSend,
                      svgColor: ColorConst.primaryColor,
                      toolTip: 'Send',
                      onPressed: _send,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                children: [
                  const TextSpan(
                    text:
                        'Elysia responses may be inaccurate. Know more about how your data is processed ',
                  ),
                  TextSpan(
                    text: 'here',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _launchUrl,
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
