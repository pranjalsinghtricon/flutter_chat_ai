// lib/features/profile/data/profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final profileBoxProvider = Provider<Box<String>>((ref) {
  return Hive.box<String>('profileBox');
});

final profileContentProvider =
    StateNotifierProvider<ProfileContentNotifier, Map<String, String>>((ref) {
      final box = ref.watch(profileBoxProvider);
      return ProfileContentNotifier(box);
    });

class ProfileContentNotifier extends StateNotifier<Map<String, String>> {
  final Box<String> box;

  ProfileContentNotifier(this.box)
    : super(Map<String, String>.from(box.toMap()));

  void updateSection(String key, String value) {
    box.put(key, value);
    state = Map<String, String>.from(box.toMap());
  }
}
