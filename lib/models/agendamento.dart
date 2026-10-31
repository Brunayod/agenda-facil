import 'unidade.dart';

/// Tipo de atendimento escolhido no formulário de novo agendamento.
enum TipoAtendimento {
  consulta('Consulta Médica', 'Especialidade'),
  exame('Exame Laboratorial', 'Exame'),
  vacinacao('Vacinação', 'Vacina'),
  receita('Renovação de Receita', 'Serviço');

  const TipoAtendimento(this.rotulo, this.rotuloServico);

  /// Nome exibido ao usuário.
  final String rotulo;

  /// Título da etapa "especialidade/serviço" para este tipo.
  final String rotuloServico;
}

enum StatusAgendamento {
  confirmado('Confirmado'),
  realizado('Realizado'),
  naoCompareceu('Não compareceu'),
  cancelado('Cancelado');

  const StatusAgendamento(this.rotulo);
  final String rotulo;
}

const _diasSemana = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];

class Agendamento {
  const Agendamento({
    required this.protocolo,
    required this.tipo,
    required this.servico,
    required this.unidade,
    required this.profissional,
    required this.dataHora,
    required this.status,
    required this.orientacoes,
  });

  /// Código único do agendamento (também usado como identificador).
  final String protocolo;
  final TipoAtendimento tipo;

  /// Especialidade, exame ou vacina (ex.: "Clínica Médica").
  final String servico;
  final Unidade unidade;
  final String profissional;
  final DateTime dataHora;
  final StatusAgendamento status;

  /// Orientações de preparo (ex.: "Jejum de 8 horas").
  final List<String> orientacoes;

  /// Título exibido nos cards.
  String get titulo => servico;

  bool get estaAtivo => status == StatusAgendamento.confirmado;

  String get dataFormatada =>
      '${_dois(dataHora.day)}/${_dois(dataHora.month)}/${dataHora.year}';

  String get horaFormatada =>
      '${_dois(dataHora.hour)}:${_dois(dataHora.minute)}';

  /// Ex.: "Sexta-feira, 10/10/2026 às 09:00".
  String get dataPorExtenso =>
      '${_diasSemana[dataHora.weekday - 1]}, $dataFormatada às $horaFormatada';

  Agendamento copyWith({DateTime? dataHora, StatusAgendamento? status}) {
    return Agendamento(
      protocolo: protocolo,
      tipo: tipo,
      servico: servico,
      unidade: unidade,
      profissional: profissional,
      dataHora: dataHora ?? this.dataHora,
      status: status ?? this.status,
      orientacoes: orientacoes,
    );
  }

  static String _dois(int n) => n.toString().padLeft(2, '0');
}
