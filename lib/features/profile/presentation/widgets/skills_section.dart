import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/chip/custom_chip.dart';
import 'package:flutter_chat_ai/common_ui_components/searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:flutter_chat_ai/providers/skill_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SkillsSection extends ConsumerWidget {
  const SkillsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSkills = ref.watch(selectedSkillsProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        const CustomSearchableDropdown(),
        ...selectedSkills.map((skill) => CustomChip(
          label: skill,
          onRemove: () {
            ref.read(selectedSkillsProvider.notifier).update((state) => state..remove(skill));
            ref.read(availableSkillsProvider.notifier).update((state) => [...state, skill]);
          },
        )),
      ],
    );
  }
}
