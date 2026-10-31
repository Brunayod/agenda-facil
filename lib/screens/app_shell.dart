import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../widgets/abas_agenda.dart';
import '../widgets/app_background.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_snack_bar.dart';
import 'em_construcao_screen.dart';
import 'home_screen.dart';
import 'meus_agendamentos_screen.dart';
import 'novo_agendamento_screen.dart';

/// Estrutura fixa do app: fundo decorativo + página atual + barra inferior.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Índices das abas da barra inferior (Perfil = 3, última página da pilha).
  static const _inicio = 0;
  static const _agenda = 1;
  static const _rede = 2;

  int _indice = _inicio;

  /// Aba exibida em "Meus agendamentos" (Agenda ativa ou Histórico).
  final ValueNotifier<AbaAgenda> _abaAgenda = ValueNotifier(AbaAgenda.ativa);

  @override
  void dispose() {
    _abaAgenda.dispose();
    super.dispose();
  }

  void _ir(int indice) => setState(() => _indice = indice);

  Future<void> _novoAgendamento() async {
    final messenger = ScaffoldMessenger.of(context);
    final criado = await Navigator.of(context).push<Agendamento>(
      MaterialPageRoute(builder: (context) => const NovoAgendamentoScreen()),
    );
    if (criado == null || !mounted) return;

    _abaAgenda.value = AbaAgenda.ativa;
    _ir(_agenda);
    AppSnackBar.mostrar(
      messenger,
      'Agendamento confirmado: ${criado.titulo}, '
      '${criado.dataFormatada} às ${criado.horaFormatada}.',
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
                Expanded(
                  child: IndexedStack(
                    index: _indice,
                    children: [
                      HomeScreen(
                        nomeUsuario: 'Jheniffer',
                        onNovaConsulta: _novoAgendamento,
                        onMeusAgendamentos: () => _ir(_agenda),
                        onRedeDeSaude: () => _ir(_rede),
                      ),
                      MeusAgendamentosScreen(
                        aba: _abaAgenda,
                        onVoltar: () => _ir(_inicio),
                      ),
                      EmConstrucaoScreen(
                        titulo: 'Rede de saúde',
                        onVoltar: () => _ir(_inicio),
                      ),
                      EmConstrucaoScreen(
                        titulo: 'Perfil',
                        onVoltar: () => _ir(_inicio),
                      ),
                    ],
                  ),
                ),
                AppBottomNav(
                  indiceAtual: _indice,
                  onSelecionar: _ir,
                  onBotaoCentral: _novoAgendamento,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
