import 'package:flutter/material.dart';

/// A utility class that provides reusable notification methods
/// for displaying messages to the user.
class NotificationService {
  /// Shows a standard notification with customizable parameters
  static void showNotification(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: _getColorForType(type),
      duration: duration,
      action: action,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Shows a success notification
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showNotification(
      context,
      message: message,
      type: NotificationType.success,
      duration: duration,
      action: action,
    );
  }

  /// Shows an error notification
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    showNotification(
      context,
      message: message,
      type: NotificationType.error,
      duration: duration,
      action: action,
    );
  }

  /// Shows an info notification
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showNotification(
      context,
      message: message,
      type: NotificationType.info,
      duration: duration,
      action: action,
    );
  }

  /// Shows a warning notification
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showNotification(
      context,
      message: message,
      type: NotificationType.warning,
      duration: duration,
      action: action,
    );
  }

  /// Returns the appropriate color for the notification type
  static Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
      default:
        return Colors.blue;
    }
  }
}

/// Enum representing different types of notifications
enum NotificationType {
  success,
  error,
  warning,
  info,
}
