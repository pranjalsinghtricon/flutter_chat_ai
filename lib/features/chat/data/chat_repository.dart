import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../data/models/chat_model.dart';

class ChatRepository {
  static const String boxName = "chat_history";

  Future<List<ChatHistory>> fetchChatsFromApi() async {
    final response = await http.get(Uri.parse("http://demo6845203.mockable.io/conversation"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)["data"];

      List<ChatHistory> allChats = [];
      for (final section in ["today", "yesterday", "last_7_days", "last_30_days", "archived_chats"]) {
        for (var item in (data[section] as List)) {
          allChats.add(ChatHistory.fromJson(item));
        }
      }

      final box = await Hive.openBox<ChatHistory>(boxName);
      await box.clear();
      await box.addAll(allChats);

      return allChats;
    } else {
      throw Exception("Failed to load chats");
    }
  }

  Future<List<ChatHistory>> getLocalChats() async {
    final box = await Hive.openBox<ChatHistory>(boxName);
    return box.values.toList();
  }

  Future<void> addChat(ChatHistory chat) async {
    final box = await Hive.openBox<ChatHistory>(boxName);
    await box.add(chat);
  }
}
