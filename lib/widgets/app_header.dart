import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text.dart';

/// Cabeçalho azul com cantos inferiores arredondados e o logo do SUS.
///
/// Sem [onVoltar] mostra o layout da Home (saudação + subtítulo).
/// Com [onVoltar] mostra a seta e o título da página.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.onVoltar,
  });

  final String titulo;
  final String? subtitulo;
  final VoidCallback? onVoltar;

  /// Altura do cabeçalho no Figma, sem contar a barra de status.
  static const double altura = 94;

  @override
  Widget build(BuildContext context) {
    final topo = MediaQuery.paddingOf(context).top;
    final temVoltar = onVoltar != null;

    return Container(
      height: altura + topo,
      decoration: const BoxDecoration(
        color: AppColors.azulHeader,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: topo + 14,
            child: ExcludeSemantics(
              child: SvgPicture.asset(AppAssets.logoSus),
            ),
          ),
          if (temVoltar)
            Positioned(
              left: 0,
              top: topo + 3,
              child: IconButton(
                onPressed: onVoltar,
                tooltip: 'Voltar',
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          Positioned(
            left: temVoltar ? 32 : 24,
            right: 126,
            top: topo + (temVoltar ? 40 : 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    titulo,
                    style: AppText.headerTitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (subtitulo != null)
                  Text(
                    subtitulo!,
                    style: AppText.headerSubtitulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
