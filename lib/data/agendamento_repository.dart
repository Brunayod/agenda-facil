import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/agendamento.dart';
import '../models/unidade.dart';
import 'cache_local.dart';
import 'catalogo.dart';
import 'erros.dart';
import 'supabase_config.dart';

/// Repositório (singleton) dos agendamentos do paciente com sessão ativa.
///
/// É um [ChangeNotifier]: telas com `ListenableBuilder` são reconstruídas ao
/// adicionar, cancelar ou reagendar. Os dados ficam na tabela `agendamentos`
/// do Supabase; o protocolo e o status inicial são definidos pelo banco.
/// Erros (regras dos triggers, rede) são lançados para a tela tratar.
class AgendamentoRepository extends ChangeNotifier {
  AgendamentoRepository._();

  static final AgendamentoRepository instance = AgendamentoRepository._();

  /// Agendamento + nome do serviço, orientações e profissional.
  /// (A unidade vem do [Catalogo], pois não há FK direta para `unidades`.)
  static const _colunas = '*, servicos(nome, orientacoes), profissionais(nome)';

  final List<Agendamento> _itens = [];

  /// Carrega os agendamentos do usuário autenticado (a RLS filtra).
  Future<void> carregar() async {
    final usuarioId = supabase.auth.currentUser?.id;
    try {
      final linhas = await supabase
          .from('agendamentos')
          .select(_colunas)
          .order('data_hora', ascending: true);

      _itens
        ..clear()
        ..addAll(linhas.map(_dePostgrest));
      await _salvarCache();
    } catch (erro) {
      // Erro do banco (RLS, coluna...) deve aparecer; só falha de rede cai
      // na cópia local.
      if (erro is PostgrestException || usuarioId == null) rethrow;
      final copia = await CacheLocal.ler('agendamentos', usuarioId);
      if (copia is! List) rethrow;
      debugPrint(
        'AgendamentoRepository: sem conexão ($erro); usando cópia local.',
      );
      _itens
        ..clear()
        ..addAll(
          copia.map((e) => Agendamento.fromJson(e as Map<String, dynamic>)),
        );
    }
    notifyListeners();
  }

  Future<void> _salvarCache() async {
    final usuarioId = supabase.auth.currentUser?.id;
    if (usuarioId == null) return;
    await CacheLocal.salvar(
      'agendamentos',
      usuarioId,
      _itens.map((a) => a.toJson()).toList(),
    );
  }

  /// Esquece os dados (ao sair ou excluir a conta).
  void limpar() {
    _itens.clear();
    notifyListeners();
  }

  /// Agendamentos confirmados, do mais próximo para o mais distante.
  List<Agendamento> get ativos {
    final lista = _itens.where((a) => a.estaAtivo).toList()
      ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
    return List.unmodifiable(lista);
  }

  /// Realizados, cancelados e faltas, do mais recente para o mais antigo.
  List<Agendamento> get historico {
    final lista = _itens.where((a) => !a.estaAtivo).toList()
      ..sort((a, b) => b.dataHora.compareTo(a.dataHora));
    return List.unmodifiable(lista);
  }

  Agendamento? porProtocolo(String protocolo) {
    for (final item in _itens) {
      if (item.protocolo == protocolo) return item;
    }
    return null;
  }

  /// Verificação rápida no aparelho: o horário precisa ser futuro e o
  /// usuário não pode ter outro agendamento ativo exatamente na mesma data e
  /// hora. O banco repete essas regras (e as de dia útil/horário padrão).
  bool horarioDisponivel(DateTime dataHora, {String? ignorarProtocolo}) {
    if (!dataHora.isAfter(DateTime.now())) return false;
    return !_itens.any(
      (a) =>
          a.estaAtivo &&
          a.protocolo != ignorarProtocolo &&
          a.dataHora == dataHora,
    );
  }

  Future<Agendamento> adicionar({
    required TipoAtendimento tipo,
    required String servico,
    required Unidade unidade,
    required DateTime dataHora,
  }) async {
    final usuario = supabase.auth.currentUser;
    if (usuario == null) throw const ErroApp('Sessão expirada. Entre de novo.');

    final servicoId = Catalogo.servicoId(tipo, servico);
    if (servicoId == null) {
      throw const ErroApp(
        'Catálogo indisponível. Verifique a internet e reabra o app.',
      );
    }

    // O app não escolhe o profissional: o banco indica quem atende o serviço.
    final profissionalId = await supabase.rpc(
      'profissional_para',
      params: {'p_unidade': unidade.id, 'p_servico': servicoId},
    );
    if (profissionalId == null) {
      throw const ErroApp('Não há profissional para este serviço na unidade.');
    }

    // protocolo e status são preenchidos pelo banco (grant por coluna).
    final linha = await supabase
        .from('agendamentos')
        .insert({
          'paciente_id': usuario.id,
          'tipo': tipo.name,
          'servico_id': servicoId,
          'unidade_id': unidade.id,
          'profissional_id': profissionalId,
          'data_hora': dataHora.toUtc().toIso8601String(),
        })
        .select(_colunas)
        .single();

    final novo = _dePostgrest(linha);
    _itens.add(novo);
    notifyListeners();
    await _salvarCache();
    return novo;
  }

  /// Move o agendamento para o histórico com status "Cancelado".
  Future<void> cancelar(String protocolo) =>
      _atualizar(protocolo, {'status': StatusAgendamento.cancelado.name});

  Future<void> reagendar(String protocolo, DateTime novaDataHora) =>
      _atualizar(protocolo, {'data_hora': novaDataHora.toUtc().toIso8601String()});

  Future<void> _atualizar(String protocolo, Map<String, dynamic> campos) async {
    final indice = _itens.indexWhere((a) => a.protocolo == protocolo);
    if (indice < 0) return;

    final linha = await supabase
        .from('agendamentos')
        .update(campos)
        .eq('protocolo', protocolo)
        .select(_colunas)
        .single();

    _itens[indice] = _dePostgrest(linha);
    notifyListeners();
    await _salvarCache();
  }

  Agendamento _dePostgrest(Map<String, dynamic> m) {
    final servico = m['servicos'] as Map<String, dynamic>?;
    final profissional = m['profissionais'] as Map<String, dynamic>?;
    final tipo = TipoAtendimento.values.byName(m['tipo'] as String);
    final nomeServico = (servico?['nome'] as String?) ?? tipo.rotulo;

    return Agendamento(
      protocolo: m['protocolo'] as String,
      tipo: tipo,
      servico: nomeServico,
      unidade: Catalogo.unidadePorId(m['unidade_id'] as String),
      profissional: (profissional?['nome'] as String?) ?? 'Equipe da unidade',
      dataHora: DateTime.parse(m['data_hora'] as String).toLocal(),
      status: StatusAgendamento.values.byName(m['status'] as String),
      orientacoes: servico?['orientacoes'] != null
          ? List<String>.from(servico!['orientacoes'] as List)
          : Catalogo.orientacoesPara(tipo, nomeServico),
    );
  }
}
