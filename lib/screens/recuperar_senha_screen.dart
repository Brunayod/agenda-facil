import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_input.dart';
import '../core/app_text.dart';
import '../core/validadores.dart';
import '../data/erros.dart';
import '../data/recuperacao_senha.dart';
import '../widgets/botao_app.dart';
import '../widgets/campo_senha.dart';

enum _Etapa { email, codigo, senha }

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recuperacao = RecuperacaoSenha();
  final _email = TextEditingController();
  final _codigo = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();

  _Etapa _etapa = _Etapa.email;
  bool _ocupado = false;
  String? _erro;

  @override
  void dispose() {
    unawaited(_recuperacao.encerrar());
    _email.dispose();
    _codigo.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _continuar({bool reenviar = false}) async {
    if (_ocupado || (!reenviar && !_formKey.currentState!.validate())) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _ocupado = true;
      _erro = null;
    });

    try {
      if (reenviar || _etapa == _Etapa.email) {
        await _recuperacao.enviarCodigo(_email.text.trim());
        if (!mounted) return;
        _codigo.clear();
        setState(() => _etapa = _Etapa.codigo);
      } else if (_etapa == _Etapa.codigo) {
        await _recuperacao.verificarCodigo(_email.text.trim(), _codigo.text);
        if (!mounted) {
          unawaited(_recuperacao.encerrar());
          return;
        }
        _codigo.clear();
        setState(() => _etapa = _Etapa.senha);
      } else {
        await _recuperacao.redefinir(_senha.text);
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (erro) {
      if (mounted) {
        setState(() {
          if (_etapa == _Etapa.senha && !_recuperacao.codigoVerificado) {
            _voltarParaEmail();
          }
          _erro = erro is ErroApp ? erro.mensagem : mensagemSemConexao;
        });
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  void _voltarParaEmail() {
    _codigo.clear();
    _senha.clear();
    _confirmacao.clear();
    _erro = null;
    _etapa = _Etapa.email;
  }

  @override
  Widget build(BuildContext context) {
    final instrucao = switch (_etapa) {
      _Etapa.email => 'Informe o e-mail cadastrado na sua conta.',
      _Etapa.codigo =>
        'Se houver uma conta com o e-mail ${_email.text.trim()}, você '
            'receberá um código de 6 dígitos. Confira também a caixa de spam.',
      _Etapa.senha => 'Escolha uma nova senha para entrar no Agenda Fácil.',
    };
    final acao = switch (_etapa) {
      _Etapa.email => 'Enviar código',
      _Etapa.codigo => 'Validar código',
      _Etapa.senha => 'Salvar nova senha',
    };

    return PopScope(
      canPop: !_ocupado,
      child: Scaffold(
        appBar: AppBar(title: const Text('Recuperar senha')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Semantics(
                    liveRegion: true,
                    child: Text(instrucao, style: AppText.formAjuda),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_etapa == _Etapa.email)
                          TextFormField(
                            key: const ValueKey(_Etapa.email),
                            controller: _email,
                            readOnly: _ocupado,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.email],
                            autocorrect: false,
                            onFieldSubmitted: (_) => _continuar(),
                            validator: (valor) =>
                                Validadores.emailValido(valor ?? '')
                                    ? null
                                    : 'Informe um e-mail válido.',
                            style: AppText.campo,
                            decoration: CampoDecoracao.criar(rotulo: 'E-mail'),
                          ),
                        if (_etapa == _Etapa.codigo)
                          TextFormField(
                            key: const ValueKey(_Etapa.codigo),
                            controller: _codigo,
                            readOnly: _ocupado,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            onFieldSubmitted: (_) => _continuar(),
                            validator: (valor) => valor?.length == 6
                                ? null
                                : 'Informe os 6 dígitos do código.',
                            style: AppText.campo,
                            decoration: CampoDecoracao.criar(
                              rotulo: 'Código de recuperação',
                            ),
                          ),
                        if (_etapa == _Etapa.senha) ...[
                          CampoSenha(
                            key: const ValueKey('novaSenha'),
                            controller: _senha,
                            rotulo: 'Nova senha',
                            textInputAction: TextInputAction.next,
                            validator: (valor) => (valor ?? '').length < 6
                                ? 'Use pelo menos 6 caracteres.'
                                : null,
                          ),
                          const SizedBox(height: 14),
                          CampoSenha(
                            key: const ValueKey('confirmaSenha'),
                            controller: _confirmacao,
                            rotulo: 'Confirme a nova senha',
                            onSubmitted: (_) => _continuar(),
                            validator: (valor) => valor == _senha.text
                                ? null
                                : 'As senhas precisam ser iguais.',
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_erro != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      child: Text(_erro!, style: AppText.erroForm),
                    ),
                  ],
                  const SizedBox(height: 20),
                  BotaoApp(
                    rotulo: acao,
                    carregando: _ocupado,
                    onPressed: _ocupado ? null : _continuar,
                  ),
                  if (_etapa == _Etapa.codigo) ...[
                    TextButton(
                      onPressed:
                          _ocupado ? null : () => _continuar(reenviar: true),
                      child: const Text('Reenviar código'),
                    ),
                    TextButton(
                      onPressed:
                          _ocupado ? null : () => setState(_voltarParaEmail),
                      child: const Text('Alterar e-mail'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}