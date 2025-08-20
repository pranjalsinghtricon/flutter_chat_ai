class Message {
  final String id;
  final String content;
  final bool isUser;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
  });

  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
    );
  }
}
