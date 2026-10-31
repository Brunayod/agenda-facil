import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_assets.dart';

/// Fundo cinza com a onda azul e as cruzes decorativas.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SvgPicture.asset(
        AppAssets.fundo,
        fit: BoxFit.cover,
        alignment: Alignment.centerRight,
      ),
    );
  }
}
