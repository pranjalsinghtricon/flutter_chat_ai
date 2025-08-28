class ChatEntity {
  final String sessionId;
  final String title;
  final DateTime updatedOn;
  final bool isArchived;

  ChatEntity({
    required this.sessionId,
    required this.title,
    required this.updatedOn,
    required this.isArchived,
  });
}
