import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
import 'package:elysia/infrastructure/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/chat/data/models/chat_model.dart';
import 'features/chat/data/models/message_model.dart';
import 'widgets/global_appbar.dart';
import 'widgets/global_app_drawer.dart';
import 'dart:developer' as developer;
import 'amplifyconfiguration.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

Future<void> main() async {
  developer.log('🚀 Starting Elysia app...', name: 'Main');
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  Hive.registerAdapter(ChatHistoryAdapter());
  Hive.registerAdapter(MessageAdapter());
  await Hive.openBox<ChatHistory>('chat_history');
  await Hive.openBox<String>('profileBox');
  await Hive.openBox<String>('skillBox');

  await _configureAmplify();

  runApp(const ProviderScope(child: ChatApp()));
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);
    await Amplify.configure(amplifyconfig);
    developer.log('✅ Amplify configured successfully', name: 'Main');
  } on Exception catch (e) {
    developer.log('⚠ Amplify config error: $e', name: 'Main');
  }
}

class ChatApp extends ConsumerWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elysia',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
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
