import 'package:elysia/features/chat/data/repositories/chat_actions_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatActionsRepositoryProvider =
    Provider<ChatActionsRepository>((ref) => ChatActionsRepository());

final chatActionsControllerProvider =
    StateNotifierProvider<ChatActionsController, AsyncValue<String?>>((ref) {
  return ChatActionsController(ref.read(chatActionsRepositoryProvider));
});

class ChatActionsController extends StateNotifier<AsyncValue<String?>> {
  final ChatActionsRepository _repo;
  ChatActionsController(this._repo) : super(const AsyncValue.data(null));

  Future<void> archiveChat(String sessionId) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repo.archiveChat(sessionId: sessionId);
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> renameChat(String sessionId, String title) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repo.renameChat(sessionId: sessionId, title: title);
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteChat(String sessionId) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repo.deleteChatSession(sessionId: sessionId);
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
