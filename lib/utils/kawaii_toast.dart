import 'package:flutter/material.dart';
import 'popup.dart';

/// KawaiiToast — pop-ups centrados y accesibles (mobile-first)
///
/// Reemplaza notificaciones tipo barra superior por una tarjeta
/// centrada con blur/sombra suave, icono y auto-cierre.
/// Usa Material 3 y cumple tamaños táctiles y Semantics.
class KawaiiToast {
  static void info(BuildContext context, String message) {
    Popup.show(
      context,
      type: PopupType.info,
      title: message,
      duration: const Duration(milliseconds: 2500),
    );
  }

  static void success(BuildContext context, String message) {
    Popup.show(
      context,
      type: PopupType.success,
      title: message,
      duration: const Duration(milliseconds: 2500),
    );
  }

  static void warn(BuildContext context, String message) {
    Popup.show(
      context,
      type: PopupType.warning,
      title: message,
      duration: const Duration(milliseconds: 2800),
    );
  }

  static void error(BuildContext context, String message) {
    Popup.show(
      context,
      type: PopupType.error,
      title: message,
      duration: const Duration(milliseconds: 3000),
    );
  }
}
