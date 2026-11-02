import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';

/// Linha "ícone em círculo + rótulo + valor" usada em detalhes e perfil.
class InfoLinha extends StatelessWidget {
  const InfoLinha({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.valor,
  });

  final IconData icone;
  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.azulOnda,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 20, color: AppColors.azulPrimario),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo, style: AppText.detalheRotulo),
                Text(valor, style: AppText.detalheValor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
