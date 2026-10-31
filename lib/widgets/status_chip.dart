import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../models/agendamento.dart';

/// Chip de status: Confirmado / Realizado / Não compareceu / Cancelado.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final StatusAgendamento status;

  @override
  Widget build(BuildContext context) {
    final estilo = switch (status) {
      StatusAgendamento.confirmado => const _EstiloChip(
          fundo: AppColors.confirmadoFundo,
          texto: AppColors.confirmadoTexto,
          borda: AppColors.confirmadoBorda,
          icone: Icons.check,
        ),
      StatusAgendamento.realizado => const _EstiloChip(
          fundo: AppColors.realizadoFundo,
          texto: AppColors.realizadoTexto,
          icone: Icons.check,
        ),
      StatusAgendamento.naoCompareceu => const _EstiloChip(
          fundo: AppColors.naoCompareceuFundo,
          texto: AppColors.naoCompareceuTexto,
          icone: Icons.info_outline,
        ),
      StatusAgendamento.cancelado => const _EstiloChip(
          fundo: AppColors.canceladoFundo,
          texto: AppColors.canceladoTexto,
          icone: Icons.close,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: estilo.fundo,
        borderRadius: BorderRadius.circular(999),
        border: estilo.borda == null
            ? null
            : Border.all(color: estilo.borda!, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(estilo.icone, size: 16, color: estilo.texto),
          const SizedBox(width: 4),
          Text(status.rotulo, style: AppText.chip(estilo.texto)),
        ],
      ),
    );
  }
}

class _EstiloChip {
  const _EstiloChip({
    required this.fundo,
    required this.texto,
    required this.icone,
    this.borda,
  });

  final Color fundo;
  final Color texto;
  final Color? borda;
  final IconData icone;
}
