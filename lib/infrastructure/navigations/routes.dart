class Routes {
  static Future<String> get initialRoute async {
    // Here you could check if the user is logged in, etc.
    return LOGIN;
  }

  static const LOGIN = '/login';
  static const CHAT = '/chat';
}
