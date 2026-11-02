import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'data/paciente_repository.dart';
import 'screens/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );
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
            final fator = PacienteRepository.instance.paciente.tamanhoTexto.fator;
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
      home: const AppShell(),
    );
  }
}
