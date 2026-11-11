import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_input.dart';
import '../core/app_text.dart';
import '../core/mascaras.dart';
import '../core/validadores.dart';
import '../data/dados_demo.dart';
import '../data/sessao_repository.dart';
import '../widgets/app_background.dart';
import '../widgets/botao_app.dart';
import '../widgets/campo_senha.dart';
import 'cadastro_screen.dart';

/// Tela de login: CPF ou Cartão SUS (CNS) + senha.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identificador = TextEditingController();
  final _senha = TextEditingController();

  bool _entrando = false;
  bool _entrandoDemo = false;
  String? _erro;

  bool get _ocupado => _entrando || _entrandoDemo;

  @override
  void dispose() {
    _identificador.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _entrando = true;
      _erro = null;
    });
    final erro = await SessaoRepository.instance.entrar(
      identificador: _identificador.text,
      senha: _senha.text,
    );
    // Em caso de sucesso o AppRaiz troca de tela e este widget é descartado.
    if (!mounted) return;
    setState(() {
      _entrando = false;
      _erro = erro;
    });
  }

  Future<void> _acessoRapido() async {
    setState(() {
      _entrandoDemo = true;
      _erro = null;
    });
    final erro = await SessaoRepository.instance.entrarComoDemo();
    // Em caso de sucesso o AppRaiz troca de tela e este widget é descartado.
    if (!mounted) return;
    setState(() {
      _entrandoDemo = false;
      _erro = erro;
    });
  }

  void _criarConta() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (context) => const CadastroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topo = MediaQuery.paddingOf(context).top;
    final inferior = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Positioned.fill(
            child: ListView(
              padding: EdgeInsets.only(bottom: 24 + inferior),
              children: [
                _CabecalhoLogin(topo: topo),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.azulBordaCard,
                        width: 2,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text('Entrar', style: AppText.tituloSecao),
                          ),
                          Text(
                            'Use seu CPF ou Cartão SUS e sua senha.',
                            style: AppText.formAjuda,
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _identificador,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            inputFormatters: const [
                              MascaraInput(Mascaras.cpfOuCns, maxDigitos: 15),
                            ],
                            validator: Validadores.cpfOuCns,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: AppText.campo,
                            decoration: CampoDecoracao.criar(
                              rotulo: 'CPF ou Cartão SUS (CNS)',
                              prefixo: const Icon(
                                Icons.badge_outlined,
                                color: AppColors.azulPrimario,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          CampoSenha(
                            controller: _senha,
                            validator: (valor) => (valor ?? '').isEmpty
                                ? 'Informe sua senha.'
                                : null,
                            onSubmitted: (_) => _ocupado ? null : _entrar(),
                          ),
                          if (_erro != null) ...[
                            const SizedBox(height: 12),
                            _CaixaErro(mensagem: _erro!),
                          ],
                          const SizedBox(height: 20),
                          BotaoApp(
                            rotulo: 'Entrar',
                            icone: Icons.login,
                            carregando: _entrando,
                            onPressed: _ocupado ? null : _entrar,
                          ),
                          const SizedBox(height: 10),
                          BotaoApp(
                            rotulo: 'Criar minha conta',
                            icone: Icons.person_add_alt_1_outlined,
                            estilo: EstiloBotao.contorno,
                            onPressed: _ocupado ? null : _criarConta,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    children: [
                      BotaoApp(
                        rotulo: 'Acesso Rápido (Demo Banca)',
                        icone: Icons.bolt,
                        estilo: EstiloBotao.destaque,
                        carregando: _entrandoDemo,
                        onPressed: _ocupado ? null : _acessoRapido,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Entra como Jheniffer Almeida Santos, com dados de '
                        'demonstração.\nCPF ${Mascaras.cpf(DadosDemo.cpf)} · '
                        'senha ${DadosDemo.senha}',
                        textAlign: TextAlign.center,
                        style: AppText.formAjuda,
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

/// Faixa azul do topo com a marca do app e o logo do SUS.
class _CabecalhoLogin extends StatelessWidget {
  const _CabecalhoLogin({required this.topo});

  final double topo;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 210 + topo),
      decoration: const BoxDecoration(
        color: AppColors.azulHeader,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 10,
            top: topo + 18,
            child: ExcludeSemantics(
              child: SvgPicture.asset(AppAssets.logoSus),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, topo + 100, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text('Agenda Fácil', style: AppText.loginTitulo),
                ),
                Text(
                  'Consultas, exames e vacinas da rede pública de saúde, '
                  'na palma da mão.',
                  style: AppText.loginSubtitulo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaixaErro extends StatelessWidget {
  const _CaixaErro({required this.mensagem});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Semantics(
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
            Expanded(child: Text(mensagem, style: AppText.erroForm)),
          ],
        ),
      ),
    );
  }
}
