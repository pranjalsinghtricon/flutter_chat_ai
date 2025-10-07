import 'package:flutter/material.dart';

class SocialNetworkScreen extends StatefulWidget {
  const SocialNetworkScreen({Key? key}) : super(key: key);

  @override
  State<SocialNetworkScreen> createState() => _SocialNetworkScreenState();
}

class _SocialNetworkScreenState extends State<SocialNetworkScreen> {
  final TextEditingController _controller = TextEditingController(
    text: "LinkedIn",
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Social Networks",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Back to Chat",
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                ),
              ),
            ],
          ),
          const Text(
            "You can add your social media accounts (e.g. LinkedIn) to improve the accuracy and quality of the "
            "responses about yourself. If you sync your account, Elysia will consult the linked account to enhance "
            "some sections of your profile (eg completing fields like 'About', 'Skills' and 'Interests'), and it will "
            "consult the information in your synced account where necessary to improve responses about whether you or "
            "whose expertise matches with the object of the request made by another colleague. You can remove the synced "
            "account at any time and Elysia will no longer retrieve information from the synced account.",
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // Heading
          const Text(
            "Social Networks",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Enter Social Network",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    _controller.text,
                  ); // return updated value
                },
                child: const Text("Update profile"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
