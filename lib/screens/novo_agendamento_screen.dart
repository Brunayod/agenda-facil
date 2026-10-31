import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../data/agendamento_repository.dart';
import '../data/catalogo.dart';
import '../models/agendamento.dart';
import '../models/unidade.dart';
import '../widgets/app_background.dart';
import '../widgets/app_header.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/botao_app.dart';
import '../widgets/opcao_chip.dart';
import '../widgets/seletor_data_hora.dart';
import '../widgets/tipo_atendimento_icone.dart';

/// Formulário de novo agendamento. Ao confirmar, fecha devolvendo o
/// [Agendamento] criado (ou `null` se o usuário voltar sem confirmar).
class NovoAgendamentoScreen extends StatefulWidget {
  const NovoAgendamentoScreen({super.key});

  @override
  State<NovoAgendamentoScreen> createState() => _NovoAgendamentoScreenState();
}

class _NovoAgendamentoScreenState extends State<NovoAgendamentoScreen> {
  TipoAtendimento? _tipo;
  String? _servico;
  Unidade? _unidade;
  DateTime? _dataHora;

  bool get _completo =>
      _tipo != null &&
      _servico != null &&
      _unidade != null &&
      _dataHora != null;

  void _selecionarTipo(TipoAtendimento tipo) {
    if (tipo == _tipo) return;
    setState(() {
      _tipo = tipo;
      _servico = null; // os serviços dependem do tipo
    });
  }

  void _confirmar() {
    final tipo = _tipo;
    final servico = _servico;
    final unidade = _unidade;
    final dataHora = _dataHora;
    if (tipo == null ||
        servico == null ||
        unidade == null ||
        dataHora == null) {
      return;
    }

    final repo = AgendamentoRepository.instance;
    if (!repo.horarioDisponivel(dataHora)) {
      AppSnackBar.mostrar(
        ScaffoldMessenger.of(context),
        'Esse horário não está mais disponível. Escolha outro.',
        icone: Icons.info_outline,
      );
      return;
    }

    final novo = repo.adicionar(
      tipo: tipo,
      servico: servico,
      unidade: unidade,
      dataHora: dataHora,
    );
    Navigator.of(context).pop(novo);
  }

  @override
  Widget build(BuildContext context) {
    final tipo = _tipo;
    final inferior = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Positioned.fill(
            child: Column(
              children: [
                AppHeader(
                  titulo: 'Novo agendamento',
                  onVoltar: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    children: [
                      _Secao(
                        numero: 1,
                        titulo: 'Tipo de atendimento',
                        child: _GradeTipos(
                          selecionado: tipo,
                          onSelecionar: _selecionarTipo,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _Secao(
                        numero: 2,
                        titulo: tipo?.rotuloServico ?? 'Especialidade / serviço',
                        child: tipo == null
                            ? Text(
                                'Escolha o tipo de atendimento primeiro.',
                                style: AppText.formAjuda,
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final servico
                                      in Catalogo.servicosDe(tipo))
                                    OpcaoChip(
                                      rotulo: servico,
                                      selecionado: _servico == servico,
                                      onTap: () =>
                                          setState(() => _servico = servico),
                                    ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 24),
                      _Secao(
                        numero: 3,
                        titulo: 'Unidade',
                        child: Column(
                          children: [
                            for (final unidade in Catalogo.unidades)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _TileUnidade(
                                  unidade: unidade,
                                  selecionada: _unidade == unidade,
                                  onTap: () =>
                                      setState(() => _unidade = unidade),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _Secao(
                        numero: 4,
                        titulo: 'Data e horário',
                        child: SeletorDataHora(
                          onChanged: (valor) =>
                              setState(() => _dataHora = valor),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + inferior),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A173B68),
                        blurRadius: 12,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: BotaoApp(
                    rotulo: 'Confirmar Agendamento',
                    icone: Icons.check,
                    onPressed: _completo ? _confirmar : null,
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

/// Título numerado + conteúdo de uma etapa do formulário.
class _Secao extends StatelessWidget {
  const _Secao({
    required this.numero,
    required this.titulo,
    required this.child,
  });

  final int numero;
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.azulPrimario,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$numero',
                style: AppText.opcao(Colors.white, peso: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(titulo, style: AppText.formSecao),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

/// Grade 2x2 com os tipos de atendimento.
class _GradeTipos extends StatelessWidget {
  const _GradeTipos({required this.selecionado, required this.onSelecionar});

  final TipoAtendimento? selecionado;
  final ValueChanged<TipoAtendimento> onSelecionar;

  @override
  Widget build(BuildContext context) {
    final tipos = TipoAtendimento.values;

    Widget linha(TipoAtendimento a, TipoAtendimento b) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _TileTipo(
                tipo: a,
                selecionado: selecionado == a,
                onTap: () => onSelecionar(a),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _TileTipo(
                tipo: b,
                selecionado: selecionado == b,
                onTap: () => onSelecionar(b),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        linha(tipos[0], tipos[1]),
        const SizedBox(height: 10),
        linha(tipos[2], tipos[3]),
      ],
    );
  }
}

class _TileTipo extends StatelessWidget {
  const _TileTipo({
    required this.tipo,
    required this.selecionado,
    required this.onTap,
  });

  final TipoAtendimento tipo;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      label: tipo.rotulo,
      excludeSemantics: true,
      child: Material(
        color: selecionado ? AppColors.azulAbaInativa : Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                selecionado ? AppColors.azulPrimario : AppColors.azulBordaCard,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(tipo.icone, width: 44, height: 44),
                const SizedBox(height: 6),
                Text(
                  tipo.rotulo,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: AppText.opcao(
                    AppColors.azulEscuro,
                    peso: selecionado ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TileUnidade extends StatelessWidget {
  const _TileUnidade({
    required this.unidade,
    required this.selecionada,
    required this.onTap,
  });

  final Unidade unidade;
  final bool selecionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionada,
      label: '${unidade.nome}, ${unidade.endereco}',
      excludeSemantics: true,
      child: Material(
        color: selecionada ? AppColors.azulAbaInativa : Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                selecionada ? AppColors.azulPrimario : AppColors.azulBordaCard,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  selecionada
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.azulPrimario,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unidade.nome,
                        style: AppText.opcao(
                          AppColors.azulEscuro,
                          peso: FontWeight.w600,
                        ),
                      ),
                      Text(unidade.endereco, style: AppText.formAjuda),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
