import 'package:flutter/material.dart';
import 'package:elysia/common_ui_components/dialog/plain_alert_dialog.dart';
import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:elysia/features/chat/data/repositories/ai_model_repository.dart';

void showModelChangeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return FutureBuilder<List<String>>(
        future: ModelRepository().fetchModelsFromApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                color: ColorConst.primaryColor,
                strokeWidth: 2,
              ),
            ));
          } else if (snapshot.hasError) {
            return PlainAlertDialog(
              title: "Error",
              onClose: () => Navigator.pop(context),
              child: const Text("Failed to load models"),
            );
          } else {
            final models = snapshot.data ?? [];
            String selectedModel = models.isNotEmpty ? models[0] : "";

            return StatefulBuilder(
              builder: (context, setState) {
                return PlainAlertDialog(
                  title: "Change Model",
                  onClose: () => Navigator.pop(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButton<String>(
                          value: selectedModel,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: models.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedModel = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel", style: TextStyle(color: Colors.black87)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              print("Model changed to: $selectedModel");
                              // Hook into Riverpod/Controller here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConst.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Apply",
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
}
