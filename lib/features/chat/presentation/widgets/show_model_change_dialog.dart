import 'package:flutter/material.dart';
import 'package:flutter_chat_ai/common_ui_components/dialog/plain_alert_dialog.dart';

void showModelChangeDialog(BuildContext context) {
  String selectedModel = "Claude 3.7 Sonnet";

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return PlainAlertDialog(
            title: "Change Model",
            onClose: () => Navigator.pop(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedModel,
                  isExpanded: true,
                  items: [
                    "Claude 3.7 Sonnet",
                    "GPT-4",
                    "GPT-3.5",
                    "Llama 3.1"
                  ].map((String value) {
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        print("Model changed to: $selectedModel");
                        // 🔥 Hook into Riverpod/Controller here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
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
    },
  );
}
