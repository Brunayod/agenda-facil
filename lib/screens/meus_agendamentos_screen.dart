import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../data/agendamento_repository.dart';
import '../models/agendamento.dart';
import '../widgets/abas_agenda.dart';
import '../widgets/agendamento_card.dart';
import '../widgets/app_header.dart';
import '../widgets/detalhes_agendamento_sheet.dart';

/// Telas 2 e 3 — "Meus agendamentos" com as abas Agenda ativa e Histórico.
///
/// A aba selecionada vem de fora ([aba]) para o app poder abrir direto na
/// "Agenda ativa" depois de criar um agendamento. A lista é reativa: muda
/// sozinha quando o repositório é atualizado.
class MeusAgendamentosScreen extends StatelessWidget {
  const MeusAgendamentosScreen({
    super.key,
    required this.aba,
    required this.onVoltar,
  });

  final ValueNotifier<AbaAgenda> aba;
  final VoidCallback onVoltar;

  @override
  Widget build(BuildContext context) {
    final repo = AgendamentoRepository.instance;

    return ListenableBuilder(
      listenable: Listenable.merge([repo, aba]),
      builder: (context, _) {
        final ehAtiva = aba.value == AbaAgenda.ativa;
        final titulo = ehAtiva ? 'Agenda Ativa' : 'Histórico de agendamentos';
        final subtitulo = ehAtiva
            ? 'Aqui estão suas consultas e exames agendados'
            : 'Consulte seus atendimentos realizados';
        final lista = ehAtiva ? repo.ativos : repo.historico;

        return Column(
          children: [
            AppHeader(titulo: 'Meus agendamentos', onVoltar: onVoltar),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(11, 31, 11, 16),
                children: [
                  AbasAgenda(
                    selecionada: aba.value,
                    onSelecionar: (nova) => aba.value = nova,
                  ),
                  const SizedBox(height: 9),
                  Padding(
                    padding: const EdgeInsets.only(left: 11),
                    child: Semantics(
                      header: true,
                      child: Text(titulo, style: AppText.listaTitulo),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 19),
                    child: Text(subtitulo, style: AppText.listaSubtitulo),
                  ),
                  const SizedBox(height: 14),
                  if (lista.isEmpty)
                    _EstadoVazio(ativa: ehAtiva)
                  else
                    for (final agendamento in lista) ...[
                      AgendamentoCard(
                        agendamento: agendamento,
                        onTap: () => _abrirDetalhes(context, agendamento),
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _abrirDetalhes(BuildContext context, Agendamento agendamento) {
    DetalhesAgendamentoSheet.mostrar(
      context,
      agendamento.protocolo,
      // Ao cancelar, mostra a aba Histórico onde o item passou a aparecer.
      aoCancelar: () => aba.value = AbaAgenda.historico,
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({required this.ativa});

  final bool ativa;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.azulBordaCard, width: 2),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_available_outlined,
            size: 40,
            color: AppColors.azulPrimario,
          ),
          const SizedBox(height: 12),
          Text(
            ativa
                ? 'Você não tem agendamentos ativos.'
                : 'Seu histórico está vazio.',
            textAlign: TextAlign.center,
            style: AppText.menuTitulo,
          ),
          if (ativa) ...[
            const SizedBox(height: 4),
            Text(
              'Toque no botão SUS, no centro da barra, para agendar.',
              textAlign: TextAlign.center,
              style: AppText.menuSubtitulo,
            ),
          ],
        ],
      ),
    );
  }
}
