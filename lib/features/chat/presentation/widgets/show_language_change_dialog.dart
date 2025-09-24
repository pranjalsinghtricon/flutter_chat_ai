import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/common_ui_components/dialog/plain_alert_dialog.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:elysia/common_ui_components/dialog/bottom_drawer_options.dart';
import 'package:elysia/features/chat/data/repositories/user_preferences_reposistory.dart';
import 'package:elysia/utiltities/core/storage.dart';


void showLanguageChangeDialog(BuildContext context) {
  final UserPreferencesStorage _userPreferencesStorage = UserPreferencesStorage();
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, _) {
          return FutureBuilder<List<dynamic>>(
            future: Future.wait([
              _userPreferencesStorage.getSupportedLanguages(),
              _userPreferencesStorage.getPreferredLanguage(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Failed to load languages'));
              } else {
                final List<String> languages = snapshot.data?[0] ?? [];
                final String? preferredLanguage = snapshot.data?[1];
                String selectedLanguage = preferredLanguage ?? (languages.isNotEmpty ? languages.first : "");
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: SizedBox(
                              width: 40,
                              child: Divider(thickness: 3),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Choose Language",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ColorConst.primaryBlack),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 280,
                            child: ScrollbarTheme(
                              data: ScrollbarThemeData(
                                thumbColor: MaterialStateProperty.all(Color(0xFFDADADA)),
                                thickness: MaterialStateProperty.all(4),
                                radius: const Radius.circular(4),
                              ),
                              child: Scrollbar(
                                thumbVisibility: true,
                                interactive: true,
                                child: ListView(
                                  children: languages.map((lang) {
                                    return RadioListTile<String>(
                                      value: lang,
                                      groupValue: selectedLanguage,
                                      title: Text(lang,
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: ColorConst.primaryBlack)),
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
                                      dense: true,
                                      activeColor: Colors.black,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedLanguage = value!;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancel", style: TextStyle(color: Colors.black87)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  final repo = UserPreferencesRepository();
                                  await repo.updateUserPreferencesFromApi(
                                    nameOfModel: await _userPreferencesStorage.getPreferredModel() ?? '',
                                    responseLanguage: selectedLanguage,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B7CA2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "Save",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      );
    },
  );
}

void showChatBottomDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    builder: (context) {
      return BottomDrawerOptions(
        options: [
          BottomDrawerOption(
            icon: Icons.language,
            label: 'Change Language',
            onTap: () {
              Navigator.pop(context);
              showLanguageChangeDialog(context);
            },
          ),
        ],
      );
    },
  );
}
