import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../data/agendamento_repository.dart';
import '../data/catalogo.dart';
import 'opcao_chip.dart';

/// Escolha de data (próximos dias úteis) e horário disponível.
///
/// Chama [onChanged] com a data/hora completa quando as duas escolhas estão
/// feitas, ou com `null` enquanto estiver incompleto.
/// [ignorarProtocolo] libera o horário do próprio agendamento ao reagendar.
class SeletorDataHora extends StatefulWidget {
  const SeletorDataHora({
    super.key,
    required this.onChanged,
    this.ignorarProtocolo,
  });

  final ValueChanged<DateTime?> onChanged;
  final String? ignorarProtocolo;

  @override
  State<SeletorDataHora> createState() => _SeletorDataHoraState();
}

class _SeletorDataHoraState extends State<SeletorDataHora> {
  late final List<DateTime> _dias = Catalogo.proximosDias();
  DateTime? _dia;
  TimeOfDay? _horario;

  DateTime _compor(DateTime dia, TimeOfDay hora) =>
      DateTime(dia.year, dia.month, dia.day, hora.hour, hora.minute);

  bool _disponivel(DateTime dia, TimeOfDay hora) =>
      AgendamentoRepository.instance.horarioDisponivel(
        _compor(dia, hora),
        ignorarProtocolo: widget.ignorarProtocolo,
      );

  void _notificar() {
    final dia = _dia;
    final hora = _horario;
    widget.onChanged(dia != null && hora != null ? _compor(dia, hora) : null);
  }

  void _selecionarDia(DateTime dia) {
    setState(() {
      _dia = dia;
      final hora = _horario;
      if (hora != null && !_disponivel(dia, hora)) _horario = null;
    });
    _notificar();
  }

  void _selecionarHorario(TimeOfDay hora) {
    setState(() => _horario = hora);
    _notificar();
  }

  @override
  Widget build(BuildContext context) {
    final dia = _dia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Data', style: AppText.formRotulo),
        const SizedBox(height: 8),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dias.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = _dias[index];
              return _ChipDia(
                dia: item,
                selecionado: dia == item,
                onTap: () => _selecionarDia(item),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text('Horário', style: AppText.formRotulo),
        const SizedBox(height: 8),
        if (dia == null)
          Text(
            'Escolha uma data para ver os horários disponíveis.',
            style: AppText.formAjuda,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final hora in Catalogo.horarios)
                OpcaoChip(
                  rotulo: Catalogo.formatarHora(hora),
                  selecionado: _horario == hora,
                  habilitado: _disponivel(dia, hora),
                  onTap: () => _selecionarHorario(hora),
                ),
            ],
          ),
      ],
    );
  }
}

class _ChipDia extends StatelessWidget {
  const _ChipDia({
    required this.dia,
    required this.selecionado,
    required this.onTap,
  });

  final DateTime dia;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fundo = selecionado ? AppColors.azulPrimario : Colors.white;
    final principal = selecionado ? Colors.white : AppColors.azulEscuro;
    final secundario = selecionado ? Colors.white : AppColors.textoSecundario;
    final semana = Catalogo.diaSemanaCurto(dia);
    final mes = Catalogo.mesCurto(dia);

    return Semantics(
      button: true,
      selected: selecionado,
      label: '$semana, ${dia.day} de $mes',
      excludeSemantics: true,
      child: Material(
        color: fundo,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: selecionado
              ? BorderSide.none
              : const BorderSide(color: AppColors.azulBordaCard, width: 2),
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 58,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(semana, style: AppText.diaSemana(secundario)),
                Text('${dia.day}', style: AppText.diaNumero(principal)),
                Text(mes, style: AppText.diaSemana(secundario)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
