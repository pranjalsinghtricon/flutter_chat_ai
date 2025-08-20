import 'package:hive/hive.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 0)
class ChatHistory extends HiveObject {
  @HiveField(0)
  String sessionId;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime updatedOn;

  @HiveField(3)
  bool isArchived;

  ChatHistory({
    required this.sessionId,
    required this.title,
    required this.updatedOn,
    this.isArchived = false,
  });

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      sessionId: json['session_id'],
      title: json['chat_history_title'],
      updatedOn: DateTime.parse(json['updated_on']),
      isArchived: json['is_archived'] ?? false,
    );
  }
}
