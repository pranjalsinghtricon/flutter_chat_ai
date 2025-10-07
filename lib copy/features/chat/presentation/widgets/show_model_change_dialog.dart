import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:elysia/features/chat/data/repositories/user_preferences_reposistory.dart';
import 'package:elysia/utiltities/core/storage.dart';
import 'package:elysia/common_ui_components/snackbar/custom_snackbar.dart';

void showModelChangeDialog(BuildContext context) {
  final UserPreferencesStorage _userPreferencesStorage = UserPreferencesStorage();
  bool isLoading = false;

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
          return FutureBuilder<List<Object?>>(
            future: Future.wait([
              _userPreferencesStorage.getSupportedModels(), // List<Map<String,dynamic>>
              _userPreferencesStorage.getPreferredModel(),  // String?
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Failed to load models'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No models found'));
              } else {
                // Cast properly
                final List<Map<String, dynamic>> models =
                    List<Map<String, dynamic>>.from(snapshot.data![0] as List);
                final String? preferredModel = snapshot.data![1] as String?;

                // Determine initial selection
                String selectedModel = preferredModel ??
                    (models.isNotEmpty ? models.first['name_of_model'] as String : "");

                return StatefulBuilder(
                  builder: (context, setState) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 4,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
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
                            "Choose model",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: ColorConst.primaryBlack,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 110,
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
                                  children: models.map((model) {
                                    final String displayName =
                                        model['display_name'] as String;
                                    final String nameOfModel =
                                        model['name_of_model'] as String;

                                    return RadioListTile<String>(
                                      value: nameOfModel,
                                      groupValue: selectedModel,
                                      title: Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                          color: ColorConst.primaryBlack,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: const VisualDensity(
                                        horizontal: -4,
                                        vertical: -2,
                                      ),
                                      dense: true,
                                      activeColor: Colors.black,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedModel = value!;
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
                                child: const Text(
                                  "Cancel",
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        setState(() => isLoading = true);

                                        try {
                                          // Save locally
                                          await _userPreferencesStorage
                                              .savePreferredModel(selectedModel);                                       

                                          // Save via API
                                          final repo = UserPreferencesRepository();
                                          final response =
                                              await repo.updateUserPreferencesFromApi(
                                            nameOfModel: selectedModel,
                                            responseLanguage:
                                                await _userPreferencesStorage
                                                        .getPreferredLanguage() ??
                                                    '',
                                          );
                                          if (response.isNotEmpty) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).clearSnackBars();
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: 'Your model has been updated!',
                                                  icon: Icons.check_circle_outline,
                                                );
                                              Navigator.pop(context);
                                            }
                                          } 
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).clearSnackBars();
                                            showCustomSnackBar(
                                              context: context,
                                              message: 'Failed to update model, please try again!',
                                              icon: Icons.error_outline,
                                            );
                                          }
                                        } finally {
                                          if (context.mounted) {
                                            setState(() => isLoading = false);
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B7CA2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
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
