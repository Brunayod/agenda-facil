import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';

enum AbaAgenda { ativa, historico }

/// Alternador "Agenda ativa | Histórico".
class AbasAgenda extends StatelessWidget {
  const AbasAgenda({
    super.key,
    required this.selecionada,
    required this.onSelecionar,
  });

  final AbaAgenda selecionada;
  final ValueChanged<AbaAgenda> onSelecionar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Aba(
            rotulo: 'Agenda ativa',
            selecionada: selecionada == AbaAgenda.ativa,
            onTap: () => onSelecionar(AbaAgenda.ativa),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _Aba(
            rotulo: 'Histórico',
            selecionada: selecionada == AbaAgenda.historico,
            onTap: () => onSelecionar(AbaAgenda.historico),
          ),
        ),
      ],
    );
  }
}

class _Aba extends StatelessWidget {
  const _Aba({
    required this.rotulo,
    required this.selecionada,
    required this.onTap,
  });

  final String rotulo;
  final bool selecionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionada,
      label: rotulo,
      excludeSemantics: true,
      child: Material(
        color: selecionada ? AppColors.azulPrimario : AppColors.azulAbaInativa,
        shape: StadiumBorder(
          side: selecionada
              ? BorderSide.none
              : const BorderSide(color: AppColors.azulPrimario, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                rotulo,
                style: selecionada
                    ? AppText.abaTexto
                    : AppText.abaTextoInativa,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
