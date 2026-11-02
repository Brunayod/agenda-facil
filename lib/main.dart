import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'data/paciente_repository.dart';
import 'screens/app_shell.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );
  // Lê contas, sessão e agendamentos salvos antes de desenhar a primeira tela.
  await PacienteRepository.instance.carregar();
  runApp(const AgendaFacilApp());
}

class AgendaFacilApp extends StatelessWidget {
  const AgendaFacilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Fácil',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Aplica a preferência "Tamanho do texto" do perfil em todo o app,
      // somada à escala de fonte do sistema.
      builder: (context, child) {
        return ListenableBuilder(
          listenable: PacienteRepository.instance,
          builder: (context, _) {
            final media = MediaQuery.of(context);
            final fator = PacienteRepository.instance.tamanhoTexto.fator;
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(
                  media.textScaler.scale(1) * fator,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
      home: const _PortaDeEntrada(),
    );
  }
}

/// Decide a tela inicial pela sessão: logado vê o app, deslogado vê o login.
/// Ao entrar ou sair, a troca acontece sozinha (o repositório avisa).
class _PortaDeEntrada extends StatelessWidget {
  const _PortaDeEntrada();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PacienteRepository.instance,
      builder: (context, _) {
        // Troca direta (sem animação): ao sair, o AppShell precisa sumir na
        // hora, pois suas telas só funcionam com um paciente logado.
        return PacienteRepository.instance.logado
            ? const AppShell()
            : const LoginScreen();
      },
    );
  }
}
