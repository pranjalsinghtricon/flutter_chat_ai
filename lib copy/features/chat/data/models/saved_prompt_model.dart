class SavedPrompt {
  final String createdOn;
  final String prompt;
  final int promptId;
  final String userId;

  SavedPrompt({
    required this.createdOn,
    required this.prompt,
    required this.promptId,
    required this.userId,
  });

  factory SavedPrompt.fromJson(Map<String, dynamic> json) {
    return SavedPrompt(
      createdOn: json['created_on'] as String,
      prompt: json['prompt'] as String,
      promptId: json['prompt_id'] as int,
      userId: json['user_id'] as String,
    );
  }
}
