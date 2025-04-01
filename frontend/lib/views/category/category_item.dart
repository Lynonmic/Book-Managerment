import 'package:flutter/material.dart';
import 'package:frontend/views/category/admin_category.dart';

class CategoryItem extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const CategoryItem({Key? key, required this.name, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left content with icon
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.category, color: Colors.grey[800]),
              ),
              SizedBox(width: 16),

              // Middle content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
