class MessageEntity {
  final String id;
  final String sessionId;
  final String content;
  final bool isUser;
  final DateTime createdAt;

  MessageEntity({
    required this.id,
    required this.sessionId,
    required this.content,
    required this.isUser,
    required this.createdAt,
  });
}
