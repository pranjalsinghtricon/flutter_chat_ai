import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elysia/features/chat/application/chat_controller.dart';

class CustomHorizontalScrollableCard extends StatefulWidget {
  final List<String> items;
  final WidgetRef ref; // 🔑 add ref
  const CustomHorizontalScrollableCard({super.key, required this.items, required this.ref});

  @override
  State<CustomHorizontalScrollableCard> createState() =>
      _CustomHorizontalScrollableCardState();
}

class _CustomHorizontalScrollableCardState extends State<CustomHorizontalScrollableCard> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int newPage = _pageController.page!.round();
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            padEnds: false,
            itemBuilder: (context, index) {
              final text = widget.items[index];
              return InkWell(
                onTap: () => widget.ref
                    .read(chatControllerProvider.notifier)
                    .sendMessage(text, widget.ref),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 10 : 8,
              height: _currentPage == index ? 10 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFFA4A4A4)
                    : const Color(0xFFD9D9D9),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}
