import 'package:flutter/material.dart';

import '../core/app_assets.dart';
import '../core/app_text.dart';
import '../widgets/app_header.dart';
import '../widgets/menu_card.dart';

/// Tela 1 — Home ("Minha saúde").
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.nomeUsuario,
    required this.onNovaConsulta,
    required this.onMeusAgendamentos,
    required this.onRedeDeSaude,
  });

  final String nomeUsuario;
  final VoidCallback onNovaConsulta;
  final VoidCallback onMeusAgendamentos;
  final VoidCallback onRedeDeSaude;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(
          titulo: 'Olá $nomeUsuario',
          subtitulo: 'Bem-vindo ao Agenda fácil',
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(11, 27, 11, 16),
            children: [
              Center(child: Text('Minha saúde', style: AppText.tituloSecao)),
              const SizedBox(height: 18),
              MenuCard(
                icone: AppAssets.homeNovaConsulta,
                titulo: 'Novas consultas',
                subtitulo: 'Agende sua consulta\ncom um profissional de saúde.',
                onTap: onNovaConsulta,
              ),
              const SizedBox(height: 8),
              MenuCard(
                icone: AppAssets.homeAgendamentos,
                titulo: 'Meus agendamentos',
                subtitulo: 'Acesse seus agendamentos atuais.',
                onTap: onMeusAgendamentos,
              ),
              const SizedBox(height: 8),
              MenuCard(
                icone: AppAssets.homeRede,
                titulo: 'Rede de saúde',
                subtitulo: 'Saiba as unidades perto de você.',
                onTap: onRedeDeSaude,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
