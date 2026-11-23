import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_input.dart';
import '../core/app_text.dart';
import '../data/catalogo.dart';
import '../models/tipo_atendimento.dart';
import '../models/unidade.dart';
import '../widgets/app_header.dart';
import '../widgets/detalhes_unidade_sheet.dart';
import '../widgets/opcao_chip.dart';
import '../widgets/unidade_card.dart';

/// Aba "Rede": unidades de saúde com busca e filtro por tipo de atendimento.
class RedeScreen extends StatefulWidget {
  const RedeScreen({
    super.key,
    required this.onVoltar,
    required this.onAgendar,
  });

  final VoidCallback onVoltar;

  /// Chamado ao tocar em "Agendar nesta unidade".
  final ValueChanged<Unidade> onAgendar;

  @override
  State<RedeScreen> createState() => _RedeScreenState();
}

class _RedeScreenState extends State<RedeScreen> {
  final TextEditingController _busca = TextEditingController();
  TipoAtendimento? _filtro;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unidades = Catalogo.buscarUnidades(
      consulta: _busca.text,
      tipo: _filtro,
    );

    return Column(
      children: [
        AppHeader(titulo: 'Rede de saúde', onVoltar: widget.onVoltar),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            children: [
              TextField(
                controller: _busca,
                textInputAction: TextInputAction.search,
                style: AppText.campo,
                onChanged: (_) => setState(() {}),
                decoration: CampoDecoracao.criar(
                  dica: 'Buscar por nome ou bairro',
                  raio: 28,
                  prefixo: const Icon(
                    Icons.search,
                    color: AppColors.azulPrimario,
                  ),
                  sufixo: _busca.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textoSecundario,
                          ),
                          onPressed: () => setState(_busca.clear),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: OpcaoChip(
                        rotulo: 'Todos',
                        selecionado: _filtro == null,
                        onTap: () => setState(() => _filtro = null),
                      ),
                    ),
                    for (final tipo in TipoAtendimento.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: OpcaoChip(
                          rotulo: tipo.rotuloCurto,
                          selecionado: _filtro == tipo,
                          onTap: () => setState(() => _filtro = tipo),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                unidades.length == 1
                    ? '1 unidade encontrada'
                    : '${unidades.length} unidades encontradas',
                style: AppText.formAjuda,
              ),
              const SizedBox(height: 8),
              if (unidades.isEmpty)
                const _SemResultados()
              else
                for (final unidade in unidades) ...[
                  UnidadeCard(
                    unidade: unidade,
                    onTap: () => DetalhesUnidadeSheet.mostrar(
                      context,
                      unidade,
                      onAgendar: widget.onAgendar,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SemResultados extends StatelessWidget {
  const _SemResultados();

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
            Icons.search_off,
            size: 40,
            color: AppColors.azulPrimario,
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma unidade encontrada.',
            textAlign: TextAlign.center,
            style: AppText.menuTitulo,
          ),
          const SizedBox(height: 4),
          Text(
            'Tente outro nome, bairro ou tipo de atendimento.',
            textAlign: TextAlign.center,
            style: AppText.menuSubtitulo,
          ),
        ],
      ),
    );
  }
}
