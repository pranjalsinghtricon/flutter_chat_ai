class APIEndpoints {
	static const String archiveChat = '/chat/archive';
	static const String renameChat = '/chat/title:rename';
	static const String deleteChatSession = '/chat/conversation/session';
	static const String chatHistory = '/chat/users';
	static const String chatSessionMessages = '/chat/session';
	static const String chatStreamCompletion = '/chat/stream/completion';
	static const String getUserProfile = '/profile/self';
	static const String getSamplePrompts = '/chat/prompts/sample';
	static const String getLanguages = '/settings/languages';
	static const String getModels = '/settings/models';
	static const String getUserPreferences = '/settings/user';
	static const String updateUserPreferences = '/settings/user';
	static const String feedback = '/feedback/submit';
	static const String feedbackComment = '/feedback/comment';
	static const String deleteSavedPrompt = '/chat/prompt';
	static const String savedPrompts = '/chat/users';
}