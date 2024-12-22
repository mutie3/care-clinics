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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey[800]
                    : Colors.blue, // Dark mode background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.selectedValue ?? "Select Time",
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white
                          : Colors.white, // Light text in dark mode
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color:
                        isDarkMode ? Colors.white : Colors.white, // Icon color
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[850]
                      : Colors.white, // Dropdown background color
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                height: 100,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    Icon? leftArrow;
                    Icon? rightArrow;

                    if (index == 0) {
                      rightArrow = Icon(Icons.arrow_forward,
                          color: isDarkMode ? Colors.white : Colors.black);
                    } else if (index == widget.items.length - 1) {
                      leftArrow = Icon(Icons.arrow_back,
                          color: isDarkMode ? Colors.white : Colors.black);
                    } else {
                      leftArrow = Icon(Icons.arrow_back,
                          color: isDarkMode ? Colors.white : Colors.black);
                      rightArrow = Icon(Icons.arrow_forward,
                          color: isDarkMode ? Colors.white : Colors.black);
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
                          vertical: 10,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.blueGrey
                              : Colors.blueAccent, // Color in dropdown
                          borderRadius: BorderRadius.circular(10),
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
                            const SizedBox(width: 6),
                            Expanded(
                              child: Center(
                                child: Text(
                                  widget.items[index],
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.white, // Text color
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
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
