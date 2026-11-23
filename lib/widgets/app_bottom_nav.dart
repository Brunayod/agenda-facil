import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text.dart';

/// Barra de navegação inferior com o botão central do SUS em destaque.
///
/// Índices: 0 Início · 1 Agenda · 2 Rede · 3 Perfil.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.indiceAtual,
    required this.onSelecionar,
    required this.onBotaoCentral,
  });

  final int indiceAtual;
  final ValueChanged<int> onSelecionar;
  final VoidCallback onBotaoCentral;

  /// Quanto o botão central sobressai acima da barra branca.
  static const double _saliencia = 19;
  static const double _alturaBarra = 66;

  @override
  Widget build(BuildContext context) {
    final inferior = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      width: double.infinity,
      height: _saliencia + _alturaBarra + inferior,
      child: Stack(
        children: [
          Positioned(
            top: _saliencia,
            left: 0,
            right: 0,
            bottom: 0,
            // Camada externa = "borda" azul clara (só topo e laterais);
            // um BoxDecoration com borderRadius exige borda uniforme.
            child: Container(
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
              decoration: const BoxDecoration(
                color: AppColors.azulBordaCard,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Container(
                padding: EdgeInsets.only(top: 5, bottom: inferior),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Row(
                  children: [
                    _ItemNav(
                      rotulo: 'Início',
                      iconeAtivo: AppAssets.navInicioOn,
                      iconeInativo: AppAssets.navInicioOff,
                      selecionado: indiceAtual == 0,
                      onTap: () => onSelecionar(0),
                    ),
                    _ItemNav(
                      rotulo: 'Agenda',
                      iconeAtivo: AppAssets.navAgendaOn,
                      iconeInativo: AppAssets.navAgendaOff,
                      selecionado: indiceAtual == 1,
                      onTap: () => onSelecionar(1),
                    ),
                    const Spacer(), // espaço do botão central
                    _ItemNav(
                      rotulo: 'Rede',
                      iconeAtivo: AppAssets.navRedeOn,
                      iconeInativo: AppAssets.navRedeOff,
                      selecionado: indiceAtual == 2,
                      onTap: () => onSelecionar(2),
                    ),
                    _ItemNav(
                      rotulo: 'Perfil',
                      iconeAtivo: AppAssets.navPerfilOn,
                      iconeInativo: AppAssets.navPerfilOff,
                      selecionado: indiceAtual == 3,
                      onTap: () => onSelecionar(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Semantics(
              button: true,
              label: 'SUS, novo agendamento',
              excludeSemantics: true,
              child: GestureDetector(
                onTap: onBotaoCentral,
                behavior: HitTestBehavior.opaque,
                child: SvgPicture.asset(AppAssets.botaoCentral),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemNav extends StatelessWidget {
  const _ItemNav({
    required this.rotulo,
    required this.iconeAtivo,
    required this.iconeInativo,
    required this.selecionado,
    required this.onTap,
  });

  final String rotulo;
  final String iconeAtivo;
  final String iconeInativo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: selecionado,
        label: rotulo,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 36,
          // FittedBox reduz o conjunto (ícone + rótulo) se faltar espaço,
          // então a barra nunca estoura, seja qual for a escala de fonte.
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(selecionado ? iconeAtivo : iconeInativo),
                  const SizedBox(height: 2),
                  Text(
                    rotulo,
                    style: AppText.navRotulo,
                    maxLines: 1,
                    // Limita o aumento de fonte do sistema nesta barra.
                    textScaler: MediaQuery.textScalerOf(context)
                        .clamp(maxScaleFactor: 1.15),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
