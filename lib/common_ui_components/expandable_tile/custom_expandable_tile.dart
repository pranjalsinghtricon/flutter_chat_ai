import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/common_ui_components/snackbar/custom_snackbar.dart';

import '../../../features/chat/data/models/chat_model.dart';
import '../../features/chat/application/chat_actions_controller.dart';
import '../../../features/chat/application/chat_controller.dart';

class CustomExpandableTile extends ConsumerStatefulWidget {
  final String title;
  final List<ChatHistory> items;
  final void Function(ChatHistory) onTapItem;
  final bool initiallyExpanded;

  const CustomExpandableTile({
    super.key,
    required this.title,
    required this.items,
    required this.onTapItem,
    this.initiallyExpanded = false,
  });

  @override
  ConsumerState<CustomExpandableTile> createState() =>
      _CustomExpandableTileState();
}

class _CustomExpandableTileState extends ConsumerState<CustomExpandableTile> {
  bool _isExpanded = false;
  final TextEditingController _renameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }

  Future<void> _showRenameSheet(ChatHistory chat) async {
    _renameController.text = chat.title;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _renameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: "New name", 
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: ColorConst.primaryBlack,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: ColorConst.primaryColor, // active border color
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(
                          color: ColorConst.greyDivider,
                          width: 1,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: ColorConst.primaryBlack),
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: ColorConst.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Rename"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      final newTitle = _renameController.text.trim();
      if (newTitle.isNotEmpty && newTitle != chat.title) {
        try {
          await ref
              .read(chatActionsControllerProvider.notifier)
              .renameChat(chat.sessionId, newTitle);
          ref
              .read(chatHistoryProvider.notifier)
              .updateTitle(chat.sessionId, newTitle);
          
          // Use Future.delayed to ensure the bottom sheet is dismissed
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              showCustomSnackBar(
                context: context,
                message: 'Chat renamed',
                icon: Icons.edit_outlined,
              );
            }
          });
        } catch (e) {
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).clearSnackBars();
              showCustomSnackBar(
                context: context,
                message: 'Error renaming chat',
                icon: Icons.error_outline,
              );
            }
          });
        }
      }
    }
  }

  Future<void> _showDeleteSheet(ChatHistory chat) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Delete Chat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text("Are you sure, you want to delete this chat?"),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(
                          color: Color(0xFFDDDDDD),
                          width: 1,
                        ),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: ColorConst.primaryBlack),
                    ),
                  ),

                  // TextButton(
                  //   onPressed: () => Navigator.pop(context, false),
                  //   child: const Text("Cancel", style: TextStyle(color: ColorConst.primaryBlack),),
                  // ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Delete"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      try {
        await ref
            .read(chatActionsControllerProvider.notifier)
            .deleteChat(chat.sessionId);
        ref.read(chatHistoryProvider.notifier).deleteChat(chat.sessionId);
        
        // Use Future.delayed to ensure the bottom sheet is dismissed
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            showCustomSnackBar(
              context: context,
              message: 'Chat deleted',
              icon: Icons.delete_outlined,
            );
          }
        });
      } catch (e) {
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            showCustomSnackBar(
              context: context,
              message: 'Error deleting chat',
              icon: Icons.error_outline,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          leading: SizedBox(
            width: 25,
            height: 25,
            child: Center(
              child: Icon(
                _isExpanded
                    ? Icons.expand_more
                    : Icons.arrow_forward_ios_outlined,
                size: _isExpanded ? 25 : 15,
                color: Colors.grey[600],
              ),
            ),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: ColorConst.primaryBlack,
            ),
          ),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
        ),
        if (_isExpanded)
          Column(
            children: widget.items.map((chat) {
              return Container(
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 22, right: 8),
                  title: Text(
                    chat.title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ColorConst.primaryBlack,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onSelected: (value) async {
                      if (value == 'Archive') {
                        await ref
                            .read(chatActionsControllerProvider.notifier)
                            .archiveChat(chat.sessionId);
                        ref
                            .read(chatHistoryProvider.notifier)
                            .updateArchiveStatus(chat.sessionId);
                      } else if (value == 'Rename') {
                        await _showRenameSheet(chat);
                      } else if (value == 'Delete') {
                        await _showDeleteSheet(chat);
                      }
                    },
                    itemBuilder: (context) {
                      final isArchived = chat.isArchived == true;
                      return [
                        if (!isArchived)
                          PopupMenuItem(
                            value: 'Archive',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.archive_outlined,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                                const SizedBox(width: 8),
                                const Text('Archive'),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'Rename',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              const Text('Rename'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              const Text('Delete'),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                  onTap: () => widget.onTapItem(chat),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
