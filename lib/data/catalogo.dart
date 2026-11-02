import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../models/profissional.dart';
import '../models/unidade.dart';

/// Dados fixos usados pelo app (unidades, serviços, horários...).
///
/// Endereços, telefones, distâncias, profissionais e orientações são
/// EXEMPLOS: substitua pelos dados reais (ou por uma API) quando existirem.
abstract final class Catalogo {
  static const unidades = <Unidade>[
    Unidade(
      id: 'vila-mariana',
      nome: 'UBS Vila Mariana',
      bairro: 'Vila Mariana',
      endereco: 'Rua Domingos de Morais, 1200 - Vila Mariana, São Paulo - SP',
      horarioFuncionamento: 'Seg a Sex • 07h às 19h',
      telefone: '(11) 5555-0101',
      distanciaKm: 1.2,
      servicos: [
        TipoAtendimento.consulta,
        TipoAtendimento.exame,
        TipoAtendimento.vacinacao,
        TipoAtendimento.receita,
      ],
      profissionais: [
        Profissional(nome: 'Dra. Helena Martins', especialidade: 'Clínica Médica'),
        Profissional(nome: 'Dr. Rafael Souza', especialidade: 'Pediatria'),
        Profissional(nome: 'Dra. Camila Duarte', especialidade: 'Ginecologia'),
        Profissional(nome: 'Dr. Lucas Ferreira', especialidade: 'Odontologia'),
        Profissional(
          nome: 'Equipe de enfermagem',
          especialidade: 'Vacinação',
        ),
        Profissional(
          nome: 'Equipe do laboratório',
          especialidade: 'Exames laboratoriais',
        ),
      ],
    ),
    Unidade(
      id: 'santa-cecilia',
      nome: 'UBS Santa Cecília',
      bairro: 'Santa Cecília',
      endereco: 'Rua Vitorino Carmilo, 400 - Santa Cecília, São Paulo - SP',
      horarioFuncionamento: 'Seg a Sex • 07h às 18h',
      telefone: '(11) 5555-0102',
      distanciaKm: 2.8,
      servicos: [
        TipoAtendimento.consulta,
        TipoAtendimento.exame,
        TipoAtendimento.vacinacao,
      ],
      profissionais: [
        Profissional(nome: 'Dr. André Lima', especialidade: 'Clínica Médica'),
        Profissional(nome: 'Dra. Patrícia Gomes', especialidade: 'Pediatria'),
        Profissional(
          nome: 'Equipe de enfermagem',
          especialidade: 'Vacinação',
        ),
        Profissional(
          nome: 'Equipe do laboratório',
          especialidade: 'Exames laboratoriais',
        ),
      ],
    ),
    Unidade(
      id: 'republica',
      nome: 'UBS República',
      bairro: 'República',
      endereco: 'Praça da República, 150 - República, São Paulo - SP',
      horarioFuncionamento: 'Seg a Sex • 08h às 17h',
      telefone: '(11) 5555-0103',
      distanciaKm: 3.4,
      servicos: [
        TipoAtendimento.consulta,
        TipoAtendimento.vacinacao,
        TipoAtendimento.receita,
      ],
      profissionais: [
        Profissional(nome: 'Dra. Marina Costa', especialidade: 'Clínica Médica'),
        Profissional(
          nome: 'Dra. Beatriz Nogueira',
          especialidade: 'Saúde mental',
        ),
        Profissional(nome: 'Dr. Tiago Ramos', especialidade: 'Odontologia'),
        Profissional(
          nome: 'Equipe de enfermagem',
          especialidade: 'Vacinação',
        ),
      ],
    ),
    Unidade(
      id: 'bom-retiro',
      nome: 'UBS Bom Retiro',
      bairro: 'Bom Retiro',
      endereco: 'Rua Prates, 600 - Bom Retiro, São Paulo - SP',
      horarioFuncionamento: 'Seg a Sex • 07h às 19h',
      telefone: '(11) 5555-0104',
      distanciaKm: 4.1,
      servicos: [
        TipoAtendimento.consulta,
        TipoAtendimento.exame,
        TipoAtendimento.vacinacao,
        TipoAtendimento.receita,
      ],
      profissionais: [
        Profissional(nome: 'Dr. Eduardo Prado', especialidade: 'Clínica Médica'),
        Profissional(nome: 'Dra. Sofia Almeida', especialidade: 'Ginecologia'),
        Profissional(nome: 'Dr. Bruno Carvalho', especialidade: 'Pediatria'),
        Profissional(
          nome: 'Equipe de enfermagem',
          especialidade: 'Vacinação',
        ),
        Profissional(
          nome: 'Equipe do laboratório',
          especialidade: 'Exames laboratoriais',
        ),
      ],
    ),
    Unidade(
      id: 'pinheiros',
      nome: 'UBS Pinheiros',
      bairro: 'Pinheiros',
      endereco: 'Rua Teodoro Sampaio, 1100 - Pinheiros, São Paulo - SP',
      horarioFuncionamento: 'Seg a Sáb • 07h às 13h',
      telefone: '(11) 5555-0105',
      distanciaKm: 5.6,
      servicos: [
        TipoAtendimento.consulta,
        TipoAtendimento.exame,
        TipoAtendimento.vacinacao,
        TipoAtendimento.receita,
      ],
      profissionais: [
        Profissional(nome: 'Dra. Luiza Fernandes', especialidade: 'Clínica Médica'),
        Profissional(nome: 'Dra. Renata Moraes', especialidade: 'Ginecologia'),
        Profissional(nome: 'Dr. Felipe Azevedo', especialidade: 'Odontologia'),
        Profissional(
          nome: 'Dr. Gustavo Pires',
          especialidade: 'Saúde mental',
        ),
        Profissional(
          nome: 'Equipe de enfermagem',
          especialidade: 'Vacinação',
        ),
        Profissional(
          nome: 'Equipe do laboratório',
          especialidade: 'Exames laboratoriais',
        ),
      ],
    ),
  ];

