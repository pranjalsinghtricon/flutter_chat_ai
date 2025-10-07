import 'package:flutter/material.dart';
import 'package:elysia/providers/skill_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomSearchableDropdown extends ConsumerStatefulWidget {
  const CustomSearchableDropdown({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomSearchableDropdown> createState() =>
      _CustomSearchableDropdownState();
}

class _CustomSearchableDropdownState
    extends ConsumerState<CustomSearchableDropdown> {
  String searchQuery = '';
  bool isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    final availableSkills = ref.watch(availableSkillsProvider);

    // Filtered skills
    final filteredSkills = availableSkills
        .where(
          (skill) => skill.toLowerCase().contains(searchQuery.toLowerCase()),
        )
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
              isDropdownOpen = true; // open dropdown when user starts typing
            });
          },
          onTap: () {
            setState(() {
              isDropdownOpen =
                  !isDropdownOpen; // toggle dropdown when clicking in search
            });
          },
        ),
        const SizedBox(height: 8),

        // Dropdown List
        if (isDropdownOpen && filteredSkills.isNotEmpty)
          Container(
            constraints: const BoxConstraints(
              maxHeight: 200, // height for 3-4 items approx.
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredSkills.length,
                itemBuilder: (context, index) {
                  final skill = filteredSkills[index];
                  return ListTile(
                    title: Text(skill),
                    onTap: () {
                      // Move to selected list
                      ref
                          .read(selectedSkillsProvider.notifier)
                          .update((state) => [...state, skill]);
                      ref
                          .read(availableSkillsProvider.notifier)
                          .update((state) => state..remove(skill));
                      setState(() {
                        searchQuery = '';
                        isDropdownOpen = false; // close after selection
                      });
                    },
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
