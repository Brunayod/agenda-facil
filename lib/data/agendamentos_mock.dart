import '../models/agendamento.dart';

/// Dados de exemplo do protótipo. Substitua por API/repositório quando existir.
abstract final class AgendamentosMock {
  static final List<Agendamento> ativos = [
    Agendamento(
      tipo: TipoAgendamento.clinicaMedica,
      titulo: 'Clínica Médica',
      unidade: 'UBS Vila Mariana',
      dataHora: DateTime(2026, 10, 10, 9, 0),
      status: StatusAgendamento.confirmado,
    ),
    Agendamento(
      tipo: TipoAgendamento.vacinacao,
      titulo: 'Vacinação',
      unidade: 'UBS Vila Mariana',
      dataHora: DateTime(2026, 9, 28, 11, 0),
      status: StatusAgendamento.confirmado,
    ),
    Agendamento(
      tipo: TipoAgendamento.exame,
      titulo: 'Exame laboratorial',
      unidade: 'UBS Vila Mariana',
      dataHora: DateTime(2026, 10, 1, 15, 0),
      status: StatusAgendamento.confirmado,
    ),
  ];

  static final List<Agendamento> historico = [
    Agendamento(
      tipo: TipoAgendamento.clinicaMedica,
      titulo: 'Clínica Médica',
      unidade: 'UBS Vila Mariana',
      dataHora: DateTime(2026, 7, 17, 10, 0),
      status: StatusAgendamento.realizado,
    ),
    Agendamento(
      tipo: TipoAgendamento.vacinacao,
      titulo: 'Vacinação',
      unidade: 'UBS Vila Mariana',
      dataHora: DateTime(2026, 5, 12, 16, 0),
      status: StatusAgendamento.realizado,
    ),
    Agendamento(
      tipo: TipoAgendamento.exame,
      titulo: 'Exame laboratorial',
      unidade: 'UBS Vila Mariana',
      dataHora: DateTime(2026, 7, 8, 7, 0),
      status: StatusAgendamento.naoCompareceu,
    ),
  ];
}
