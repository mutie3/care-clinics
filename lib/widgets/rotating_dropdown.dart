import 'package:flutter/material.dart';

class RotatingDropdown extends StatefulWidget {
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const RotatingDropdown({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
  });

  @override
  RotatingDropdownState createState() => RotatingDropdownState();
}

class RotatingDropdownState extends State<RotatingDropdown> {
  bool _isExpanded = false;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Center(
      // Center the dropdown in the middle of the page
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10), // Smaller padding
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8), // Smaller radius
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.selectedValue ?? "Select Time",
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16), // Smaller font size
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                height: 100, // Smaller height for dropdown
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    // Determine the arrows based on the index
                    Icon? leftArrow;
                    Icon? rightArrow;

                    if (index == 0) {
                      rightArrow =
                          const Icon(Icons.arrow_forward, color: Colors.white);
                    } else if (index == widget.items.length - 1) {
                      leftArrow =
                          const Icon(Icons.arrow_back, color: Colors.white);
                    } else {
                      leftArrow =
                          const Icon(Icons.arrow_back, color: Colors.white);
                      rightArrow =
                          const Icon(Icons.arrow_forward, color: Colors.white);
                    }

                    return GestureDetector(
                      onTap: () {
                        widget.onChanged(widget.items[index]);
                        setState(() {
                          _isExpanded = false;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10, // Reduced vertical padding
                          horizontal: 14, // Reduced horizontal padding
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius:
                              BorderRadius.circular(10), // Smaller corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (leftArrow != null) leftArrow,
                            const SizedBox(
                                width: 6), // Space between icon and text
                            Expanded(
                              child: Center(
                                child: Text(
                                  widget.items[index],
                                  style: const TextStyle(
                                    fontSize: 18, // Smaller font size
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing:
                                        1.2, // Reduced letter spacing
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            if (rightArrow != null) rightArrow,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
