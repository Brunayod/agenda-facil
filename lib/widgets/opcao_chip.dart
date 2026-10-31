import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';

/// Chip selecionável (serviço, horário...). Desabilitado = indisponível.
class OpcaoChip extends StatelessWidget {
  const OpcaoChip({
    super.key,
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
    this.habilitado = true,
  });

  final String rotulo;
  final bool selecionado;
  final VoidCallback onTap;
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final fundo = !habilitado
        ? AppColors.fundo
        : (selecionado ? AppColors.azulPrimario : Colors.white);
    final corTexto = !habilitado
        ? AppColors.iconeInativo
        : (selecionado ? Colors.white : AppColors.azulTexto);
    final borda = (!habilitado || selecionado)
        ? BorderSide.none
        : const BorderSide(color: AppColors.azulPrimario, width: 1.5);

    final estiloTexto = AppText.opcao(
      corTexto,
      peso: selecionado ? FontWeight.w600 : FontWeight.w500,
    );

    return Semantics(
      button: true,
      selected: selecionado,
      enabled: habilitado,
      label: habilitado ? rotulo : '$rotulo, indisponível',
      excludeSemantics: true,
      child: Material(
        color: fundo,
        clipBehavior: Clip.antiAlias,
        shape: StadiumBorder(side: borda),
        child: InkWell(
          onTap: habilitado ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            child: Text(
              rotulo,
              style: habilitado
                  ? estiloTexto
                  : estiloTexto.copyWith(decoration: TextDecoration.lineThrough),
            ),
          ),
        ),
      ),
    );
  }
}
