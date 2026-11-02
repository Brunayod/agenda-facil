import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../models/unidade.dart';
import 'tag_servico.dart';

/// Card de uma UBS na tela Rede: nome, endereço, horário, telefone,
/// distância e tags dos serviços oferecidos.
class UnidadeCard extends StatelessWidget {
  const UnidadeCard({super.key, required this.unidade, required this.onTap});

  final Unidade unidade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final u = unidade;

    return Semantics(
      button: true,
      label: '${u.nome}, ${u.endereco}, ${u.horarioFuncionamento}, '
          'telefone ${u.telefone}, a ${u.distanciaFormatada}. '
          'Toque para ver detalhes.',
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
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.azulCirculo,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_hospital_outlined,
                        color: AppColors.azulPrimario,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u.nome, style: AppText.unidadeNome),
                          Text(u.endereco, style: AppText.cardUnidade),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          size: 14,
                          color: AppColors.azulPrimario,
                        ),
                        const SizedBox(width: 3),
                        Text(u.distanciaFormatada, style: AppText.distancia),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _Linha(
                  icone: Icons.schedule,
                  texto: u.horarioFuncionamento,
                ),
                const SizedBox(height: 4),
                _Linha(icone: Icons.phone_outlined, texto: u.telefone),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tipo in u.servicos)
                      TagServico(rotulo: tipo.rotuloCurto),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icone, size: 16, color: AppColors.textoSecundario),
        const SizedBox(width: 8),
        Expanded(child: Text(texto, style: AppText.cardData)),
      ],
    );
  }
}
