import 'tipo_atendimento.dart';
import 'unidade.dart';

// Quem importa o modelo de agendamento também enxerga TipoAtendimento.
export 'tipo_atendimento.dart';

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

  /// Converte para um mapa pronto para `jsonEncode` / banco de dados.
  Map<String, dynamic> toJson() => {
        'protocolo': protocolo,
        'tipo': tipo.name,
        'servico': servico,
        'unidade': unidade.toJson(),
        'profissional': profissional,
        'dataHora': dataHora.toIso8601String(),
        'status': status.name,
        'orientacoes': orientacoes,
      };

  factory Agendamento.fromJson(Map<String, dynamic> json) => Agendamento(
        protocolo: json['protocolo'] as String,
        tipo: TipoAtendimento.values.byName(json['tipo'] as String),
        servico: json['servico'] as String,
        unidade: Unidade.fromJson(json['unidade'] as Map<String, dynamic>),
        profissional: json['profissional'] as String,
        dataHora: DateTime.parse(json['dataHora'] as String),
        status: StatusAgendamento.values.byName(json['status'] as String),
        orientacoes: List<String>.from(json['orientacoes'] as List),
      );

  static String _dois(int n) => n.toString().padLeft(2, '0');
}
