import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../models/agendamento.dart';
import 'botao_app.dart';
import 'seletor_data_hora.dart';

/// BottomSheet para escolher uma nova data/horário de um agendamento.
abstract final class ReagendarSheet {
  /// Retorna a nova data/hora escolhida, ou `null` se o usuário desistir.
  static Future<DateTime?> mostrar(
    BuildContext context,
    Agendamento agendamento,
  ) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ConteudoReagendar(agendamento: agendamento),
    );
  }
}

class _ConteudoReagendar extends StatefulWidget {
  const _ConteudoReagendar({required this.agendamento});

  final Agendamento agendamento;

  @override
  State<_ConteudoReagendar> createState() => _ConteudoReagendarState();
}

class _ConteudoReagendarState extends State<_ConteudoReagendar> {
  DateTime? _nova;

  @override
  Widget build(BuildContext context) {
    final a = widget.agendamento;
    final inferior = MediaQuery.paddingOf(context).bottom;
    final altura = MediaQuery.sizeOf(context).height;
    final podeConfirmar = _nova != null && _nova != a.dataHora;

    return Container(
      constraints: BoxConstraints(maxHeight: altura * 0.92),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.iconeInativo,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reagendar', style: AppText.listaTitulo),
                  Text(
                    '${a.titulo} · ${a.unidade.nome}',
                    style: AppText.listaSubtitulo,
                  ),
                  Text(
                    'Atual: ${a.dataFormatada} às ${a.horaFormatada}',
                    style: AppText.formAjuda,
                  ),
                  const SizedBox(height: 16),
                  SeletorDataHora(
                    ignorarProtocolo: a.protocolo,
                    onChanged: (valor) => setState(() => _nova = valor),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + inferior),
            child: BotaoApp(
              rotulo: 'Confirmar novo horário',
              icone: Icons.event_available,
              onPressed:
                  podeConfirmar ? () => Navigator.of(context).pop(_nova) : null,
            ),
          ),
        ],
      ),
    );
  }
}
