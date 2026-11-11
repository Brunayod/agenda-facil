import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/paciente.dart';
import 'cache_local.dart';
import 'erros.dart';
import 'supabase_config.dart';

/// Repositório (singleton) dos dados do paciente com sessão ativa.
///
/// É um [ChangeNotifier]: as telas reagem com `ListenableBuilder`. Cada
/// alteração aparece na interface na hora e é gravada na tabela `pacientes`
/// do Supabase. Se a gravação falhar, a alteração é desfeita e o erro é
/// lançado (as telas mostram a mensagem com `mensagemDeErro`).
class PacienteRepository extends ChangeNotifier {
  PacienteRepository._();

  static final PacienteRepository instance = PacienteRepository._();

  Paciente? _paciente;

  bool get temPaciente => _paciente != null;

  /// Paciente com sessão ativa. Só use depois do login.
  Paciente get paciente {
    final atual = _paciente;
    if (atual == null) {
      throw StateError('Nenhum paciente carregado. Faça login primeiro.');
    }
    return atual;
  }

  /// Carrega os dados do usuário autenticado. Lança se não houver sessão ou
  /// se o paciente não existir (a política RLS só devolve a própria linha).
  Future<void> carregar() async {
    final usuario = supabase.auth.currentUser;
    if (usuario == null) throw StateError('Sem sessão ativa.');

    try {
      final linha = await supabase
          .from('pacientes')
          .select()
          .eq('id', usuario.id)
          .single();

      _paciente = _dePostgrest(linha);
      await CacheLocal.salvar('paciente', usuario.id, _paciente!.toJson());
    } catch (erro) {
      // Erro do banco (RLS, linha ausente...) deve aparecer: não usa cache.
      // Já falha de rede cai na cópia local, se existir.
      if (erro is PostgrestException) rethrow;
      final copia = await CacheLocal.ler('paciente', usuario.id);
      if (copia is! Map<String, dynamic>) rethrow;
      debugPrint('PacienteRepository: sem conexão ($erro); usando cópia local.');
      _paciente = Paciente.fromJson(copia);
    }
    notifyListeners();
  }

  /// Esquece os dados (ao sair ou excluir a conta).
  void limpar() {
    _paciente = null;
    notifyListeners();
  }

  /// Substitui os dados editáveis (formulário "Editar dados" e preferências).
  /// CPF, CNS e data de nascimento são imutáveis no banco.
  Future<void> atualizar(Paciente novo) async {
    final anterior = _paciente;
    final usuario = supabase.auth.currentUser;
    if (usuario == null) throw StateError('Sem sessão ativa.');

    _paciente = novo;
    notifyListeners();

    try {
      await supabase.from('pacientes').update({
        'nome': novo.nome,
        'tipo_sanguineo':
            novo.tipoSanguineo.isEmpty ? null : novo.tipoSanguineo,
        'telefone': novo.telefone,
        'email': novo.email,
        'endereco': novo.endereco,
        'unidade_referencia_id': novo.unidadeReferenciaId,
        'alergias': novo.alergias,
        'condicoes': novo.condicoes,
        'lembretes_ativos': novo.lembretesAtivos,
        'tamanho_texto': novo.tamanhoTexto.name,
      }).eq('id', usuario.id);
      await CacheLocal.salvar('paciente', usuario.id, novo.toJson());
    } catch (erro) {
      registrarErro(erro);
      debugPrint('PacienteRepository: falha ao salvar; alteração desfeita.');
      _paciente = anterior;
      notifyListeners();
      rethrow;
    }
  }

  // ----- Alergias e condições -----

  /// Devolve `false` se o texto for vazio ou já existir na lista.
  Future<bool> adicionarAlergia(String item) async {
    final texto = item.trim();
    if (texto.isEmpty || _contem(paciente.alergias, texto)) return false;
    await atualizar(paciente.copyWith(alergias: [...paciente.alergias, texto]));
    return true;
  }

  Future<void> removerAlergia(String item) => atualizar(
        paciente.copyWith(
          alergias: paciente.alergias.where((a) => a != item).toList(),
        ),
      );

  /// Devolve `false` se o texto for vazio ou já existir na lista.
  Future<bool> adicionarCondicao(String item) async {
    final texto = item.trim();
    if (texto.isEmpty || _contem(paciente.condicoes, texto)) return false;
    await atualizar(
      paciente.copyWith(condicoes: [...paciente.condicoes, texto]),
    );
    return true;
  }

  Future<void> removerCondicao(String item) => atualizar(
        paciente.copyWith(
          condicoes: paciente.condicoes.where((c) => c != item).toList(),
        ),
      );

  // ----- Preferências -----

  Future<void> definirLembretes(bool ativos) =>
      atualizar(paciente.copyWith(lembretesAtivos: ativos));

  Future<void> definirTamanhoTexto(TamanhoTexto tamanho) =>
      atualizar(paciente.copyWith(tamanhoTexto: tamanho));

  static Paciente _dePostgrest(Map<String, dynamic> m) => Paciente(
        nome: m['nome'] as String,
        cns: m['cns'] as String,
        cpf: m['cpf'] as String,
        // Coluna `date` chega como "1998-05-14".
        dataNascimento: DateTime.parse(m['data_nascimento'] as String),
        tipoSanguineo: (m['tipo_sanguineo'] as String?) ?? '',
        telefone: m['telefone'] as String,
        email: m['email'] as String,
        endereco: m['endereco'] as String,
        unidadeReferenciaId: m['unidade_referencia_id'] as String,
        alergias: List<String>.from(m['alergias'] as List? ?? const []),
        condicoes: List<String>.from(m['condicoes'] as List? ?? const []),
        lembretesAtivos: m['lembretes_ativos'] as bool? ?? true,
        tamanhoTexto: TamanhoTexto.values
            .byName(m['tamanho_texto'] as String? ?? 'normal'),
      );

  static bool _contem(List<String> lista, String texto) {
    final alvo = texto.toLowerCase();
    return lista.any((item) => item.toLowerCase() == alvo);
  }
}
