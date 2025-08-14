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
          leading: Icon(widget.leadingIcon, color: Colors.blue),
          title: Text(widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Colors.grey[600],
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
              return ListTile(
                dense: true,
                contentPadding:
                const EdgeInsets.only(left: 72, right: 16), // indent child
                title: Text(chatTitle,
                    style: const TextStyle(fontSize: 14, color: Colors.black87)),
                onTap: () {
                  // TODO: Open the chat
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
      ],
    );
  }
}
