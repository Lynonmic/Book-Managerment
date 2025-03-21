import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final Color? backgroundColor;
  final IconData icon;

  const FloatingButton({
    Key? key,
    required this.onPressed,
    this.tooltip = 'Add',
    this.backgroundColor,
    this.icon = Icons.add,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      child: Icon(icon, color: Colors.white),
    );
  }
}

class FloatingButtonExtended extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final String label;
  final Color? backgroundColor;
  final IconData icon;

  const FloatingButtonExtended({
    Key? key,
    required this.onPressed,
    required this.label,
    this.tooltip = 'Add',
    this.backgroundColor,
    this.icon = Icons.add,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
} 