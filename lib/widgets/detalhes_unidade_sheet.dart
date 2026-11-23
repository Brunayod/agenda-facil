import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../models/unidade.dart';
import 'botao_app.dart';
import 'info_linha.dart';
import 'tag_servico.dart';

/// BottomSheet com os detalhes de uma UBS, seus profissionais e o botão
/// "Agendar nesta unidade".
abstract final class DetalhesUnidadeSheet {
  /// [onAgendar] é chamado depois de fechar o modal, com a unidade escolhida.
  static Future<void> mostrar(
    BuildContext context,
    Unidade unidade, {
    required ValueChanged<Unidade> onAgendar,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _Conteudo(unidade: unidade, onAgendar: onAgendar),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.unidade, required this.onAgendar});

  final Unidade unidade;
  final ValueChanged<Unidade> onAgendar;

  @override
  Widget build(BuildContext context) {
    final u = unidade;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppColors.azulCirculo,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_hospital_outlined,
                          size: 28,
                          color: AppColors.azulPrimario,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(u.nome, style: AppText.cardTitulo),
                            ),
                            Text(
                              '${u.bairro} • a ${u.distanciaFormatada}',
                              style: AppText.cardUnidade,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  InfoLinha(
                    icone: Icons.location_on_outlined,
                    rotulo: 'Endereço',
                    valor: u.endereco,
                  ),
                  InfoLinha(
                    icone: Icons.schedule,
                    rotulo: 'Horário de funcionamento',
                    valor: u.horarioFuncionamento,
                  ),
                  InfoLinha(
                    icone: Icons.phone_outlined,
                    rotulo: 'Telefone',
                    valor: u.telefone,
                  ),
                  Text('Serviços oferecidos', style: AppText.formSecao),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final tipo in u.servicos)
                        TagServico(rotulo: tipo.rotulo),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Profissionais que atendem aqui', style: AppText.formSecao),
                  const SizedBox(height: 10),
                  for (final p in u.profissionais)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: AppColors.azulOnda,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              size: 20,
                              color: AppColors.azulPrimario,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.nome, style: AppText.detalheValor),
                                Text(
                                  p.especialidade,
                                  style: AppText.detalheRotulo,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + inferior),
            child: BotaoApp(
              rotulo: 'Agendar nesta unidade',
              icone: Icons.event_available,
              onPressed: () {
                Navigator.of(context).pop();
                onAgendar(u);
              },
            ),
          ),
        ],
      ),
    );
  }
}
