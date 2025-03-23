// action_buttons.dart
import 'package:flutter/material.dart';

class ActionButton {
  final String label;
  final VoidCallback? onTap;
  final List<ActionOption>? options;

  ActionButton({required this.label, this.onTap, this.options});
}

class ActionOption {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  ActionOption({required this.label, required this.icon, required this.onTap});
}

class CategoryActions extends StatelessWidget {
  final String categoryTitle;
  final List<ActionButton> actions;

  const CategoryActions({
    Key? key,
    required this.categoryTitle,
    required this.actions,
  }) : super(key: key);

  void _showOptionsDialog(BuildContext context, List<ActionButton> actions) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                actions.map((action) {
                  return ListTile(
                    title: Text(action.label),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (action.options != null &&
                          action.options!.isNotEmpty) {
                        _showActionOptions(context, action);
                      } else if (action.onTap != null) {
                        action.onTap!();
                      }
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  void _showActionOptions(BuildContext context, ActionButton action) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  action.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...action.options!.map((option) {
                return ListTile(
                  leading: Icon(option.icon),
                  title: Text(option.label),
                  onTap: () {
                    Navigator.of(context).pop();
                    option.onTap();
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          categoryTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () => _showOptionsDialog(context, actions),
        ),
      ],
    );
  }
}

// Example of a scrollable category widget
class ScrollableCategoryList extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const ScrollableCategoryList({Key? key, required this.categories})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var category in categories)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CategoryActions(
                  categoryTitle: category['title'],
                  actions: category['actions'],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: category['items'].length,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemBuilder: (context, index) {
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text(category['items'][index])),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
      ],
    );
  }
}
