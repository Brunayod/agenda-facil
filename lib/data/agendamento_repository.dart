import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/agendamento.dart';
import '../models/unidade.dart';
import 'catalogo.dart';

/// Repositório (singleton) dos agendamentos do paciente logado.
///
/// É um [ChangeNotifier]: telas que usam `ListenableBuilder` são
/// reconstruídas automaticamente ao adicionar, cancelar ou reagendar.
///
/// Cada paciente tem a própria lista, salva em `shared_preferences` na chave
/// `af.agendamentos.<cpf>`. Quem chama [carregarPara] (o login) escolhe de
/// quem são os dados; [descarregar] (o logout) esvazia a memória sem apagar
/// o que está salvo.
class AgendamentoRepository extends ChangeNotifier {
  AgendamentoRepository._();

  static final AgendamentoRepository instance = AgendamentoRepository._();

  static const _prefixoChave = 'af.agendamentos.';
  static const _chaveSequencia = 'af.sequencia';

  final List<Agendamento> _itens = [];

  /// Contador global de protocolos (nunca repete entre pacientes).
  int _sequencia = 1000;

  /// CPF do paciente dono da lista atual (`null` = ninguém logado).
  String? _cpf;

  /// Carrega do disco os agendamentos de [cpf]. Se não houver nada salvo e
  /// [semearSeVazio] for `true`, cria os dados de demonstração.
  Future<void> carregarPara(String cpf, {bool semearSeVazio = false}) async {
    final prefs = await SharedPreferences.getInstance();
    _cpf = cpf;
    _itens.clear();
    _sequencia = prefs.getInt(_chaveSequencia) ?? 1000;

    var encontrou = false;
    final bruto = prefs.getString('$_prefixoChave$cpf');
    if (bruto != null) {
      try {
        final mapa = jsonDecode(bruto) as Map<String, dynamic>;
        _itens.addAll(
          (mapa['itens'] as List)
              .map((e) => Agendamento.fromJson(e as Map<String, dynamic>)),
        );
        encontrou = true;
      } on Object {
        _itens.clear(); // dados corrompidos: trata como primeiro acesso
      }
    }

    if (!encontrou && semearSeVazio) _semear();
    _concluirVencidos();
    await _salvar();
    notifyListeners();
  }

  /// Esvazia a memória (logout). Os dados salvos no aparelho permanecem.
  void descarregar() {
    _cpf = null;
    _itens.clear();
    notifyListeners();
  }

  /// Agendamentos confirmados cuja data já passou viram "Realizado": sem
  /// isso, ao reabrir o app dias depois eles ficariam "ativos" no passado.
  void _concluirVencidos() {
    final agora = DateTime.now();
    for (var i = 0; i < _itens.length; i++) {
      final a = _itens[i];
      if (a.estaAtivo && a.dataHora.isBefore(agora)) {
        _itens[i] = a.copyWith(status: StatusAgendamento.realizado);
      }
    }
  }

