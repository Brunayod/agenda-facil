import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../models/agendamento.dart';
import 'status_chip.dart';
import 'tipo_atendimento_icone.dart';

/// Card de um agendamento (consulta, exame, vacina ou receita).
/// O card inteiro (e a seta) é clicável.
class AgendamentoCard extends StatelessWidget {
  const AgendamentoCard({super.key, required this.agendamento, this.onTap});

  final Agendamento agendamento;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final a = agendamento;

    return Semantics(
      button: true,
      label: '${a.titulo}, ${a.unidade.nome}, ${a.dataFormatada} às '
          '${a.horaFormatada}, ${a.status.rotulo}. Toque para ver detalhes.',
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.bordaAgendamento),
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(a.tipo.icone),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(a.titulo, style: AppText.cardTitulo),
                                Text(
                                  a.unidade.nome,
                                  style: AppText.cardUnidade,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 66),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(AppAssets.icCalendario),
                          const SizedBox(width: 6),
                          Text(
                            '${a.dataFormatada}  ·  ${a.horaFormatada}',
                            style: AppText.cardData,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 52),
                      child: StatusChip(status: a.status),
                    ),
                  ],
                ),
              ),
              // Seta centralizada verticalmente em todo o card.
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(child: SvgPicture.asset(AppAssets.chevron)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
