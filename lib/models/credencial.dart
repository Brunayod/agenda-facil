import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Credencial de acesso de uma conta.
///
/// A senha nunca é guardada: só um hash SHA-256 com sal aleatório. Isto é
/// uma proteção básica para a versão local; na versão com servidor, a
/// autenticação deve ser feita no back-end.
class Credencial {
  const Credencial({
    required this.cpf,
    required this.cns,
    required this.sal,
    required this.hashSenha,
  });

  /// CPF e CNS somente com dígitos.
  final String cpf;
  final String cns;
  final String sal;
  final String hashSenha;

  factory Credencial.nova({
    required String cpf,
    required String cns,
    required String senha,
  }) {
    final aleatorio = Random.secure();
    final sal = base64UrlEncode(
      List<int>.generate(16, (_) => aleatorio.nextInt(256)),
    );
    return Credencial(
      cpf: cpf,
      cns: cns,
      sal: sal,
      hashSenha: _hash(sal, senha),
    );
  }

  bool confere(String senha) => _hash(sal, senha) == hashSenha;

  static String _hash(String sal, String senha) =>
      sha256.convert(utf8.encode('$sal:$senha')).toString();

  Map<String, dynamic> toJson() => {
        'cpf': cpf,
        'cns': cns,
        'sal': sal,
        'hashSenha': hashSenha,
      };

  factory Credencial.fromJson(Map<String, dynamic> json) => Credencial(
        cpf: json['cpf'] as String,
        cns: json['cns'] as String,
        sal: json['sal'] as String,
        hashSenha: json['hashSenha'] as String,
      );
}
