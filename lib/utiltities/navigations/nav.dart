import 'package:elysia/features/auth/presentation/login.dart';
import 'package:elysia/features/chat/presentation/screens/chat_screen.dart';
import 'package:elysia/utiltities/navigations/routes.dart';
import 'package:elysia/widgets/global_app_drawer.dart';
import 'package:elysia/widgets/global_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class Nav {
  static final router = GoRouter(
    initialLocation: Routes.LOGIN,
    routes: [
      GoRoute(
        path: Routes.LOGIN,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.CHAT,
        builder: (context, state) => const MainLayout(
          child: ChatScreen(),
        ),
      ),
    ],
  );
}

// ✅ reusable layout
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
