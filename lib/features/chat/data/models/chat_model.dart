import 'package:hive/hive.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 0)
class ChatHistory extends HiveObject {
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

  /// ✅ copyWith for updates
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

  /// ✅ fromJson / toJson for API
  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      sessionId: json['sessionId'] as String,
      title: json['title'] as String,
      updatedOn: DateTime.parse(json['updatedOn'] as String),
      isArchived: json['isArchived'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'title': title,
      'updatedOn': updatedOn.toIso8601String(),
      'isArchived': isArchived,
    };
  }
}
