import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_input.dart';
import '../core/app_text.dart';

/// Campo de senha com botão para mostrar/ocultar o texto.
class CampoSenha extends StatefulWidget {
  const CampoSenha({
    super.key,
    required this.controller,
    required this.validator,
    this.rotulo = 'Senha',
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final String rotulo;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _oculta,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppText.campo,
      decoration: CampoDecoracao.criar(
        rotulo: widget.rotulo,
        prefixo: const Icon(Icons.lock_outline, color: AppColors.azulPrimario),
        sufixo: IconButton(
          tooltip: _oculta ? 'Mostrar senha' : 'Ocultar senha',
          icon: Icon(
            _oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textoSecundario,
          ),
          onPressed: () => setState(() => _oculta = !_oculta),
        ),
      ),
    );
  }
}
