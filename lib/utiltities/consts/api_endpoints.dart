class BASEURL {
	static const String baseUrl = 'https://stream-api-qa.iiris.com/v2/ai';
}

class APIEndpoints {
	static const String archiveChat = '${BASEURL.baseUrl}/chat/archive';
	static const String renameChat = '${BASEURL.baseUrl}/chat/title:rename';
	static const String deleteChatSession = '${BASEURL.baseUrl}/chat/conversation/session';
	static const String chatHistory = '${BASEURL.baseUrl}/chat/users';
	static const String chatSessionMessages = '${BASEURL.baseUrl}/chat/session';
	static const String chatStreamCompletion = '${BASEURL.baseUrl}/chat/stream/completion';
	static const String getUserProfile = '${BASEURL.baseUrl}/profile/self';
    static const String getSamplePrompts = '${BASEURL.baseUrl}/chat/prompts/sample';
	static const String getLanguages = '${BASEURL.baseUrl}/settings/languages';
	static const String getUserPreferences = '${BASEURL.baseUrl}/settings/user';
	static const String updateUserPreferences = '${BASEURL.baseUrl}/settings/user';
}