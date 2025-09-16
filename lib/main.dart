import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplifyconfiguration.dart';
import 'features/auth/presentation/login.dart';
import 'features/auth/presentation/splash_screen.dart'; // ✅ Import splash screen
import 'widgets/global_appbar.dart';
import 'widgets/global_app_drawer.dart';
import 'infrastructure/theme/theme.dart';
import 'dart:developer' as developer;

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      final authPlugin = AmplifyAuthCognito();
      await Amplify.addPlugin(authPlugin);
      await Amplify.configure(amplifyconfig);
      setState(() {
        _isAmplifyConfigured = true;
      });
      developer.log('✅ Amplify configured successfully', name: 'Main');
    } on AmplifyAlreadyConfiguredException {
      developer.log('⚠ Amplify already configured.', name: 'Main');
    } catch (e) {
      developer.log('⚠ Amplify configuration error: $e', name: 'Main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final themeMode = ref.watch(themeModeProvider);
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Elysia',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: _isAmplifyConfigured
            ? const SplashScreen()
            : const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    });
  }
}

class MainLayout extends StatelessWidget {
  final Widget child;
  const MainLayout({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
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
