import 'package:flutter/material.dart';

class CategoryPills extends StatelessWidget {
  final List<String> categories;
  final String activeCategory;
  final Function(String)? onCategorySelected;

  const CategoryPills({
    super.key,
    required this.categories,
    required this.activeCategory,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories.map((category) {
              final isActive = category == activeCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    if (onCategorySelected != null) {
                      onCategorySelected!(category);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.purple[600] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
