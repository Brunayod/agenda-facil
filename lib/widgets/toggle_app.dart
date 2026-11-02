import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Interruptor (liga/desliga) no estilo do app.
class ToggleApp extends StatelessWidget {
  const ToggleApp({
    super.key,
    required this.valor,
    required this.onChanged,
    required this.rotulo,
  });

  final bool valor;
  final ValueChanged<bool> onChanged;

  /// Texto lido por leitores de tela.
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: valor,
      label: rotulo,
      onTap: () => onChanged(!valor),
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!valor),
          child: SizedBox(
            width: 60,
            height: 48,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 30,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: valor ? AppColors.azulPrimario : AppColors.iconeInativo,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment:
                      valor ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
