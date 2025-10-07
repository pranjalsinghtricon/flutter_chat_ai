import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Hardcoded skills initially (later could come from API)
final availableSkillsProvider = StateProvider<List<String>>(
  (ref) => [
    "End-to-end Automation",
    "TypeScript",
    "Python",
    "WordPress",
    "Proto.io",
    "AWS",
    "Figma",
    "Containerization",
    "CI/CD",
    ".NET Core",
    "Xamarin",
    "Flutter",
    "Clean code",
    "User Interface Design",
    "Native Android",
    "Java",
    "Kotlin",
    "iOS Development",
    "REST API",
    "Jenkins",
  ],
);

/// Load selected skills from Hive (persisted storage)
final selectedSkillsProvider = StateProvider<List<String>>((ref) {
  final box = Hive.box<String>(
    'skillBox',
  ); // ✅ using skillBox instead of profileBox
  final saved = box.get('skills');
  if (saved != null && saved.isNotEmpty) {
    return saved.split(",");
  }
  return [];
});

/// Controls edit mode
final isEditModeProvider = StateProvider<bool>((ref) => false);
