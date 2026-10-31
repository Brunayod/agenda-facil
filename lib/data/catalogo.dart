import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../models/unidade.dart';

/// Dados fixos usados pelo formulário (unidades, serviços, horários...).
///
/// Endereços, profissionais e orientações são EXEMPLOS: substitua pelos dados
/// reais (ou por uma API) quando existirem.
abstract final class Catalogo {
  static const unidades = <Unidade>[
    Unidade(
      id: 'vila-mariana',
      nome: 'UBS Vila Mariana',
      endereco: 'Rua Domingos de Morais, 1200 - Vila Mariana, São Paulo - SP',
    ),
    Unidade(
      id: 'santa-cecilia',
      nome: 'UBS Santa Cecília',
      endereco: 'Rua Vitorino Carmilo, 400 - Santa Cecília, São Paulo - SP',
    ),
    Unidade(
      id: 'republica',
      nome: 'UBS República',
      endereco: 'Praça da República, 150 - República, São Paulo - SP',
    ),
  ];

  static const horarios = <TimeOfDay>[
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 9, minute: 30),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 30),
  ];

  static List<String> servicosDe(TipoAtendimento tipo) => switch (tipo) {
        TipoAtendimento.consulta => const [
            'Clínica Médica',
            'Pediatria',
            'Ginecologia',
            'Odontologia',
          ],
        TipoAtendimento.exame => const [
            'Hemograma completo',
            'Glicemia em jejum',
            'Perfil lipídico',
            'Exame de urina',
          ],
        TipoAtendimento.vacinacao => const [
            'Vacina da gripe',
            'Covid-19',
            'Hepatite B',
            'Tétano (dT)',
          ],
        TipoAtendimento.receita => const [
            'Clínica Médica',
            'Hipertensão e diabetes',
            'Saúde mental',
          ],
      };

  static String profissionalPara(TipoAtendimento tipo, String servico) =>
      switch (tipo) {
        TipoAtendimento.exame => 'Equipe do laboratório',
        TipoAtendimento.vacinacao => 'Equipe de enfermagem',
        TipoAtendimento.consulta ||
        TipoAtendimento.receita =>
          switch (servico) {
            'Pediatria' => 'Dr. Rafael Souza',
            'Ginecologia' => 'Dra. Camila Duarte',
            'Odontologia' => 'Dr. Lucas Ferreira',
            'Saúde mental' => 'Dra. Beatriz Nogueira',
            _ => 'Dra. Helena Martins',
          },
      };

  static List<String> orientacoesPara(TipoAtendimento tipo, String servico) {
    const documento = 'Levar documento com foto e carteirinha do SUS';
    const antecedencia = 'Chegar com 15 minutos de antecedência';

    switch (tipo) {
      case TipoAtendimento.consulta:
        return [
          documento,
          antecedencia,
          'Levar exames e receitas anteriores, se houver',
          if (servico == 'Odontologia') 'Escovar os dentes antes da consulta',
        ];
      case TipoAtendimento.exame:
        return [
          documento,
          antecedencia,
          if (servico == 'Exame de urina')
            'Coletar a primeira urina da manhã em frasco apropriado'
          else
            'Jejum de 8 horas (pode beber apenas água)',
        ];
      case TipoAtendimento.vacinacao:
        return [
          documento,
          'Levar a caderneta de vacinação',
          'Avisar a equipe se estiver com febre ou sintomas de gripe',
        ];
      case TipoAtendimento.receita:
        return [
          documento,
          'Levar a receita anterior ou as caixas dos medicamentos',
          'Informar mudanças de dose ou efeitos colaterais',
        ];
    }
  }

  /// Próximos dias úteis (sem sábado e domingo), a partir de hoje.
  static List<DateTime> proximosDias({int quantidade = 14}) {
    final hoje = DateTime.now();
    var dia = DateTime(hoje.year, hoje.month, hoje.day);
    final lista = <DateTime>[];
    while (lista.length < quantidade) {
      if (dia.weekday != DateTime.saturday && dia.weekday != DateTime.sunday) {
        lista.add(dia);
      }
      dia = DateTime(dia.year, dia.month, dia.day + 1);
    }
    return lista;
  }

  static String formatarHora(TimeOfDay hora) =>
      '${hora.hour.toString().padLeft(2, '0')}:'
      '${hora.minute.toString().padLeft(2, '0')}';

  static String diaSemanaCurto(DateTime dia) =>
      const ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][dia.weekday - 1];

  static String mesCurto(DateTime dia) => const [
        'jan',
        'fev',
        'mar',
        'abr',
        'mai',
        'jun',
        'jul',
        'ago',
        'set',
        'out',
        'nov',
        'dez',
      ][dia.month - 1];
}