  static const horarios = <TimeOfDay>[
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 9, minute: 30),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 30),
  ];

  /// Busca a unidade pelo `id`; se não existir, devolve a primeira da lista.
  static Unidade unidadePorId(String id) {
    for (final unidade in unidades) {
      if (unidade.id == id) return unidade;
    }
    return unidades.first;
  }

  /// Filtra por nome/bairro (ignora acentos e maiúsculas) e por tipo de
  /// atendimento. O resultado vem ordenado pela distância.
  static List<Unidade> buscarUnidades({
    String consulta = '',
    TipoAtendimento? tipo,
  }) {
    final termo = _normalizar(consulta.trim());
    final lista = unidades.where((u) {
      if (tipo != null && !u.oferece(tipo)) return false;
      if (termo.isEmpty) return true;
      return _normalizar(u.nome).contains(termo) ||
          _normalizar(u.bairro).contains(termo);
    }).toList()
      ..sort((a, b) => a.distanciaKm.compareTo(b.distanciaKm));
    return lista;
  }

  static String _normalizar(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const semAcento = 'aaaaaeeeeiiiiooooouuuuc';
    final saida = StringBuffer();
    for (final rune in texto.toLowerCase().runes) {
      final caractere = String.fromCharCode(rune);
      final indice = comAcento.indexOf(caractere);
      saida.write(indice >= 0 ? semAcento[indice] : caractere);
    }
    return saida.toString();
  }

  /// Serviços do tipo escolhido. Com [unidade], consultas e receitas mostram
  /// só o que a unidade realmente atende.
  static List<String> servicosDe(TipoAtendimento tipo, {Unidade? unidade}) {
    final todos = switch (tipo) {
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

    if (unidade == null ||
        (tipo != TipoAtendimento.consulta && tipo != TipoAtendimento.receita)) {
      return todos;
    }

    final disponiveis = todos
        .where(
          (s) => unidade.especialidades.contains(especialidadeDe(tipo, s)),
        )
        .toList();
    return disponiveis.isEmpty ? todos : disponiveis;
  }

  /// Especialidade (como cadastrada nos profissionais) que atende o serviço.
  static String especialidadeDe(TipoAtendimento tipo, String servico) =>
      switch (tipo) {
        TipoAtendimento.consulta => servico,
        TipoAtendimento.receita =>
          servico == 'Saúde mental' ? 'Saúde mental' : 'Clínica Médica',
        TipoAtendimento.exame => 'Exames laboratoriais',
        TipoAtendimento.vacinacao => 'Vacinação',
      };

  /// Profissional responsável. Com [unidade], usa quem atende nela.
  static String profissionalPara(
    TipoAtendimento tipo,
    String servico, {
    Unidade? unidade,
  }) {
    if (unidade != null) {
      final especialidade = especialidadeDe(tipo, servico);
      for (final p in unidade.profissionais) {
        if (p.especialidade == especialidade) return p.nome;
      }
    }

    return switch (tipo) {
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
  }

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
