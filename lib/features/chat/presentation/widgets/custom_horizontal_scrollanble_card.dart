import 'package:flutter/material.dart';

class CustomHorizontalScrollableCard extends StatefulWidget {
  final List<String> items;
  const CustomHorizontalScrollableCard({super.key, required this.items});

  @override
  State<CustomHorizontalScrollableCard> createState() => _CustomHorizontalScrollableCardState();
}

class _CustomHorizontalScrollableCardState extends State<CustomHorizontalScrollableCard> {
  // Use a listener for the page controller to update the indicator
  final PageController _pageController = PageController(viewportFraction: 0.85); // Adjust this value for the card width
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
          height: 100, // Increased height for card + indicator
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            padEnds: false, // This is the key property to align to the left
            itemBuilder: (context, index) {
              return Container(
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
                    widget.items[index],
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
                color: _currentPage == index ? const Color(0xFFA4A4A4) : const Color(0xFFD9D9D9),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}