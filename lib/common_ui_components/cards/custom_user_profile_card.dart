import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/features/profile/application/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class CustomProfilePageCard extends ConsumerStatefulWidget {
  final String heading;
  final String subheading;
  final String? sectionKey;
  final String? initialAboutMeContent;
  final Widget? child;

  const CustomProfilePageCard({
    Key? key,
    required this.heading,
    required this.subheading,
    this.sectionKey,
    this.initialAboutMeContent,
    this.child,
  }) : super(key: key);

  @override
  ConsumerState<CustomProfilePageCard> createState() =>
      _CustomProfilePageCardState();
}

class _CustomProfilePageCardState extends ConsumerState<CustomProfilePageCard> {
  bool _isEditing = false;
  late TextEditingController _controller;

  String _optInValue = "Yes"; // default shown in card

  @override
  void initState() {
    super.initState();
    if (widget.sectionKey != null && widget.initialAboutMeContent != null) {
      final savedValue = ref.read(profileContentProvider)[widget.sectionKey] ??
          widget.initialAboutMeContent!;
      _controller = TextEditingController(text: savedValue);
    } else {
      _controller = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final savedValue =
    (widget.sectionKey != null && widget.initialAboutMeContent != null)
        ? ref.watch(profileContentProvider)[widget.sectionKey] ??
        widget.initialAboutMeContent!
        : null;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.blue, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.heading,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (widget.sectionKey != null &&
                    widget.initialAboutMeContent != null)
                  IconButton(
                    icon: Icon(
                      _isEditing ? Icons.close : Icons.edit,
                      color: Colors.grey[700],
                    ),
                    onPressed: () {
                      setState(() => _isEditing = !_isEditing);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Subheading
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.subheading,
                    style: const TextStyle(
                      fontSize: 13,
                      // color: Colors.
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Either child OR editable text
            if (widget.child != null)
              widget.child!
            else if (_isEditing)
              TextField(
                controller: _controller,
                maxLines: null,
                style: const TextStyle(fontSize: 14, height: 1.4),
              )
            else if (savedValue != null)
                Text(
                  savedValue,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),

            // Divider + Cancel/Save only in editing
            if (_isEditing && widget.sectionKey != null) ...[
              const Divider(height: 20, color: Colors.black26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                        _controller.text = savedValue ?? "";
                      });
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(profileContentProvider.notifier)
                          .updateSection(widget.sectionKey!, _controller.text);
                      setState(() => _isEditing = false);
                    },
                    child: const Text("Save"),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
