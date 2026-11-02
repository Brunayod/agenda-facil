import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_input.dart';
import '../core/app_text.dart';
import '../core/formatadores.dart';
import '../core/validadores.dart';
import '../data/paciente_repository.dart';
import '../widgets/app_background.dart';
import '../widgets/app_header.dart';
import '../widgets/aviso_erro.dart';
import '../widgets/botao_app.dart';
import 'cadastro_screen.dart';

/// Tela de entrada: CPF ou Cartão SUS + senha, cadastro e acesso de demonstração.
///
/// Não navega sozinha após o login: o app observa a sessão em
/// [PacienteRepository] e troca esta tela pela Home.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identificador = TextEditingController();
  final _senha = TextEditingController();

  bool _verSenha = false;
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _identificador.dispose();
    _senha.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_carregando) return;
    setState(() => _erro = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _carregando = true);
    final erro = await PacienteRepository.instance.entrar(
      identificador: _identificador.text,
      senha: _senha.text,
    );
    // Em caso de sucesso esta tela já foi trocada pela Home (não montada).
    if (!mounted) return;
    setState(() {
      _carregando = false;
      _erro = erro;
    });
  }

  Future<void> _acessoRapido() async {
    if (_carregando) return;
    setState(() {
      _carregando = true;
      _erro = null;
    });
    await PacienteRepository.instance.acessoRapido();
    if (!mounted) return;
    setState(() => _carregando = false);
  }

  void _criarConta() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (context) => const CadastroScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Positioned.fill(
            child: Column(
              children: [
                const AppHeader(
                  titulo: 'Agenda Fácil',
                  subtitulo: 'Consultas e exames do SUS',
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                    children: [
                      _CartaoLogin(
                        formKey: _formKey,
                        identificador: _identificador,
                        senha: _senha,
                        verSenha: _verSenha,
                        onAlternarSenha: () =>
                            setState(() => _verSenha = !_verSenha),
                        erro: _erro,
                        carregando: _carregando,
                        onEntrar: _entrar,
                      ),
                      const SizedBox(height: 20),
                      const _SeparadorOu(),
                      const SizedBox(height: 20),
                      BotaoApp(
                        rotulo: 'Criar minha conta',
                        icone: Icons.person_add_alt_1_outlined,
                        estilo: EstiloBotao.contorno,
                        onPressed: _carregando ? null : _criarConta,
                      ),
                      const SizedBox(height: 12),
                      _BotaoAcessoRapido(
                        onPressed: _carregando ? null : _acessoRapido,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Conta de demonstração: CPF 123.456.789-09 '
                        'e senha ${PacienteRepository.senhaDemo}.',
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

class _CartaoLogin extends StatelessWidget {
  const _CartaoLogin({
    required this.formKey,
    required this.identificador,
    required this.senha,
    required this.verSenha,
    required this.onAlternarSenha,
    required this.erro,
    required this.carregando,
    required this.onEntrar,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identificador;
  final TextEditingController senha;
  final bool verSenha;
  final VoidCallback onAlternarSenha;
  final String? erro;
  final bool carregando;
  final VoidCallback onEntrar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.azulBordaCard, width: 2),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text('Acesse sua conta', style: AppText.listaTitulo),
            ),
            const SizedBox(height: 2),
            Text(
              'Entre com seu CPF ou Cartão SUS e sua senha.',
              style: AppText.formAjuda,
            ),
            const SizedBox(height: 18),
            if (erro != null) ...[
              AvisoErro(texto: erro!),
              const SizedBox(height: 14),
            ],
            TextFormField(
              controller: identificador,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              inputFormatters: const [FormatoCpfOuCns()],
              style: AppText.campo,
              validator: Validadores.cpfOuCns,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: CampoDecoracao.criar(
                rotulo: 'CPF ou Cartão SUS',
                prefixo: const Icon(
                  Icons.badge_outlined,
                  color: AppColors.azulPrimario,
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: senha,
              obscureText: !verSenha,
              enableSuggestions: false,
              autocorrect: false,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onEntrar(),
              style: AppText.campo,
              validator: (valor) =>
                  (valor ?? '').isEmpty ? 'Informe sua senha.' : null,
              decoration: CampoDecoracao.criar(
                rotulo: 'Senha',
                prefixo: const Icon(
                  Icons.lock_outline,
                  color: AppColors.azulPrimario,
                ),
                sufixo: IconButton(
                  onPressed: onAlternarSenha,
                  tooltip: verSenha ? 'Ocultar senha' : 'Mostrar senha',
                  icon: Icon(
                    verSenha
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textoSecundario,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            BotaoApp(
              rotulo: carregando ? 'Entrando...' : 'Entrar',
              icone: carregando ? null : Icons.login,
              onPressed: carregando ? null : onEntrar,
            ),
          ],
        ),
      ),
    );
  }
}

class _SeparadorOu extends StatelessWidget {
  const _SeparadorOu();

  @override
  Widget build(BuildContext context) {
    const linha = Expanded(
      child: Divider(color: AppColors.azulBordaCard, thickness: 2, height: 2),
    );
    return Row(
      children: [
        linha,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('ou', style: AppText.formAjuda),
        ),
        linha,
      ],
    );
  }
}

/// Botão em destaque (degradê azul) que entra como a paciente de demonstração.
class _BotaoAcessoRapido extends StatelessWidget {
  const _BotaoAcessoRapido({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final habilitado = onPressed != null;

    return Semantics(
      button: true,
      enabled: habilitado,
      label: 'Acesso Rápido, Demo Banca',
      excludeSemantics: true,
      child: Opacity(
        opacity: habilitado ? 1 : 0.6,
        child: Material(
          color: Colors.transparent,
          clipBehavior: Clip.antiAlias,
          shape: const StadiumBorder(),
          child: Ink(
            decoration: const ShapeDecoration(
              shape: StadiumBorder(),
              gradient: LinearGradient(
                colors: [AppColors.azulHeader, AppColors.azulEscuro],
              ),
              shadows: [
                BoxShadow(
                  color: Color(0x33173B68),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: onPressed,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt, size: 22, color: Colors.white),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Acesso Rápido (Demo Banca)',
                          textAlign: TextAlign.center,
                          style: AppText.botao(Colors.white),
                        ),
                      ),
                    ],
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
