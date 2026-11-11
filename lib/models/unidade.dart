import 'profissional.dart';
import 'tipo_atendimento.dart';

/// Unidade de saúde (UBS) da rede.
class Unidade {
  const Unidade({
    required this.id,
    required this.nome,
    required this.bairro,
    required this.endereco,
    required this.horarioFuncionamento,
    required this.telefone,
    required this.latitude,
    required this.longitude,
    required this.servicos,
    required this.profissionais,
    this.distanciaKm,
  });

  final String id;
  final String nome;
  final String bairro;
  final String endereco;

  /// Ex.: "Seg a Sex • 07h às 19h".
  final String horarioFuncionamento;
  final String telefone;

  /// Coordenadas da UBS (graus decimais). `0, 0` = sem coordenadas.
  final double latitude;
  final double longitude;

  /// Distância simulada (legado), usada só para ordenar a lista enquanto o
  /// GPS do usuário não está disponível. A distância real é calculada a
  /// partir de [latitude] e [longitude] (ver `LocalizacaoRepository`).
  final double? distanciaKm;

  /// Tipos de atendimento oferecidos.
  final List<TipoAtendimento> servicos;
  final List<Profissional> profissionais;

  bool oferece(TipoAtendimento tipo) => servicos.contains(tipo);

  /// `false` quando a UBS ainda não tem coordenadas cadastradas.
  bool get temCoordenadas => !(latitude == 0 && longitude == 0);

  /// Ex.: "0,8 km".
  static String formatarKm(double km) {
    if (km < 0.1) return '< 0,1 km';
    return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  /// Especialidades atendidas na unidade.
  Set<String> get especialidades =>
      profissionais.map((p) => p.especialidade).toSet();

  @override
  bool operator ==(Object other) => other is Unidade && other.id == id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'bairro': bairro,
        'endereco': endereco,
        'horarioFuncionamento': horarioFuncionamento,
        'telefone': telefone,
        'latitude': latitude,
        'longitude': longitude,
        'distanciaKm': distanciaKm,
        'servicos': servicos.map((s) => s.name).toList(),
        'profissionais': profissionais.map((p) => p.toJson()).toList(),
      };

  factory Unidade.fromJson(Map<String, dynamic> json) => Unidade(
        id: json['id'] as String,
        nome: json['nome'] as String,
        bairro: json['bairro'] as String,
        endereco: json['endereco'] as String,
        horarioFuncionamento: json['horarioFuncionamento'] as String,
        telefone: json['telefone'] as String,
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        distanciaKm: (json['distanciaKm'] as num?)?.toDouble(),
        servicos: (json['servicos'] as List)
            .map((s) => TipoAtendimento.values.byName(s as String))
            .toList(),
        profissionais: (json['profissionais'] as List)
            .map((p) => Profissional.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}
