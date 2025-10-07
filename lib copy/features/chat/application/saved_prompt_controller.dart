import 'package:elysia/features/chat/data/models/saved_prompt_model.dart';
import 'package:elysia/features/chat/data/repositories/saved_prompt_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final savedPromptRepositoryProvider = Provider<SavedPromptRepository>(
  (ref) => SavedPromptRepository(),
);

final savedPromptControllerProvider =
    StateNotifierProvider<SavedPromptController, AsyncValue<List<SavedPrompt>>>(
  (ref) => SavedPromptController(ref.read(savedPromptRepositoryProvider)),
);

class SavedPromptController extends StateNotifier<AsyncValue<List<SavedPrompt>>> {
  final SavedPromptRepository _repository;

  SavedPromptController(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchSavedPrompts() async {
    try {
      state = const AsyncValue.loading();
      final prompts = await _repository.fetchSavedPrompts();
      state = AsyncValue.data(prompts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> savePrompt(String prompt) async {
    try {
      await _repository.savePrompt(prompt);
      // Refresh the prompts list after successful save
      await fetchSavedPrompts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePrompt(int promptId) async {
    try {
      await _repository.deletePrompt(promptId);
      // Refresh the prompts list after successful deletion
      await fetchSavedPrompts();
    } catch (e) {
      rethrow;
    }
  }
}
