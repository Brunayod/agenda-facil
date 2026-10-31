import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../widgets/app_header.dart';

/// Tela provisória para abas que ainda não existem no protótipo (Rede, Perfil).
class EmConstrucaoScreen extends StatelessWidget {
  const EmConstrucaoScreen({
    super.key,
    required this.titulo,
    required this.onVoltar,
  });

  final String titulo;
  final VoidCallback onVoltar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(titulo: titulo, onVoltar: onVoltar),
        Expanded(
          child: Center(
            child: Text('Em construção', style: AppText.placeholder),
          ),
        ),
      ],
    );
  }
}
