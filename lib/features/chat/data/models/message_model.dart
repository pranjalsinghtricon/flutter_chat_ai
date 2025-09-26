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

  @HiveField(5)
  final bool isGenerating;

  @HiveField(6)
  final String? runId; // Add this field for feedback API
    
  @HiveField(7)
  final String? readAloudLanguage;

  @HiveField(8)
  final bool isPrivate;

  Message({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.isUser,
    required this.createdAt,
    this.isGenerating = false,
    this.runId,
    this.readAloudLanguage,
    this.isPrivate = false,
  });

  Message copyWith({
    String? id,
    String? sessionId,
    String? content,
    bool? isUser,
    DateTime? createdAt,
    bool? isGenerating,
    String? runId,
    String? readAloudLanguage,
    bool? isPrivate,
  }) {
    return Message(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      isGenerating: isGenerating ?? this.isGenerating,
      runId: runId ?? this.runId,
      readAloudLanguage: readAloudLanguage ?? this.readAloudLanguage,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  /// Factory to create a Message object from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: (json['id'] ?? '') as String,
      sessionId: (json['sessionId'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      isUser: (json['isUser'] ?? false) as bool,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isGenerating: json['isGenerating'] as bool? ?? false,
      runId: json['runId'] as String?, // Add this line
      readAloudLanguage: json['readAloudLanguage'] as String?,
    );
  }

  /// Convert Message object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'content': content,
      'isUser': isUser,
      'createdAt': createdAt.toIso8601String(),
      'isGenerating': isGenerating,
      'runId': runId, 
      'readAloudLanguage': readAloudLanguage,
      'private_chat': isPrivate,
    };
  }
}