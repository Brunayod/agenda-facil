import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_input.dart';
import '../core/app_text.dart';

/// Diálogo com um campo de texto para adicionar um item a uma lista.
abstract final class DialogoAdicionarItem {
  /// Devolve o texto digitado, ou `null` se o usuário cancelar.
  static Future<String?> mostrar(
    BuildContext context, {
    required String titulo,
    required String dica,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => _Conteudo(titulo: titulo, dica: dica),
    );
  }
}

class _Conteudo extends StatefulWidget {
  const _Conteudo({required this.titulo, required this.dica});

  final String titulo;
  final String dica;

  @override
  State<_Conteudo> createState() => _ConteudoState();
}

class _ConteudoState extends State<_Conteudo> {
  final TextEditingController _controller = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) {
      setState(() => _erro = 'Digite um nome.');
      return;
    }
    Navigator.of(context).pop(texto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.titulo, style: AppText.listaTitulo),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 30,
        textCapitalization: TextCapitalization.sentences,
        style: AppText.campo,
        decoration: CampoDecoracao.criar(dica: widget.dica, erro: _erro),
        onChanged: (_) {
          if (_erro != null) setState(() => _erro = null);
        },
        onSubmitted: (_) => _confirmar(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: AppText.opcao(
              AppColors.textoSecundario,
              peso: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: _confirmar,
          child: Text(
            'Adicionar',
            style: AppText.opcao(AppColors.azulPrimario, peso: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
