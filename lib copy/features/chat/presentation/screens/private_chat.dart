import 'package:elysia/utiltities/consts/color_constants.dart';
import 'package:flutter/material.dart';

class PrivateChatScreen extends StatelessWidget {
  const PrivateChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.6, // Give it explicit height
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        children: const [
          Text(
            "Private Chat",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: ColorConst.primaryColor
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Private Chat does not store history. All\n"
            "prompts and responses during the\n"
            "session stay unrecorded.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
