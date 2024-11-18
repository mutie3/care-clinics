import 'package:flutter/material.dart';

class CategoryGrid extends StatelessWidget {
  final List<String> categoryNames;
  final List<IconData> icons;
  final int selectedIndex;
  final Function(int) onCategoryTap;

  const CategoryGrid({
    super.key,
    required this.categoryNames,
    required this.icons,
    required this.selectedIndex,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
      ),
      itemCount: categoryNames.length,
      itemBuilder: (context, index) {
        bool isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onCategoryTap(index),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue[700] : Colors.blue[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icons[index],
                  color: isSelected ? Colors.white : Colors.blue[700],
                ),
                const SizedBox(height: 8),
                Text(
                  categoryNames[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
