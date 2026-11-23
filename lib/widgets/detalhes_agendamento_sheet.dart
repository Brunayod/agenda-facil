import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../data/agendamento_repository.dart';
import '../data/erros.dart';
import '../models/agendamento.dart';
import 'app_snack_bar.dart';
import 'botao_app.dart';
import 'info_linha.dart';
import 'reagendar_sheet.dart';
import 'status_chip.dart';
import 'tipo_atendimento_icone.dart';

/// BottomSheet com todos os detalhes de um agendamento.
/// Se estiver ativo, oferece "Reagendar" e "Cancelar agendamento".
abstract final class DetalhesAgendamentoSheet {
  /// [aoCancelar] é chamado depois de cancelar (ex.: ir para a aba Histórico).
  static Future<void> mostrar(
    BuildContext context,
    String protocolo, {
    VoidCallback? aoCancelar,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _ConteudoDetalhes(protocolo: protocolo, aoCancelar: aoCancelar),
    );
  }
}

class _ConteudoDetalhes extends StatelessWidget {
  const _ConteudoDetalhes({required this.protocolo, this.aoCancelar});

  final String protocolo;
  final VoidCallback? aoCancelar;

  Future<void> _reagendar(BuildContext context, Agendamento a) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final nova = await ReagendarSheet.mostrar(context, a);
    if (nova == null) return;

    try {
      await AgendamentoRepository.instance.reagendar(a.protocolo, nova);
    } catch (erro) {
      AppSnackBar.mostrar(
        messenger,
        mensagemDeErro(erro),
        icone: Icons.error_outline,
      );
      return;
    }
    final atualizado = a.copyWith(dataHora: nova);

    navigator.pop(); // fecha os detalhes
    AppSnackBar.mostrar(
      messenger,
      'Agendamento reagendado para ${atualizado.dataFormatada} '
      'às ${atualizado.horaFormatada}.',
      icone: Icons.event_available,
    );
  }

  Future<void> _cancelar(BuildContext context, Agendamento a) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancelar agendamento?', style: AppText.listaTitulo),
        content: Text(
          'Você vai cancelar "${a.titulo}" em ${a.dataFormatada} às '
          '${a.horaFormatada}. O agendamento será movido para o Histórico '
          'com status "Cancelado".',
          style: AppText.detalheCorpo,
        ),
        actionsOverflowButtonSpacing: 8,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Manter agendamento',
              style: AppText.opcao(AppColors.azulPrimario, peso: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Sim, cancelar',
              style: AppText.opcao(
                AppColors.canceladoTexto,
                peso: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    try {
      await AgendamentoRepository.instance.cancelar(a.protocolo);
    } catch (erro) {
      AppSnackBar.mostrar(
        messenger,
        mensagemDeErro(erro),
        icone: Icons.error_outline,
      );
      return;
    }
    navigator.pop(); // fecha os detalhes
    aoCancelar?.call();
    AppSnackBar.mostrar(
      messenger,
      'Agendamento cancelado. Ele está no Histórico.',
      icone: Icons.event_busy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = AgendamentoRepository.instance;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final a = repo.porProtocolo(protocolo);
        if (a == null) return const SizedBox.shrink();

        final inferior = MediaQuery.paddingOf(context).bottom;
        final altura = MediaQuery.sizeOf(context).height;

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
                  child: _Corpo(agendamento: a),
                ),
              ),
              if (a.estaAtivo)
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + inferior),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BotaoApp(
                        rotulo: 'Reagendar',
                        icone: Icons.event_repeat,
                        onPressed: () => _reagendar(context, a),
                      ),
                      const SizedBox(height: 10),
                      BotaoApp(
                        rotulo: 'Cancelar agendamento',
                        icone: Icons.event_busy,
                        estilo: EstiloBotao.perigo,
                        onPressed: () => _cancelar(context, a),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(height: 12 + inferior),
            ],
          ),
        );
      },
    );
  }
}

class _Corpo extends StatelessWidget {
  const _Corpo({required this.agendamento});

  final Agendamento agendamento;

  @override
  Widget build(BuildContext context) {
    final a = agendamento;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(a.tipo.icone),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(a.titulo, style: AppText.cardTitulo),
                  ),
                  Text(a.tipo.rotulo, style: AppText.cardUnidade),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatusChip(status: a.status),
        const SizedBox(height: 20),
        InfoLinha(
          icone: Icons.event_outlined,
          rotulo: 'Data e horário',
          valor: a.dataPorExtenso,
        ),
        InfoLinha(
          icone: Icons.person_outline,
          rotulo: 'Profissional',
          valor: a.profissional,
        ),
        InfoLinha(
          icone: Icons.location_on_outlined,
          rotulo: 'Unidade',
          valor: '${a.unidade.nome}\n${a.unidade.endereco}',
        ),
        const SizedBox(height: 4),
        Text('Orientações de preparo', style: AppText.formSecao),
        const SizedBox(height: 8),
        for (final item in a.orientacoes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.azulPrimario,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: AppText.detalheCorpo)),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.azulAbaInativa,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.azulBordaCard, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Protocolo', style: AppText.detalheRotulo),
              SelectableText(a.protocolo, style: AppText.protocolo),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
