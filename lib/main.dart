import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/chat/data/models/chat_model.dart';
import 'features/chat/data/models/message_model.dart';
import 'widgets/global_appbar.dart';
import 'widgets/global_app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ChatHistoryAdapter());
  Hive.registerAdapter(MessageAdapter());

  // Chat related boxes
  await Hive.openBox<ChatHistory>('chat_history');
  // Messages are stored per session in boxes named: messages_<sessionId>

  // Profile box for editable sections
  await Hive.openBox<String>('profileBox');

  runApp(const ProviderScope(child: ChatApp()));
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elysia',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainLayout(child: ChatScreen()),
    );
  }
}

class MainLayout extends ConsumerWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: GlobalAppBar(),
      ),
      drawer: const GlobalAppDrawer(),
      body: child,
    );
  }
}
