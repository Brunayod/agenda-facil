import 'package:flutter/material.dart';

import '../data/paciente_repository.dart';
import '../models/agendamento.dart';
import '../models/unidade.dart';
import '../widgets/abas_agenda.dart';
import '../widgets/app_background.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/app_snack_bar.dart';
import 'home_screen.dart';
import 'meus_agendamentos_screen.dart';
import 'novo_agendamento_screen.dart';
import 'perfil_screen.dart';
import 'rede_screen.dart';

/// Estrutura fixa do app: fundo decorativo + página atual + barra inferior.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Índices das abas da barra inferior (mesma ordem do IndexedStack;
  // Perfil é o índice 3 e só é acessado pela própria barra).
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

  /// Abre o formulário de novo agendamento. Com [unidade], a UBS já vem
  /// selecionada (usado pelo botão "Agendar nesta unidade" da aba Rede).
  Future<void> _novoAgendamento({Unidade? unidade}) async {
    final messenger = ScaffoldMessenger.of(context);
    final criado = await Navigator.of(context).push<Agendamento>(
      MaterialPageRoute(
        builder: (context) => NovoAgendamentoScreen(unidadeInicial: unidade),
      ),
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
                      ListenableBuilder(
                        listenable: PacienteRepository.instance,
                        builder: (context, _) => HomeScreen(
                          nomeUsuario:
                              PacienteRepository.instance.paciente.primeiroNome,
                          onNovaConsulta: _novoAgendamento,
                          onMeusAgendamentos: () => _ir(_agenda),
                          onRedeDeSaude: () => _ir(_rede),
                        ),
                      ),
                      MeusAgendamentosScreen(
                        aba: _abaAgenda,
                        onVoltar: () => _ir(_inicio),
                      ),
                      RedeScreen(
                        onVoltar: () => _ir(_inicio),
                        onAgendar: (unidade) =>
                            _novoAgendamento(unidade: unidade),
                      ),
                      PerfilScreen(onVoltar: () => _ir(_inicio)),
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
