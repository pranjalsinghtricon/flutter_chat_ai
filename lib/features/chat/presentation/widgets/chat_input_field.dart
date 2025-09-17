import 'dart:io';
import 'package:elysia/features/chat/application/chat_controller.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
import 'package:elysia/features/chat/presentation/widgets/show_language_change_dialog.dart';
import 'package:elysia/features/chat/presentation/widgets/show_model_change_dialog.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/color_constants.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../common_ui_components/buttons/custom_icon_button.dart';
import '../../../../common_ui_components/dropdowns/custom_dropdown_item.dart';
import '../../../../common_ui_components/dropdowns/custom_icon_dropdown.dart';
import '../../../../main.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatInputField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  const ChatInputField({super.key, required this.controller});

  @override
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  File? _attachedFile;
  String _fileStatus = 'none';
  final ImagePicker _picker = ImagePicker();

  Future<void> _launchUrl() async {
    final url = Uri.parse('https://your-link.com');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _send() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty || _attachedFile != null) {
      ref.read(chatControllerProvider.notifier).sendMessage(text);
      widget.controller.clear();
      setState(() {
        _attachedFile = null;
        _fileStatus = 'none';
      });
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _attachedFile = file;
        _fileStatus = 'uploading';
      });
      // handle file upload status...
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _attachedFile = File(pickedFile.path);
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

  Future<void> captureImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _attachedFile = File(pickedFile.path);
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
    } catch (e) {
      debugPrint('Camera capture failed: $e');
    }
  }


  /// Capture new photo with camera
  // Future<void> captureImageFromCamera() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.camera);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _attachedFile = File(pickedFile.path);
  //       _fileStatus = 'uploading';
  //     });
  //
  //     Future.delayed(const Duration(seconds: 2), () {
  //       if (!mounted) return;
  //       setState(() => _fileStatus = 'uploaded');
  //       Future.delayed(const Duration(seconds: 1), () {
  //         if (!mounted) return;
  //         setState(() => _fileStatus = 'done');
  //       });
  //     });
  //   }
  // }

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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     border: Border.all(color: Colors.grey.shade300),
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Column(
              //     children: [
              //       if (_attachedFile != null)
              //         Container(
              //           height: 42,
              //           padding: const EdgeInsets.symmetric(horizontal: 10),
              //           margin: const EdgeInsets.only(
              //             left: 2.0,
              //             right: 2.0,
              //             top: 2.0,
              //             bottom: 4.0,
              //           ),
              //           decoration: BoxDecoration(
              //             border: Border.all(color: Colors.grey.shade300),
              //             borderRadius: BorderRadius.circular(6),
              //             color: Colors.white,
              //           ),
              //           child: Row(
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             children: [
              //               const Icon(
              //                 Icons.insert_drive_file,
              //                 color: Colors.teal,
              //                 size: 20,
              //               ),
              //               const SizedBox(width: 8),
              //               Expanded(
              //                 child: Text(
              //                   _attachedFile!.path.split('/').last,
              //                   style: const TextStyle(
              //                     fontSize: 14,
              //                     fontWeight: FontWeight.w500,
              //                   ),
              //                   overflow: TextOverflow.ellipsis,
              //                 ),
              //               ),
              //               _buildFileStatusWidget(),
              //             ],
              //           ),
              //         ),
              //       Container(
              //         alignment: Alignment.centerLeft,
              //         padding: const EdgeInsets.symmetric(
              //           vertical: 4.0,
              //           horizontal: 14.0,
              //         ),
              //         child: ConstrainedBox(
              //           constraints: const BoxConstraints(maxHeight: 120),
              //           child: Scrollbar(
              //             child: TextField(
              //               controller: widget.controller,
              //               maxLength: 2000,
              //               maxLines: null,
              //               onChanged: (_) => setState(() {}),
              //               onSubmitted: (_) => _send(),
              //               decoration: const InputDecoration(
              //                 hintText: 'Ask Elysia anything',
              //                 counterText: '',
              //                 border: InputBorder.none,
              //                 isDense: true,
              //               ),
              //               style: const TextStyle(fontSize: 14),
              //             ),
              //           ),
              //         ),
              //       ),
              //       Row(
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.only(left: 14.0),
              //             child: CustomIconDropdown(
              //               assetPath: AssetConsts.iconChatOptions,
              //               assetSize: 20,
              //               items: [
              //                 CustomDropdownItem(
              //                   assetPath: AssetConsts.iconPrivateChat,
              //                   assetSize: 20,
              //                   label: 'Private chat',
              //                   onSelected: () {
              //                     Navigator.push(
              //                       context,
              //                       MaterialPageRoute(
              //                         builder: (context) => const MainLayout(
              //                           child: ChatScreen(isPrivate: true),
              //                         ),
              //                       ),
              //                     );
              //                   },
              //                 ),
              //                 CustomDropdownItem(
              //                   assetPath: AssetConsts.iconPaperclip,
              //                   assetSize: 20,
              //                   label: 'Attach photo',
              //                   onSelected: _pickImageFromGallery,
              //                 ),
              //                 CustomDropdownItem(
              //                   assetPath: AssetConsts.iconGoogleDocument,
              //                   assetSize: 20,
              //                   label: 'Add sources',
              //                   onSelected: () {},
              //                 ),
              //                 CustomDropdownItem(
              //                   assetPath: AssetConsts.iconGoogleBookmark,
              //                   assetSize: 20,
              //                   label: 'Saved prompts',
              //                   onSelected: () {},
              //                 ),
              //                 CustomDropdownItem(
              //                   assetPath: AssetConsts.iconChangeModel,
              //                   assetSize: 20,
              //                   label: 'Change model',
              //                   onSelected: () =>
              //                       showModelChangeDialog(context),
              //                 ),
              //                 CustomDropdownItem(
              //                   assetPath: AssetConsts.iconLanguage,
              //                   assetSize: 20,
              //                   label: 'Change language',
              //                   onSelected: () =>
              //                       showLanguageChangeDialog(context),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           const Spacer(),
              //           Row(
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               if (widget.controller.text.isNotEmpty)
              //                 Padding(
              //                   padding: const EdgeInsets.only(right: 6),
              //                   child: Text(
              //                     '${widget.controller.text.length}/2000',
              //                     style: const TextStyle(
              //                       fontSize: 12,
              //                       color: ColorConst.primaryColor,
              //                     ),
              //                   ),
              //                 ),
              //               IconButton(
              //                 icon: const Icon(
              //                   Icons.camera_alt,
              //                   color: ColorConst.primaryColor,
              //                 ),
              //                 tooltip: "Open Camera",
              //                 onPressed: captureImageFromCamera,
              //               ),
              //               CustomIconButton(
              //                 svgAsset: AssetConsts.iconSend,
              //                 svgColor: ColorConst.primaryColor,
              //                 toolTip: 'Send',
              //                 onPressed: _send,
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 4),
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
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.grey),
                        onPressed: () => openBottomDrawer(context),
                        splashRadius: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: widget.controller,
                                maxLength: 2000,
                                maxLines: 1,
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) => _send(),
                                decoration: const InputDecoration(
                                  hintText: 'Ask anything...',
                                  border: InputBorder.none,
                                  counterText: '',
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.mic, color: Colors.grey),
                              onPressed: () {
                                // Add voice input logic
                              },
                              splashRadius: 20,
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorConst.primaryColor,
                              ),
                              child: CustomIconButton(
                                svgAsset: AssetConsts.iconSend,
                                toolTip: 'Send',
                                onPressed: _send,
                              ),
                              // IconButton(
                              //   icon: const Icon(Icons.graphic_eq, color: Colors.white),
                              //   onPressed: () {
                              //     // Add custom action
                              //   },
                              //   splashRadius: 20,
                              // ),


                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

void openBottomDrawer(BuildContext context) {
  final _state = context.findAncestorStateOfType<_ChatInputFieldState>();
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOption(
              icon: Icons.camera_alt_outlined,
              label: 'Camera',
              onTap: () {
                _state?.captureImageFromCamera();
              },
            ),
            _buildOption(
              icon: Icons.photo_outlined,
              label: 'Photos',
              onTap: () {
                _state?._pickImageFromGallery();
              },
            ),
            _buildOption(
              icon: Icons.attach_file,
              label: 'Attach Files',
              onTap: () {
                _state?.pickFile();
              },
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildOption({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 30, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}
