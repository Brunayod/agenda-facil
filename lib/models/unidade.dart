/// Unidade de saúde (UBS) onde o atendimento acontece.
class Unidade {
  const Unidade({
    required this.id,
    required this.nome,
    required this.endereco,
  });

  final String id;
  final String nome;
  final String endereco;

  @override
  bool operator ==(Object other) => other is Unidade && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
