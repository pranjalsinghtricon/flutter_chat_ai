import 'package:flutter_riverpod/flutter_riverpod.dart';

// Hardcoded for now, later from API
final availableSkillsProvider = StateProvider<List<String>>((ref) => [
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
  "Jenkins"
]);

final selectedSkillsProvider = StateProvider<List<String>>((ref) => []);
