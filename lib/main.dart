import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'data/catalogo.dart';
import 'data/paciente_repository.dart';
import 'data/sessao_repository.dart';
import 'data/supabase_config.dart';
import 'screens/app_raiz.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Android
      statusBarBrightness: Brightness.dark, // iOS
    ),
  );

  // Conecta ao Supabase (a sessão do usuário é restaurada automaticamente).
  await SupabaseConfig.inicializar();

  // Unidades, serviços e horários vêm do banco (com dados de exemplo se
  // estiver sem internet).
  await Catalogo.carregar();

  // Se já havia login salvo, carrega o paciente e os agendamentos.
  await SessaoRepository.instance.inicializar();

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
      // somada à escala de fonte do sistema (só com sessão ativa).
      builder: (context, child) {
        return ListenableBuilder(
          listenable: Listenable.merge([
            SessaoRepository.instance,
            PacienteRepository.instance,
          ]),
          builder: (context, _) {
            final sessao = SessaoRepository.instance;
            final pacientes = PacienteRepository.instance;
            final fator = sessao.logado && pacientes.temPaciente
                ? pacientes.paciente.tamanhoTexto.fator
                : 1.0;

            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(
                textScaler: TextScaler.linear(media.textScaler.scale(1) * fator),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
      home: const AppRaiz(),
    );
  }
}
