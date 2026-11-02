import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text.dart';

/// Decoração padrão dos campos de texto (fundo branco, borda azul clara).
abstract final class CampoDecoracao {
  static InputDecoration criar({
    String? rotulo,
    String? dica,
    String? erro,
    Widget? prefixo,
    Widget? sufixo,
    double raio = 16,
  }) {
    OutlineInputBorder borda(Color cor) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(raio),
          borderSide: BorderSide(color: cor, width: 2),
        );

    return InputDecoration(
      labelText: rotulo,
      hintText: dica,
      errorText: erro,
      labelStyle: AppText.campoRotulo,
      hintStyle: AppText.campoRotulo,
      errorStyle: AppText.campoErro,
      prefixIcon: prefixo,
      suffixIcon: sufixo,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: borda(AppColors.azulBordaCard),
      enabledBorder: borda(AppColors.azulBordaCard),
      focusedBorder: borda(AppColors.azulPrimario),
      errorBorder: borda(AppColors.canceladoTexto),
      focusedErrorBorder: borda(AppColors.canceladoTexto),
    );
  }
}
