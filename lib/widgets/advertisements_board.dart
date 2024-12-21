import 'dart:async';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class AdvertisementsBoard extends StatefulWidget {
  final List<Map<String, String>> advertisements;

  const AdvertisementsBoard({
    super.key,
    required this.advertisements,
  });

  @override
  _AdvertisementsBoardState createState() => _AdvertisementsBoardState();
}

class _AdvertisementsBoardState extends State<AdvertisementsBoard> {
  late final PageController _pageController;
  late final Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentPage < widget.advertisements.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      height: 200, // تصغير حجم الإعلان
      child: PageView.builder(
        itemCount: widget.advertisements.length,
        controller: _pageController,
        itemBuilder: (context, index) {
          final ad = widget.advertisements[index];
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) => Transform.scale(
              scale: 0.95,
              child: child,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // عرض الصورة مع FadeInImage
                    FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: AssetImage(ad['image']!),
                      fit: BoxFit.cover,
                    ),
                    // تدرج لوني فوق الصورة لجعل النصوص واضحة
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.2),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // النصوص فوق الصورة
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              ad['title']!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            ScrollingText(
                              text: ad['description']!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ScrollingText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  _ScrollingTextState createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Timer _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll < maxScroll) {
          _scrollController.animateTo(
            currentScroll + 2.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear,
          );
        } else {
          _scrollController.jumpTo(0);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}
