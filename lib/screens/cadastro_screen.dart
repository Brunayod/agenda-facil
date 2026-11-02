import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_input.dart';
import '../core/app_text.dart';
import '../core/formatadores.dart';
import '../core/validadores.dart';
import '../data/catalogo.dart';
import '../data/paciente_repository.dart';
import '../models/paciente.dart';
import '../widgets/app_background.dart';
import '../widgets/app_header.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/aviso_erro.dart';
import '../widgets/botao_app.dart';
import '../widgets/opcao_chip.dart';
import '../widgets/secao_card.dart';
import '../widgets/tile_unidade.dart';

/// Cadastro de novo paciente. Ao concluir, volta e já entra na conta criada.
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  static const _tiposSanguineos = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _cpf = TextEditingController();
  final _cns = TextEditingController();
  final _nascimento = TextEditingController();
  final _telefone = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirmar = TextEditingController();

  String? _tipoSanguineo;
  String? _unidadeId;

  bool _tentou = false;
  bool _verSenha = false;
  bool _verConfirmar = false;
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
    _senha.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    if (_salvando) return;
    setState(() {
      _tentou = true;
      _erro = null;
    });

    final camposOk = _formKey.currentState?.validate() ?? false;
    final tipo = _tipoSanguineo;
    final unidadeId = _unidadeId;
    if (!camposOk || tipo == null || unidadeId == null) {
      setState(() => _erro = 'Revise os campos destacados em vermelho.');
      return;
    }

    setState(() => _salvando = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final paciente = Paciente(
      nome: _nome.text.trim(),
      cns: Validadores.digitos(_cns.text),
      cpf: Validadores.digitos(_cpf.text),
      dataNascimento: Validadores.converterData(_nascimento.text)!,
      tipoSanguineo: tipo,
      telefone: _telefone.text.trim(),
      email: _email.text.trim(),
      endereco: Paciente.enderecoNaoInformado,
      unidadeReferenciaId: unidadeId,
      alergias: const [],
      condicoes: const [],
    );

    final repo = PacienteRepository.instance;
    final erro = await repo.cadastrar(paciente: paciente, senha: _senha.text);
    if (!mounted) return;
    if (erro != null) {
      setState(() {
        _salvando = false;
        _erro = erro;
      });
      return;
    }

    // Fecha o cadastro primeiro; ao iniciar a sessão o app troca o login
    // pela Home sozinho.
    navigator.pop();
    await repo.iniciarSessao(paciente.cpf);
    AppSnackBar.mostrar(
      messenger,
      'Conta criada! Bem-vindo(a), ${paciente.primeiroNome}.',
    );
  }

  InputDecoration _decoracao(
    String rotulo,
    IconData icone, {
    String? dica,
    Widget? sufixo,
  }) {
    return CampoDecoracao.criar(
      rotulo: rotulo,
      dica: dica,
      sufixo: sufixo,
      prefixo: Icon(icone, color: AppColors.azulPrimario),
    );
  }

  Widget _botaoOlho({required bool visivel, required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      tooltip: visivel ? 'Ocultar senha' : 'Mostrar senha',
      icon: Icon(
        visivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textoSecundario,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const auto = AutovalidateMode.onUserInteraction;

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
                  onVoltar: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      children: [
                        SecaoCard(
                          titulo: 'Dados pessoais',
                          icone: Icons.person_outline,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nome,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                style: AppText.campo,
                                validator: Validadores.nome,
                                autovalidateMode: auto,
                                decoration: _decoracao(
                                  'Nome completo',
                                  Icons.person_outline,
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _cpf,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: const [FormatoCpf()],
                                style: AppText.campo,
                                validator: Validadores.cpf,
                                autovalidateMode: auto,
                                decoration: _decoracao(
                                  'CPF',
                                  Icons.badge_outlined,
                                  dica: '000.000.000-00',
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _cns,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: const [FormatoCns()],
                                style: AppText.campo,
                                validator: Validadores.cns,
                                autovalidateMode: auto,
                                decoration: _decoracao(
                                  'Cartão SUS (CNS)',
                                  Icons.credit_card_outlined,
                                  dica: '000 0000 0000 0000',
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _nascimento,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: const [FormatoData()],
                                style: AppText.campo,
                                validator: Validadores.dataNascimento,
                                autovalidateMode: auto,
                                decoration: _decoracao(
                                  'Data de nascimento',
                                  Icons.cake_outlined,
                                  dica: 'dd/mm/aaaa',
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _telefone,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                inputFormatters: const [FormatoTelefone()],
                                style: AppText.campo,
                                validator: Validadores.telefone,
                                autovalidateMode: auto,
                                decoration: _decoracao(
                                  'Telefone',
                                  Icons.phone_outlined,
                                  dica: '(00) 00000-0000',
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                style: AppText.campo,
                                validator: Validadores.email,
                                autovalidateMode: auto,
                                decoration: _decoracao(
                                  'E-mail',
                                  Icons.mail_outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SecaoCard(
                          titulo: 'Saúde e atendimento',
                          icone: Icons.favorite_border,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tipo sanguíneo', style: AppText.formRotulo),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final tipo in _tiposSanguineos)
                                    OpcaoChip(
                                      rotulo: tipo,
                                      selecionado: _tipoSanguineo == tipo,
                                      onTap: () =>
                                          setState(() => _tipoSanguineo = tipo),
                                    ),
                                ],
                              ),
                              if (_tentou && _tipoSanguineo == null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'Selecione o tipo sanguíneo.',
                                  style: AppText.campoErro,
                                ),
                              ],
                              const SizedBox(height: 18),
                              Text(
                                'UBS de referência',
                                style: AppText.formRotulo,
                              ),
                              const SizedBox(height: 8),
                              for (final unidade in Catalogo.unidades)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TileUnidade(
                                    unidade: unidade,
                                    selecionada: unidade.id == _unidadeId,
                                    onTap: () =>
                                        setState(() => _unidadeId = unidade.id),
                                  ),
                                ),
                              if (_tentou && _unidadeId == null)
                                Text(
                                  'Selecione sua UBS de referência.',
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
                              TextFormField(
                                controller: _senha,
                                obscureText: !_verSenha,
                                enableSuggestions: false,
                                autocorrect: false,
                                textInputAction: TextInputAction.next,
                                style: AppText.campo,
                                validator: Validadores.senha,
                                autovalidateMode: auto,
                                decoration: _decoracao(
                                  'Senha',
                                  Icons.lock_outline,
                                  dica: 'Mínimo de 6 caracteres',
                                  sufixo: _botaoOlho(
                                    visivel: _verSenha,
                                    onTap: () =>
                                        setState(() => _verSenha = !_verSenha),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _confirmar,
                                obscureText: !_verConfirmar,
                                enableSuggestions: false,
                                autocorrect: false,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _criar(),
                                style: AppText.campo,
                                validator: (valor) => valor == _senha.text
                                    ? null
                                    : 'As senhas não conferem.',
                                autovalidateMode: auto,
                                decoration: _decoracao(
                                  'Confirmar senha',
                                  Icons.lock_outline,
                                  sufixo: _botaoOlho(
                                    visivel: _verConfirmar,
                                    onTap: () => setState(
                                      () => _verConfirmar = !_verConfirmar,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_erro != null) ...[
                          AvisoErro(texto: _erro!),
                          const SizedBox(height: 14),
                        ],
                        BotaoApp(
                          rotulo: _salvando ? 'Criando conta...' : 'Criar conta',
                          icone: _salvando ? null : Icons.check,
                          onPressed: _salvando ? null : _criar,
                        ),
                      ],
                    ),
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
