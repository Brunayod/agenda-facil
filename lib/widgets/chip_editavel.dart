import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';

/// Chip com botão "x" para remover (alergias, condições...).
class ChipEditavel extends StatelessWidget {
  const ChipEditavel({super.key, required this.rotulo, required this.onRemover});

  final String rotulo;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 14),
      decoration: BoxDecoration(
        color: AppColors.azulAbaInativa,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.azulPrimario, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(rotulo, style: AppText.opcao(AppColors.azulTexto)),
          Semantics(
            button: true,
            label: 'Remover $rotulo',
            excludeSemantics: true,
            child: InkResponse(
              onTap: onRemover,
              radius: 20,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, size: 16, color: AppColors.azulTexto),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip "+ Adicionar" que acompanha uma lista de [ChipEditavel].
class ChipAdicionar extends StatelessWidget {
  const ChipAdicionar({super.key, required this.onTap, this.rotulo = 'Adicionar'});

  final VoidCallback onTap;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: rotulo,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.azulPrimario, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, size: 16, color: AppColors.azulPrimario),
                const SizedBox(width: 4),
                Text(rotulo, style: AppText.opcao(AppColors.azulPrimario)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
