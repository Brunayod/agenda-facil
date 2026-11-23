import 'package:flutter/material.dart';

import '../data/sessao_repository.dart';
import 'app_shell.dart';
import 'login_screen.dart';

/// Decide a tela inicial: app (com sessão ativa) ou login.
/// Troca sozinha quando a sessão muda (entrar / sair).
class AppRaiz extends StatelessWidget {
  const AppRaiz({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SessaoRepository.instance,
      builder: (context, _) => SessaoRepository.instance.logado
          ? const AppShell()
          : const LoginScreen(),
    );
  }
}
