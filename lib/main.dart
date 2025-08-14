import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/chat/presentation/chat_screen.dart';

void main() {
  runApp(ProviderScope(child: ChatApp()));
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'ChatGPT ',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ChatScreen(),
    );
  }
}