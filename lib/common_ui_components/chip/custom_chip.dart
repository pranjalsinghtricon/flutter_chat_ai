import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ai/providers/skill_provider.dart';

class CustomChip extends ConsumerWidget {
  final String label;
  final VoidCallback onRemove;

  const CustomChip({
    Key? key,
    required this.label,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = ref.watch(isEditModeProvider);

    return Chip(
      label: Text(label),
      backgroundColor: Colors.grey.shade200,
      deleteIcon: isEditMode ? const Icon(Icons.close, size: 18) : null,
      onDeleted: isEditMode ? onRemove : null,
    );
  }
}
