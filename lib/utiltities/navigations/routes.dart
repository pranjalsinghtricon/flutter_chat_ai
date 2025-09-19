import 'package:flutter/material.dart';
import 'package:elysia/features/auth/presentation/login.dart';
import 'package:elysia/features/auth/presentation/splash_screen.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
import 'package:elysia/main.dart';

class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String chat = '/chat';
  static const String home = '/home';
}

class AppRoutes {
  /// Centralized route table
  static final Map<String, WidgetBuilder> routes = {
    Routes.splash: (context) => const SplashScreen(),
    Routes.login: (context) => const LoginPage(),
    Routes.chat: (context) => const MainLayout(child: ChatScreen()),
    Routes.home: (context) => const MainLayout(child: ChatScreen()),
  };

  /// Optional: initial route
  static String initial = Routes.splash;
}
