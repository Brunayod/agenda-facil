import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';

enum EstiloBotao { primario, contorno, perigo }

/// Botão em formato de pílula, no estilo das abas do protótipo.
/// Com [onPressed] nulo o botão fica desabilitado.
class BotaoApp extends StatelessWidget {
  const BotaoApp({
    super.key,
    required this.rotulo,
    required this.onPressed,
    this.estilo = EstiloBotao.primario,
    this.icone,
  });

  final String rotulo;
  final VoidCallback? onPressed;
  final EstiloBotao estilo;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final habilitado = onPressed != null;

    final _Cores cores = switch (estilo) {
      EstiloBotao.primario => _Cores(
          fundo: habilitado ? AppColors.azulPrimario : AppColors.iconeInativo,
          texto: Colors.white,
        ),
      EstiloBotao.contorno => const _Cores(
          fundo: Colors.white,
          texto: AppColors.azulPrimario,
          borda: BorderSide(color: AppColors.azulPrimario, width: 2),
        ),
      EstiloBotao.perigo => const _Cores(
          fundo: Colors.white,
          texto: AppColors.canceladoTexto,
          borda: BorderSide(color: AppColors.canceladoTexto, width: 2),
        ),
    };

    return Semantics(
      button: true,
      enabled: habilitado,
      label: rotulo,
      excludeSemantics: true,
      child: Material(
        color: cores.fundo,
        clipBehavior: Clip.antiAlias,
        shape: StadiumBorder(side: cores.borda),
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icone != null) ...[
                    Icon(icone, size: 20, color: cores.texto),
                    const SizedBox(width: 8),
                  ],
                  Text(rotulo, style: AppText.botao(cores.texto)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Cores {
  const _Cores({
    required this.fundo,
    required this.texto,
    this.borda = BorderSide.none,
  });

  final Color fundo;
  final Color texto;
  final BorderSide borda;
}
