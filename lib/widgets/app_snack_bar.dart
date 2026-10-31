import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';

/// SnackBar padrão do app (flutuante, acima da barra de navegação).
///
/// Recebe o [ScaffoldMessengerState] em vez do context para poder ser usado
/// depois de fechar telas/modais (capture-o antes do `await`).
abstract final class AppSnackBar {
  static void mostrar(
    ScaffoldMessengerState messenger,
    String texto, {
    IconData icone = Icons.check_circle_outline,
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          backgroundColor: AppColors.azulEscuro,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(icone, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(texto, style: AppText.snack)),
            ],
          ),
        ),
      );
  }
}
