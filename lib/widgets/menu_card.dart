import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text.dart';

/// Card de atalho da Home (ícone + título + descrição + seta).
class MenuCard extends StatelessWidget {
  const MenuCard({
    super.key,
    required this.icone,
    required this.titulo,
    required this.subtitulo,
    this.onTap,
  });

  /// Caminho do SVG do ícone.
  final String icone;
  final String titulo;
  final String subtitulo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$titulo. ${subtitulo.replaceAll('\n', ' ')}',
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.azulBordaCard, width: 2),
        ),
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 114),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 17, 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 78,
                    child: Center(child: SvgPicture.asset(icone)),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titulo, style: AppText.menuTitulo),
                        Text(subtitulo, style: AppText.menuSubtitulo),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(AppAssets.chevron),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
