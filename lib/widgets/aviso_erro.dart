import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';

/// Faixa vermelha clara com ícone, usada para erros gerais de formulário
/// (ex.: "CPF ou senha incorretos").
class AvisoErro extends StatelessWidget {
  const AvisoErro({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.canceladoFundo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              size: 20,
              color: AppColors.canceladoTexto,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                texto,
                style: AppText.opcao(
                  AppColors.canceladoTexto,
                  peso: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
