import 'package:flutter/foundation.dart';

import '../models/paciente.dart';

/// Repositório em memória (singleton) com os dados do paciente.
///
/// É um [ChangeNotifier]: telas reagem às mudanças com `ListenableBuilder`.
/// Os dados somem ao fechar o app; para persistir, use
/// `paciente.toJson()` / `Paciente.fromJson()` com o armazenamento escolhido.
class PacienteRepository extends ChangeNotifier {
  PacienteRepository._();

  static final PacienteRepository instance = PacienteRepository._();

  // Dados de exemplo (fictícios).
  Paciente _paciente = Paciente(
    nome: 'Jheniffer Almeida Santos',
    cns: '700123456789012',
    cpf: '12345678909',
    dataNascimento: DateTime(1998, 5, 14),
    tipoSanguineo: 'O+',
    telefone: '(11) 98765-4321',
    email: 'jheniffer.santos@email.com',
    endereco: 'Rua das Flores, 120 - Vila Mariana, São Paulo - SP',
    unidadeReferenciaId: 'vila-mariana',
    alergias: const ['Dipirona'],
    condicoes: const ['Rinite'],
  );

  Paciente get paciente => _paciente;

  /// Substitui os dados cadastrais (usado pelo formulário "Editar dados").
  void atualizar(Paciente novo) {
    _paciente = novo;
    notifyListeners();
  }

  // ----- Alergias e condições -----

  /// Devolve `false` se o texto for vazio ou já existir na lista.
  bool adicionarAlergia(String item) {
    final texto = item.trim();
    if (texto.isEmpty || _contem(_paciente.alergias, texto)) return false;
    _paciente = _paciente.copyWith(alergias: [..._paciente.alergias, texto]);
    notifyListeners();
    return true;
  }

  void removerAlergia(String item) {
    _paciente = _paciente.copyWith(
      alergias: _paciente.alergias.where((a) => a != item).toList(),
    );
    notifyListeners();
  }

  /// Devolve `false` se o texto for vazio ou já existir na lista.
  bool adicionarCondicao(String item) {
    final texto = item.trim();
    if (texto.isEmpty || _contem(_paciente.condicoes, texto)) return false;
    _paciente = _paciente.copyWith(condicoes: [..._paciente.condicoes, texto]);
    notifyListeners();
    return true;
  }

  void removerCondicao(String item) {
    _paciente = _paciente.copyWith(
      condicoes: _paciente.condicoes.where((c) => c != item).toList(),
    );
    notifyListeners();
  }

  // ----- Preferências -----

  void definirLembretes(bool ativos) {
    _paciente = _paciente.copyWith(lembretesAtivos: ativos);
    notifyListeners();
  }

  void definirTamanhoTexto(TamanhoTexto tamanho) {
    _paciente = _paciente.copyWith(tamanhoTexto: tamanho);
    notifyListeners();
  }

  static bool _contem(List<String> lista, String texto) {
    final alvo = texto.toLowerCase();
    return lista.any((item) => item.toLowerCase() == alvo);
  }
}
