import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../models/unidade.dart';

/// Opção selecionável de unidade (nome + endereço), em formato de "rádio".
///
/// Com [motivoIndisponivel] preenchido a opção fica desabilitada e mostra
/// o motivo no lugar do endereço.
class TileUnidade extends StatelessWidget {
  const TileUnidade({
    super.key,
    required this.unidade,
    required this.selecionada,
    required this.onTap,
    this.motivoIndisponivel,
  });

  final Unidade unidade;
  final bool selecionada;
  final VoidCallback onTap;
  final String? motivoIndisponivel;

  bool get _habilitada => motivoIndisponivel == null;

  @override
  Widget build(BuildContext context) {
    final corTitulo =
        _habilitada ? AppColors.azulEscuro : AppColors.iconeInativo;

    return Semantics(
      button: true,
      selected: selecionada,
      enabled: _habilitada,
      label: '${unidade.nome}, ${motivoIndisponivel ?? unidade.endereco}',
      excludeSemantics: true,
      child: Material(
        color: !_habilitada
            ? AppColors.fundo
            : (selecionada ? AppColors.azulAbaInativa : Colors.white),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selecionada && _habilitada
                ? AppColors.azulPrimario
                : AppColors.azulBordaCard,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: _habilitada ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  selecionada
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color:
                      _habilitada ? AppColors.azulPrimario : AppColors.iconeInativo,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unidade.nome,
                        style: AppText.opcao(corTitulo, peso: FontWeight.w600),
                      ),
                      Text(
                        motivoIndisponivel ?? unidade.endereco,
                        style: AppText.formAjuda,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
