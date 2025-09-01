import 'package:flutter/material.dart';

class OptInScreen extends StatefulWidget {
  const OptInScreen({Key? key}) : super(key: key);

  @override
  State<OptInScreen> createState() => _OptInScreenState();
}

class _OptInScreenState extends State<OptInScreen> {
  String _selected = "No"; // default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment:  CrossAxisAlignment.center,
              children: [
                const Text(
                  "Opt In",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    // color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Back to Chat", style: TextStyle(color: Colors.black87, fontSize: 12),),
                ),
              ],
            ),
             Text(
              "To allow Elysia searching information about yourself, toggle on the Opt-In function. "
                  "This will allow Elysia to provide accurate information about you using internal sources "
                  "(like information uploaded to Elysia) or external sources (such as your LinkedIn account). "
                  "If you do not Opt-In your name will generally not appear in Elysia’s outputs. "
                  "You can Opt-Out from this feature at anytime.",
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Opt In",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            RadioListTile<String>(
              title: const Text("Yes"),
              value: "Yes",
              groupValue: _selected,
              onChanged: (value) {
                setState(() {
                  _selected = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text("No"),
              value: "No",
              groupValue: _selected,
              onChanged: (value) {
                setState(() {
                  _selected = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
