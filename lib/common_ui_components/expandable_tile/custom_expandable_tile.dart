import 'package:elysia/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/chat/application/chat_controller.dart';
import '../../../features/chat/data/models/chat_model.dart';

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

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  Future<void> _renameDialog(ChatHistory chat) async {
    final controller = TextEditingController(text: chat.title);
    final newTitle = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename chat'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (newTitle != null && newTitle.isNotEmpty) {
      await ref.read(chatHistoryProvider.notifier).renameChat(chat.sessionId, newTitle);
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
                        await ref.read(chatHistoryProvider.notifier).archiveChat(chat.sessionId, archived: true);
                      } else if (value == 'Unarchive') {
                        await ref.read(chatHistoryProvider.notifier).archiveChat(chat.sessionId, archived: false);
                      } else if (value == 'Rename') {
                        await _renameDialog(chat);
                      } else if (value == 'Delete') {
                        await ref.read(chatHistoryProvider.notifier).deleteChat(chat.sessionId);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: chat.isArchived ? 'Unarchive' : 'Archive',
                        child: Row(children: [
                          Icon(chat.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined, size: 18, color:  Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 8),
                          Text(chat.isArchived ? 'Unarchive' : 'Archive'),
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
                    ],
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