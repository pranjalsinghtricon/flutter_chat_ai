import 'package:elysia/features/chat/application/saved_prompt_controller.dart';
import 'package:elysia/utiltities/consts/asset_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

void showSavedPromptsBottomSheet(BuildContext context, TextEditingController textController) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SavedPromptsSheet(textController: textController),
  );
}

class SavedPromptsSheet extends ConsumerStatefulWidget {
  final TextEditingController textController;

  const SavedPromptsSheet({
    Key? key,
    required this.textController,
  }) : super(key: key);

  @override
  ConsumerState<SavedPromptsSheet> createState() => _SavedPromptsSheetState();
}

class _SavedPromptsSheetState extends ConsumerState<SavedPromptsSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(savedPromptControllerProvider.notifier).fetchSavedPrompts());
  }

  @override
  Widget build(BuildContext context) {
    final savedPromptsState = ref.watch(savedPromptControllerProvider);
    final TextEditingController _searchController = TextEditingController();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Saved Prompts title aligned left
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 1,
                ),
              ],
            ),
            child: const Text(
              'Saved Prompts',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Search box with padding
          // Container(
          //   margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          //   decoration: BoxDecoration(
          //     color: Colors.grey.shade100,
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: TextField(
          //     controller: _searchController,
          //     decoration: const InputDecoration(
          //       hintText: "search content",
          //       border: InputBorder.none,
          //       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          //     ),
          //     onChanged: (_) => setState(() {}),
          //   ),
          // ),

          // List of saved prompts
          Flexible(
            child: savedPromptsState.when(
              data: (prompts) {
                if (prompts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No saved prompts'),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: prompts.length,
                  itemBuilder: (context, index) {
                    final prompt = prompts[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: SvgPicture.asset(
                          AssetConsts.iconNewTopic,
                          width: 20,
                          height: 20,
                          color: const Color(0xFF525A5C),
                        ),
                        title: Text(
                          prompt.prompt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            try {
                              await ref.read(savedPromptControllerProvider.notifier).deletePrompt(prompt.promptId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Prompt deleted successfully')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting prompt: $e')),
                              );
                            }
                          },
                        ),
                        onTap: () {
                          widget.textController.text = prompt.prompt;
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
