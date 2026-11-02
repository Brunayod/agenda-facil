import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';

/// Etiqueta pequena (ex.: "Consulta", "Vacinação").
class TagServico extends StatelessWidget {
  const TagServico({super.key, required this.rotulo});

  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.azulOnda,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(rotulo, style: AppText.tag),
    );
  }
}
