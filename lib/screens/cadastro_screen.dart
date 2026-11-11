import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_input.dart';
import '../core/app_text.dart';
import '../core/mascaras.dart';
import '../core/validadores.dart';
import '../data/catalogo.dart';
import '../data/sessao_repository.dart';
import '../models/paciente.dart';
import '../widgets/app_background.dart';
import '../widgets/app_header.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/botao_app.dart';
import '../widgets/campo_senha.dart';
import '../widgets/opcao_chip.dart';
import '../widgets/secao_card.dart';
import '../widgets/tile_unidade.dart';

/// Cadastro de novo paciente. Ao concluir, a conta é criada e o usuário
/// já entra no app.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cpf = TextEditingController();
  final _cns = TextEditingController();
  final _nascimento = TextEditingController();
  final _telefone = TextEditingController();
  final _email = TextEditingController();
  final _endereco = TextEditingController();
  final _senha = TextEditingController();
  final _confirmacao = TextEditingController();

  String? _tipoSanguineo;
  String? _unidadeId;
  bool _tentouEnviar = false;
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _cpf.dispose();
    _cns.dispose();
    _nascimento.dispose();
    _telefone.dispose();
    _email.dispose();
    _endereco.dispose();
    _senha.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _criarConta() async {
    setState(() => _tentouEnviar = true);

    final formularioOk = _formKey.currentState?.validate() ?? false;
    final tipoSanguineo = _tipoSanguineo;
    final unidadeId = _unidadeId;
    final nascimento = Validadores.dataNascimento(_nascimento.text);
    if (!formularioOk ||
        tipoSanguineo == null ||
        unidadeId == null ||
        nascimento == null) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final endereco = _endereco.text.trim();

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final paciente = Paciente(
      nome: _nome.text.trim(),
      cns: Mascaras.apenasDigitos(_cns.text),
      cpf: Mascaras.apenasDigitos(_cpf.text),
      dataNascimento: nascimento,
      tipoSanguineo: tipoSanguineo,
      telefone: _telefone.text.trim(),
      email: _email.text.trim(),
      endereco: endereco.isEmpty ? 'Não informado' : endereco,
      unidadeReferenciaId: unidadeId,
      alergias: const [],
      condicoes: const [],
    );

    final erro = await SessaoRepository.instance.cadastrar(
      paciente: paciente,
      senha: _senha.text,
    );
    if (!mounted) return;

    if (erro != null) {
      setState(() {
        _salvando = false;
        _erro = erro;
      });
      return;
    }

    // A sessão já está ativa: o AppRaiz mostra o app atrás desta tela.
    navigator.pop();
    AppSnackBar.mostrar(messenger, 'Conta criada! Você já está conectado.');
  }

  Widget _campo({
    required TextEditingController controller,
    required String rotulo,
    required IconData icone,
    required FormFieldValidator<String> validator,
    TextInputType? teclado,
    TextInputAction acao = TextInputAction.next,
    List<MascaraInput> mascaras = const [],
    TextCapitalization capitalizacao = TextCapitalization.none,
    String? dica,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: teclado,
      textInputAction: acao,
      textCapitalization: capitalizacao,
      inputFormatters: mascaras,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppText.campo,
      decoration: CampoDecoracao.criar(
        rotulo: rotulo,
        dica: dica,
        prefixo: Icon(icone, color: AppColors.azulPrimario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inferior = MediaQuery.paddingOf(context).bottom;
    const espaco = SizedBox(height: 14);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Positioned.fill(
            child: Column(
              children: [
                AppHeader(
                  titulo: 'Criar conta',
                  subtitulo: 'Cadastro de novo paciente',
                  onVoltar: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, 24 + inferior),
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SecaoCard(
                              titulo: 'Dados pessoais',
                              icone: Icons.person_outline,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _campo(
                                    controller: _nome,
                                    rotulo: 'Nome completo',
                                    icone: Icons.badge_outlined,
                                    capitalizacao: TextCapitalization.words,
                                    validator: (v) =>
                                        (v ?? '').trim().split(RegExp(r'\s+')).length <
                                                2
                                            ? 'Informe nome e sobrenome.'
                                            : null,
                                  ),
                                  espaco,
                                  _campo(
                                    controller: _cpf,
                                    rotulo: 'CPF',
                                    icone: Icons.credit_card,
                                    teclado: TextInputType.number,
                                    mascaras: const [
                                      MascaraInput(Mascaras.cpf, maxDigitos: 11),
                                    ],
                                    validator: (v) => Validadores.cpfValido(v ?? '')
                                        ? null
                                        : 'CPF inválido.',
                                  ),
                                  espaco,
                                  _campo(
                                    controller: _cns,
                                    rotulo: 'Cartão SUS (CNS)',
                                    icone: Icons.health_and_safety_outlined,
                                    teclado: TextInputType.number,
                                    mascaras: const [
                                      MascaraInput(Mascaras.cns, maxDigitos: 15),
                                    ],
                                    validator: (v) => Validadores.cnsValido(v ?? '')
                                        ? null
                                        : 'Cartão SUS (CNS) inválido.',
                                  ),
                                  espaco,
                                  _campo(
                                    controller: _nascimento,
                                    rotulo: 'Data de nascimento',
                                    dica: 'dd/mm/aaaa',
                                    icone: Icons.cake_outlined,
                                    teclado: TextInputType.number,
                                    mascaras: const [
                                      MascaraInput(Mascaras.data, maxDigitos: 8),
                                    ],
                                    validator: (v) =>
                                        Validadores.dataNascimento(v ?? '') == null
                                            ? 'Informe uma data válida.'
                                            : null,
                                  ),
                                  const SizedBox(height: 18),
                                  Text('Tipo sanguíneo', style: AppText.formRotulo),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (final tipo in Catalogo.tiposSanguineos)
                                        OpcaoChip(
                                          rotulo: tipo,
                                          selecionado: _tipoSanguineo == tipo,
                                          onTap: () => setState(
                                            () => _tipoSanguineo = tipo,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (_tentouEnviar && _tipoSanguineo == null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        'Escolha seu tipo sanguíneo.',
                                        style: AppText.campoErro,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SecaoCard(
                              titulo: 'Contato',
                              icone: Icons.contact_phone_outlined,
                              child: Column(
                                children: [
                                  _campo(
                                    controller: _telefone,
                                    rotulo: 'Telefone',
                                    icone: Icons.phone_outlined,
                                    teclado: TextInputType.phone,
                                    mascaras: const [
                                      MascaraInput(
                                        Mascaras.telefone,
                                        maxDigitos: 11,
                                      ),
                                    ],
                                    validator: (v) =>
                                        Validadores.telefoneValido(v ?? '')
                                            ? null
                                            : 'Informe o telefone com DDD.',
                                  ),
                                  espaco,
                                  _campo(
                                    controller: _email,
                                    rotulo: 'E-mail',
                                    icone: Icons.mail_outline,
                                    teclado: TextInputType.emailAddress,
                                    validator: (v) =>
                                        Validadores.emailValido(v ?? '')
                                            ? null
                                            : 'Informe um e-mail válido.',
                                  ),
                                  espaco,
                                  _campo(
                                    controller: _endereco,
                                    rotulo: 'Endereço (opcional)',
                                    icone: Icons.home_outlined,
                                    teclado: TextInputType.streetAddress,
                                    capitalizacao: TextCapitalization.words,
                                    validator: (_) => null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SecaoCard(
                              titulo: 'UBS de referência',
                              icone: Icons.local_hospital_outlined,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final unidade in Catalogo.unidades)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: TileUnidade(
                                        unidade: unidade,
                                        selecionada: unidade.id == _unidadeId,
                                        onTap: () => setState(
                                          () => _unidadeId = unidade.id,
                                        ),
                                      ),
                                    ),
                                  if (_tentouEnviar && _unidadeId == null)
                                    Text(
                                      'Escolha sua UBS de referência.',
                                      style: AppText.campoErro,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SecaoCard(
                              titulo: 'Senha de acesso',
                              icone: Icons.lock_outline,
                              child: Column(
                                children: [
                                  CampoSenha(
                                    controller: _senha,
                                    rotulo: 'Senha (mínimo 6 caracteres)',
                                    textInputAction: TextInputAction.next,
                                    validator: (v) => (v ?? '').length < 6
                                        ? 'Use pelo menos 6 caracteres.'
                                        : null,
                                  ),
                                  espaco,
                                  CampoSenha(
                                    controller: _confirmacao,
                                    rotulo: 'Confirmar senha',
                                    validator: (v) => v != _senha.text
                                        ? 'As senhas não coincidem.'
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_erro != null) ...[
                        const SizedBox(height: 12),
                        Semantics(
                          liveRegion: true,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.canceladoFundo,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 20,
                                  color: AppColors.canceladoTexto,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_erro!, style: AppText.erroForm),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      BotaoApp(
                        rotulo: 'Criar conta',
                        icone: Icons.check,
                        carregando: _salvando,
                        onPressed: _salvando ? null : _criarConta,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
