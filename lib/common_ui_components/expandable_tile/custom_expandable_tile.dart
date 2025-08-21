import 'package:flutter/material.dart';

class CustomExpandableTile extends StatefulWidget {
  final String title;
  final IconData? leadingIcon;
  final List<String> items;
  final bool initiallyExpanded;

  const CustomExpandableTile({
    super.key,
    required this.title,
    this.leadingIcon,
    required this.items,
    this.initiallyExpanded = false,
  });

  @override
  State<CustomExpandableTile> createState() => _CustomExpandableTileState();
}

class _CustomExpandableTileState extends State<CustomExpandableTile> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
        ),

        if (_isExpanded)
          Column(
            children: widget.items.map((chatTitle) {
              return Container(
                color: Colors.white,
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 22, right: 8),
                  title: Text(
                    chatTitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  trailing: PopupMenuButton<String>(
                    color: Colors.white, // ✅ Makes popup menu background pure white
                    icon: const Icon(Icons.more_horiz, color: Colors.black87),
                    onSelected: (value) {
                      if (value == 'Archive') {
                        debugPrint("Archive $chatTitle");
                      } else if (value == 'Rename') {
                        debugPrint("Rename $chatTitle");
                      } else if (value == 'Delete') {
                        debugPrint("Delete $chatTitle");
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'Archive',
                        child: Row(
                          children: const [
                            Icon(Icons.archive_outlined, size: 18, color: Colors.black87),
                            SizedBox(width: 8),
                            Text('Archive'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Rename',
                        child: Row(
                          children: const [
                            Icon(Icons.edit_outlined, size: 18, color: Colors.black87),
                            SizedBox(width: 8),
                            Text('Rename'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Delete',
                        child: Row(
                          children: const [
                            Icon(Icons.delete_outline, size: 18, color: Colors.black87),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              );


            }).toList(),
          ),
      ],
    );
  }
}
