import 'package:flutter/material.dart';

class NavigationDots extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int)? onPageSelected;

  const NavigationDots({
    super.key,
    required this.currentPage,
    this.totalPages = 3,
    this.onPageSelected,
  });

  void _showOptionsDialog(BuildContext context, int pageIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Navigation Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.navigate_next),
                title: Text("Go to this page"),
                onTap: () {
                  Navigator.of(context).pop();
                  if (onPageSelected != null) {
                    onPageSelected!(pageIndex);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Edit page content"),
                onTap: () {
                  Navigator.of(context).pop();
                  // Add your edit page content logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Edit page ${pageIndex + 1} content"),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return GestureDetector(
          onTap: () => _showOptionsDialog(context, index),
          child: Container(
            width: index == currentPage ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == currentPage ? Colors.black : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