  Future<void> _salvar() async {
    final cpf = _cpf;
    if (cpf == null) return;
    // O JSON é montado antes do await: grava o estado deste instante e não
    // escreve nada se o usuário sair da conta enquanto o disco responde.
    final json = jsonEncode({'itens': _itens.map((a) => a.toJson()).toList()});
    final sequencia = _sequencia;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefixoChave$cpf', json);
    await prefs.setInt(_chaveSequencia, sequencia);
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

  /// Um horário está livre se for futuro e o usuário não tiver outro
  /// agendamento ativo exatamente na mesma data e hora.
  bool horarioDisponivel(DateTime dataHora, {String? ignorarProtocolo}) {
    if (!dataHora.isAfter(DateTime.now())) return false;
    return !_itens.any(
      (a) =>
          a.estaAtivo &&
          a.protocolo != ignorarProtocolo &&
          a.dataHora == dataHora,
    );
  }

  Agendamento adicionar({
    required TipoAtendimento tipo,
    required String servico,
    required Unidade unidade,
    required DateTime dataHora,
  }) {
    final novo = _criar(
      tipo: tipo,
      servico: servico,
      unidade: unidade,
      dataHora: dataHora,
      status: StatusAgendamento.confirmado,
    );
    _itens.add(novo);
    notifyListeners();
    unawaited(_salvar());
    return novo;
  }

  /// Move o agendamento para o histórico com status "Cancelado".
  void cancelar(String protocolo) {
    _substituir(
      protocolo,
      (a) => a.copyWith(status: StatusAgendamento.cancelado),
    );
  }

  void reagendar(String protocolo, DateTime novaDataHora) {
    _substituir(protocolo, (a) => a.copyWith(dataHora: novaDataHora));
  }

  void _substituir(String protocolo, Agendamento Function(Agendamento) fn) {
    final indice = _itens.indexWhere((a) => a.protocolo == protocolo);
    if (indice < 0) return;
    _itens[indice] = fn(_itens[indice]);
    notifyListeners();
    unawaited(_salvar());
  }

  Agendamento _criar({
    required TipoAtendimento tipo,
    required String servico,
    required Unidade unidade,
    required DateTime dataHora,
    required StatusAgendamento status,
  }) {
    final numero = (_sequencia++).toString().padLeft(6, '0');
    return Agendamento(
      protocolo: 'AF-${DateTime.now().year}-$numero',
      tipo: tipo,
      servico: servico,
      unidade: unidade,
      profissional: Catalogo.profissionalPara(tipo, servico, unidade: unidade),
      dataHora: dataHora,
      status: status,
      orientacoes: Catalogo.orientacoesPara(tipo, servico),
    );
  }

  /// Dados iniciais relativos à data atual, para o app nunca abrir vazio.
  void _semear() {
    final vilaMariana = Catalogo.unidades[0];

    _itens.addAll([
      _criar(
        tipo: TipoAtendimento.consulta,
        servico: 'Clínica Médica',
        unidade: vilaMariana,
        dataHora: _diaUtil(3, 9, 30),
        status: StatusAgendamento.confirmado,
      ),
      _criar(
        tipo: TipoAtendimento.vacinacao,
        servico: 'Vacina da gripe',
        unidade: vilaMariana,
        dataHora: _diaUtil(7, 11, 0),
        status: StatusAgendamento.confirmado,
      ),
      _criar(
        tipo: TipoAtendimento.exame,
        servico: 'Hemograma completo',
        unidade: vilaMariana,
        dataHora: _diaUtil(12, 8, 0),
        status: StatusAgendamento.confirmado,
      ),
      _criar(
        tipo: TipoAtendimento.consulta,
        servico: 'Clínica Médica',
        unidade: vilaMariana,
        dataHora: _diaUtil(-14, 11, 0),
        status: StatusAgendamento.realizado,
      ),
      _criar(
        tipo: TipoAtendimento.vacinacao,
        servico: 'Vacina da gripe',
        unidade: vilaMariana,
        dataHora: _diaUtil(-40, 15, 30),
        status: StatusAgendamento.realizado,
      ),
      _criar(
        tipo: TipoAtendimento.exame,
        servico: 'Glicemia em jejum',
        unidade: vilaMariana,
        dataHora: _diaUtil(-22, 8, 0),
        status: StatusAgendamento.naoCompareceu,
      ),
    ]);
  }

  /// Data daqui a [dias] dias, empurrada para segunda se cair no fim de semana.
  static DateTime _diaUtil(int dias, int hora, int minuto) {
    final base = DateTime.now().add(Duration(days: dias));
    var dia = DateTime(base.year, base.month, base.day, hora, minuto);
    while (dia.weekday == DateTime.saturday || dia.weekday == DateTime.sunday) {
      dia = DateTime(dia.year, dia.month, dia.day + 1, hora, minuto);
    }
    return dia;
  }
}
