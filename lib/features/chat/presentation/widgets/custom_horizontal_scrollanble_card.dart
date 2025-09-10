import 'package:flutter/material.dart';

class CustomHorizontalScrollableCard extends StatefulWidget {
  final List<String> items;
  const CustomHorizontalScrollableCard({super.key, required this.items});

  @override
  State<CustomHorizontalScrollableCard> createState() =>
      _CustomHorizontalScrollableCardState();
}

class _CustomHorizontalScrollableCardState
    extends State<CustomHorizontalScrollableCard> {
  final PageController _pageController = PageController(viewportFraction: 0.7); // 1.5 cards visible
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 90, // taller so it looks like in screenshot
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08), // 8%
                        blurRadius: 14, // matches your screenshot
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.items[index],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index
                    ? Colors.black87
                    : Colors.grey.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
