import 'package:shared_preferences/shared_preferences.dart';

/// Contrato de armazenamento chave-valor (texto) usado pelos repositórios.
///
/// Os repositórios só conhecem esta interface. Para sincronizar com um banco
/// em nuvem basta criar outra implementação (ou um repositório remoto) sem
/// mexer nas telas.
abstract interface class Armazenamento {
  Future<String?> ler(String chave);
  Future<void> gravar(String chave, String valor);
  Future<void> remover(String chave);
}

/// Armazenamento local (dispositivo ou navegador) via `shared_preferences`.
class ArmazenamentoLocal implements Armazenamento {
  ArmazenamentoLocal._(this._prefs);

  static const _prefixo = 'agenda_facil.';

  final SharedPreferences _prefs;

  static Future<ArmazenamentoLocal> criar() async =>
      ArmazenamentoLocal._(await SharedPreferences.getInstance());

  @override
  Future<String?> ler(String chave) async => _prefs.getString('$_prefixo$chave');

  @override
  Future<void> gravar(String chave, String valor) async {
    await _prefs.setString('$_prefixo$chave', valor);
  }

  @override
  Future<void> remover(String chave) async {
    await _prefs.remove('$_prefixo$chave');
  }
}

/// Armazenamento em memória, útil para testes automatizados.
class ArmazenamentoMemoria implements Armazenamento {
  final Map<String, String> _dados = {};

  @override
  Future<String?> ler(String chave) async => _dados[chave];

  @override
  Future<void> gravar(String chave, String valor) async {
    _dados[chave] = valor;
  }

  @override
  Future<void> remover(String chave) async {
    _dados.remove(chave);
  }
}

/// Nomes das chaves gravadas no armazenamento.
abstract final class ChavesArmazenamento {
  /// Lista de contas (credenciais) cadastradas neste dispositivo.
  static const contas = 'contas';

  /// CPF da conta com sessão ativa (ausente = deslogado).
  static const sessao = 'sessao';

  static String paciente(String cpf) => 'paciente.$cpf';

  static String agendamentos(String cpf) => 'agendamentos.$cpf';
}
