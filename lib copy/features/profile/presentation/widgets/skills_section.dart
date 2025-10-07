import 'package:flutter/material.dart';
import 'package:elysia/common_ui_components/chip/custom_chip.dart';
import 'package:elysia/common_ui_components/searchable_dropdown/custom_searchable_multiselect_dropdown.dart';
import 'package:elysia/providers/skill_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SkillsSection extends ConsumerWidget {
  const SkillsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSkills = ref.watch(selectedSkillsProvider);
    final isEditMode = ref.watch(isEditModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with edit/save icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Skills",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(isEditMode ? Icons.check : Icons.edit),
              onPressed: () {
                if (isEditMode) {
                  // ✅ Save to Hive when user presses check
                  final box = Hive.box<String>('skillBox');
                  box.put('skills', selectedSkills.join(","));
                }
                ref.read(isEditModeProvider.notifier).state = !isEditMode;
              },
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Dropdown only in edit mode
        if (isEditMode) const CustomSearchableMultiselectDropdown(),

        // Selected skill chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedSkills.map((skill) {
            return CustomChip(
              label: skill,
              onRemove: () {
                ref
                    .read(selectedSkillsProvider.notifier)
                    .update((state) => state..remove(skill));
                ref
                    .read(availableSkillsProvider.notifier)
                    .update((state) => [...state, skill]);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
