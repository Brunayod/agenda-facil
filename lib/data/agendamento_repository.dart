import 'package:flutter/foundation.dart';

import '../models/agendamento.dart';
import '../models/unidade.dart';
import 'catalogo.dart';

/// Repositório em memória (singleton) dos agendamentos do usuário.
///
/// É um [ChangeNotifier]: telas que usam `ListenableBuilder` são
/// reconstruídas automaticamente ao adicionar, cancelar ou reagendar.
/// Os dados somem ao fechar o app; troque por API/banco quando existir.
class AgendamentoRepository extends ChangeNotifier {
  AgendamentoRepository._() {
    _semear();
  }

  static final AgendamentoRepository instance = AgendamentoRepository._();

  final List<Agendamento> _itens = [];
  int _sequencia = 1000;

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
      profissional: Catalogo.profissionalPara(tipo, servico),
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
