import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class KawaiiToast {
  static void info(String message, {IconData icon = Icons.info_outline}) {
    showSimpleNotification(
      Text(message),
      background: Colors.white,
      foreground: Colors.brown,
      leading: Icon(icon, color: Colors.brown),
      position: NotificationPosition.top,
      autoDismiss: true,
      slideDismiss: true,
      duration: const Duration(seconds: 3),
    );
  }

  static void success(String message, {IconData icon = Icons.check_circle}) {
    showSimpleNotification(
      Text(message),
      background: const Color(0xFFFFF4DA),
      foreground: Colors.brown,
      leading: const Text('🧀', style: TextStyle(fontSize: 18)),
      trailing: Icon(icon, color: Colors.green.shade600),
      position: NotificationPosition.top,
      autoDismiss: true,
      slideDismiss: true,
      duration: const Duration(seconds: 3),
    );
  }

  static void warn(String message, {IconData icon = Icons.warning_amber_rounded}) {
    showSimpleNotification(
      Text(message),
      background: Colors.yellow.shade100,
      foreground: Colors.brown,
      leading: Icon(icon, color: Colors.orange.shade700),
      position: NotificationPosition.top,
      autoDismiss: true,
      slideDismiss: true,
      duration: const Duration(seconds: 4),
    );
  }

  static void error(String message, {IconData icon = Icons.error_outline}) {
    showSimpleNotification(
      Text(message),
      background: Colors.white,
      foreground: Colors.brown,
      leading: Icon(icon, color: Colors.red.shade600),
      position: NotificationPosition.top,
      autoDismiss: true,
      slideDismiss: true,
      duration: const Duration(seconds: 4),
    );
  }
}

