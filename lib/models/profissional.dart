/// Profissional (ou equipe) que atende em uma unidade.
class Profissional {
  const Profissional({required this.nome, required this.especialidade});

  final String nome;
  final String especialidade;

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'especialidade': especialidade,
      };

  factory Profissional.fromJson(Map<String, dynamic> json) => Profissional(
        nome: json['nome'] as String,
        especialidade: json['especialidade'] as String,
      );
}
