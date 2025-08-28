import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/providers/skill_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomSearchableMultiselectDropdown extends ConsumerStatefulWidget {
  const CustomSearchableMultiselectDropdown({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomSearchableMultiselectDropdown> createState() =>
      _CustomSearchableMultiselectDropdownState();
}

class _CustomSearchableMultiselectDropdownState
    extends ConsumerState<CustomSearchableMultiselectDropdown> {
  String searchQuery = '';
  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    final availableSkills = ref.watch(availableSkillsProvider);
    final selectedSkills = ref.watch(selectedSkillsProvider);

    // Filtered skills
    final filteredSkills = availableSkills
        .where((skill) =>
        skill.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Field
        TextField(
          decoration: InputDecoration(
            hintText: 'Type a skill to add',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              isDropdownOpen = true;
            });
          },
          onTap: () {
            setState(() => isDropdownOpen = true);
          },
        ),
        const SizedBox(height: 8),

        // Dropdown List with Checkboxes
        if (isDropdownOpen && filteredSkills.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredSkills.length,
              itemBuilder: (context, index) {
                final skill = filteredSkills[index];
                final isSelected = selectedSkills.contains(skill);

                return CheckboxListTile(
                  title: Text(skill),
                  value: isSelected,
                  onChanged: (checked) {
                    if (checked == true) {
                      ref.read(selectedSkillsProvider.notifier)
                          .update((state) => [...state, skill]);
                      ref.read(availableSkillsProvider.notifier)
                          .update((state) => state..remove(skill));
                    } else {
                      ref.read(selectedSkillsProvider.notifier)
                          .update((state) => state..remove(skill));
                      ref.read(availableSkillsProvider.notifier)
                          .update((state) => [...state, skill]);
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
