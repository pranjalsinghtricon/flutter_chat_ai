import 'package:hive/hive.dart';
part 'chat_model.g.dart';

@HiveType(typeId: 0)
class ChatHistory extends HiveObject {
  @override
  String toString() {
    return 'ChatHistory(sessionId: $sessionId, title: $title, updatedOn: $updatedOn, isArchived: $isArchived)';
  }
  
  @HiveField(0)
  final String sessionId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime updatedOn;

  @HiveField(3)
  final bool isArchived;

  ChatHistory({
    required this.sessionId,
    required this.title,
    required this.updatedOn,
    required this.isArchived,
  });

  ChatHistory copyWith({
    String? sessionId,
    String? title,
    DateTime? updatedOn,
    bool? isArchived,
  }) {
    return ChatHistory(
      sessionId: sessionId ?? this.sessionId,
      title: title ?? this.title,
      updatedOn: updatedOn ?? this.updatedOn,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      sessionId: json['session_id'] as String? ?? '',
      title: json['chat_history_title'] as String? ?? 'Untitled Chat',
      updatedOn: DateTime.tryParse(json['updated_on'] as String? ?? '') ?? DateTime.now(),
      isArchived: json['is_archived'] == true, // null or false → false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'chat_history_title': title,
      'updated_on': updatedOn.toIso8601String(),
      'is_archived': isArchived,
    };
  }
}
