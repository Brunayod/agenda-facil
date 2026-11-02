/// Tamanho de texto escolhido nas preferências de acessibilidade.
enum TamanhoTexto {
  normal('Normal', 1.0),
  grande('Grande', 1.15),
  muitoGrande('Muito grande', 1.3);

  const TamanhoTexto(this.rotulo, this.fator);

  final String rotulo;

  /// Multiplicador aplicado a todos os textos do app.
  final double fator;
}

/// Dados do paciente (cidadão) logado.
class Paciente {
  const Paciente({
    required this.nome,
    required this.cns,
    required this.cpf,
    required this.dataNascimento,
    required this.tipoSanguineo,
    required this.telefone,
    required this.email,
    required this.endereco,
    required this.unidadeReferenciaId,
    required this.alergias,
    required this.condicoes,
    this.lembretesAtivos = true,
    this.tamanhoTexto = TamanhoTexto.normal,
  });

  /// Valor do endereço quando o paciente se cadastra sem informá-lo.
  static const enderecoNaoInformado = 'Não informado';

  final String nome;

  /// Cartão Nacional de Saúde: 15 dígitos, sem formatação.
  final String cns;

  /// CPF: 11 dígitos, sem formatação.
  final String cpf;
  final DateTime dataNascimento;

  /// Ex.: "O+".
  final String tipoSanguineo;
  final String telefone;
  final String email;
  final String endereco;

  /// `id` da UBS de referência (ver `Catalogo.unidades`).
  final String unidadeReferenciaId;
  final List<String> alergias;
  final List<String> condicoes;

  // Preferências
  final bool lembretesAtivos;
  final TamanhoTexto tamanhoTexto;

  String get primeiroNome => nome.trim().split(' ').first;

  /// Ex.: "700 1234 5678 9012".
  String get cnsFormatado {
    if (cns.length != 15) return cns;
    return '${cns.substring(0, 3)} ${cns.substring(3, 7)} '
        '${cns.substring(7, 11)} ${cns.substring(11)}';
  }

  /// Ex.: "123.456.789-09".
  String get cpfFormatado {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.'
        '${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  /// Ex.: "14/05/1998".
  String get dataNascimentoFormatada =>
      '${_dois(dataNascimento.day)}/${_dois(dataNascimento.month)}/'
      '${dataNascimento.year}';

  Paciente copyWith({
    String? nome,
    String? tipoSanguineo,
    String? telefone,
    String? email,
    String? endereco,
    String? unidadeReferenciaId,
    List<String>? alergias,
    List<String>? condicoes,
    bool? lembretesAtivos,
    TamanhoTexto? tamanhoTexto,
  }) {
    return Paciente(
      nome: nome ?? this.nome,
      cns: cns,
      cpf: cpf,
      dataNascimento: dataNascimento,
      tipoSanguineo: tipoSanguineo ?? this.tipoSanguineo,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      endereco: endereco ?? this.endereco,
      unidadeReferenciaId: unidadeReferenciaId ?? this.unidadeReferenciaId,
      alergias: alergias ?? this.alergias,
      condicoes: condicoes ?? this.condicoes,
      lembretesAtivos: lembretesAtivos ?? this.lembretesAtivos,
      tamanhoTexto: tamanhoTexto ?? this.tamanhoTexto,
    );
  }

  /// Converte para um mapa pronto para `jsonEncode` / banco de dados.
  Map<String, dynamic> toJson() => {
        'nome': nome,
        'cns': cns,
        'cpf': cpf,
        'dataNascimento': dataNascimento.toIso8601String(),
        'tipoSanguineo': tipoSanguineo,
        'telefone': telefone,
        'email': email,
        'endereco': endereco,
        'unidadeReferenciaId': unidadeReferenciaId,
        'alergias': alergias,
        'condicoes': condicoes,
        'lembretesAtivos': lembretesAtivos,
        'tamanhoTexto': tamanhoTexto.name,
      };

  factory Paciente.fromJson(Map<String, dynamic> json) => Paciente(
        nome: json['nome'] as String,
        cns: json['cns'] as String,
        cpf: json['cpf'] as String,
        dataNascimento: DateTime.parse(json['dataNascimento'] as String),
        tipoSanguineo: json['tipoSanguineo'] as String,
        telefone: json['telefone'] as String,
        email: json['email'] as String,
        endereco: json['endereco'] as String,
        unidadeReferenciaId: json['unidadeReferenciaId'] as String,
        alergias: List<String>.from(json['alergias'] as List),
        condicoes: List<String>.from(json['condicoes'] as List),
        lembretesAtivos: json['lembretesAtivos'] as bool? ?? true,
        tamanhoTexto: TamanhoTexto.values
            .byName(json['tamanhoTexto'] as String? ?? 'normal'),
      );

  static String _dois(int n) => n.toString().padLeft(2, '0');
}
