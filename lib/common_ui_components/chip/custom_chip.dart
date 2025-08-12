import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const CustomChip({
    Key? key,
    required this.label,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey.shade200,
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onRemove,
    );
  }
}
