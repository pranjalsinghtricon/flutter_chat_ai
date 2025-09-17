import 'package:hive/hive.dart';
part 'message_model.g.dart';

@HiveType(typeId: 1)
class Message extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String sessionId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final bool isUser;

  @HiveField(4)
  final DateTime createdAt;

  Message({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.isUser,
    required this.createdAt,
  });

  Message copyWith({
    String? id,
    String? sessionId,
    String? content,
    bool? isUser,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: (json['id'] ?? '') as String,
      sessionId: (json['sessionId'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      isUser: (json['isUser'] ?? false) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'content': content,
      'isUser': isUser,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
