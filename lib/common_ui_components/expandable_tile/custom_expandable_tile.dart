import 'package:elysia/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/chat/data/models/chat_model.dart';
import '../../features/chat/application/chat_actions_controller.dart';
import '../../../features/chat/application/chat_controller.dart';
import '../dialog/bottom_drawer_options.dart';

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
  ConsumerState<CustomExpandableTile> createState() => _CustomExpandableTileState();
}

class _CustomExpandableTileState extends ConsumerState<CustomExpandableTile> {
  bool _isExpanded = false;
  final TextEditingController _renameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  Future<void> _renameDialog(ChatHistory chat) async {
    _renameController.text = chat.title;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            TextField(
              controller: _renameController,
              decoration: const InputDecoration(
                labelText: 'New name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      final newTitle = _renameController.text.trim();
      if (newTitle.isNotEmpty && newTitle != chat.title) {
        await ref.read(chatActionsControllerProvider.notifier).renameChat(chat.sessionId, newTitle);
        ref.read(chatHistoryProvider.notifier).updateTitle(chat.sessionId, newTitle);
      }
    }
  @override
  void dispose() {
    _renameController.dispose();
    super.dispose();
  }
  }

  Future<bool?> _deleteDialog(ChatHistory chat) async {
    return await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delete chat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Are you sure you want to delete the chat history?'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
              child: Icon(_isExpanded ? Icons.expand_more : Icons.arrow_forward_ios_outlined,
                  size: _isExpanded ? 25 : 15, color: Colors.grey[600]),
            ),
          ),
          title: Text(widget.title, style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: ColorConst.primaryBlack)
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
                  title: Text(chat.title, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                  trailing: PopupMenuButton<String>(
                    // color: Colors.white,
                    icon:  Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.onSurface),
                    onSelected: (value) async {
                      if (value == 'Archive') {
                        await ref.read(chatActionsControllerProvider.notifier).archiveChat(chat.sessionId);
                        ref.read(chatHistoryProvider.notifier).updateArchiveStatus(chat.sessionId);
                      } else if (value == 'Rename') {
                        await _renameDialog(chat);
                      } else if (value == 'Delete') {
                        final confirmed = await _deleteDialog(chat);
                        if (confirmed == true) {
                          await ref.read(chatActionsControllerProvider.notifier).deleteChat(chat.sessionId);
                          ref.read(chatHistoryProvider.notifier).deleteChat(chat.sessionId);
                        }
                      }
                    },
                    itemBuilder: (context) {
                      final isArchived = chat.isArchived == true;
                      return [
                        if (!isArchived)
                          PopupMenuItem(
                            value: 'Archive',
                            child: Row(children: [
                              Icon(Icons.archive_outlined, size: 18, color:  Theme.of(context).colorScheme.onSurface),
                              const SizedBox(width: 8),
                              Text('Archive'),
                            ]),
                          ),
                        PopupMenuItem(
                          value: 'Rename',
                          child: Row(children:  [
                            Icon(Icons.edit_outlined, size: 18, color: Theme.of(context).colorScheme.onSurface,),
                            SizedBox(width: 8),
                            Text('Rename'),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'Delete',
                          child: Row(children:  [
                            Icon(Icons.delete_outline, size: 18, color:  Theme.of(context).colorScheme.onSurface,),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ]),
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