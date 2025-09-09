import 'package:elysia/features/auth/presentation/login.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
import 'package:elysia/infrastructure/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/chat/data/models/chat_model.dart';
import 'features/chat/data/models/message_model.dart';
import 'widgets/global_appbar.dart';
import 'widgets/global_app_drawer.dart';
import 'dart:developer' as developer;

// ✅ Global navigator key used by aad_oauth
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void main() async {
  developer.log('🚀 Starting Elysia app...', name: 'Main');

  WidgetsFlutterBinding.ensureInitialized();

  developer.log('📦 Initializing Hive...', name: 'Main');
  await Hive.initFlutter();

  Hive.registerAdapter(ChatHistoryAdapter());
  Hive.registerAdapter(MessageAdapter());

  await Hive.openBox<ChatHistory>('chat_history');
  await Hive.openBox<String>('profileBox');
  await Hive.openBox<String>('skillBox');

  developer.log('✅ Hive initialized successfully', name: 'Main');
  developer.log('🎯 Launching app...', name: 'Main');

  runApp(const ProviderScope(child: ChatApp()));
}

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    developer.log('🎨 Building ChatApp', name: 'ChatApp');
    // home: const MainLayout(child: ChatScreen()),
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elysia',
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const LoginPage(),
      // home: const MainLayout(child: ChatScreen()),
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
