import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../models/profissional.dart';
import '../models/unidade.dart';
import 'localizacao_repository.dart';
import 'supabase_config.dart';

/// Serviço do catálogo (especialidade, exame, vacina ou tipo de receita).
class ServicoCatalogo {
  const ServicoCatalogo({
    required this.id,
    required this.tipo,
    required this.nome,
    required this.especialidade,
    required this.orientacoes,
  });

  final int id;
  final TipoAtendimento tipo;
  final String nome;
  final String especialidade;
  final List<String> orientacoes;
}

/// Dados do catálogo (unidades, serviços, horários...).
///
/// Na inicialização, [carregar] busca tudo do Supabase. Se não houver
/// internet, o app continua com os dados de exemplo abaixo (só para
/// visualização: sem o catálogo do servidor não é possível agendar).
abstract final class Catalogo {
  /// `true` quando os dados vieram do Supabase.
  static bool carregado = false;

  static List<Unidade> unidades = _unidadesPadrao;
  static List<ServicoCatalogo> _servicos = const [];

  /// Busca unidades, profissionais, serviços e horários no Supabase.
  /// Nunca lança: em caso de falha mantém os dados de exemplo.
  static Future<void> carregar() async {
    try {
      final linhasUnidades = await supabase
          .from('unidades')
          .select('*, unidade_tipos(tipo), profissionais(nome, especialidade)')
          .order('distancia_km', ascending: true)
          .order('id', referencedTable: 'profissionais', ascending: true);

      final linhasServicos = await supabase
          .from('servicos')
          .select('id, tipo, nome, especialidade, orientacoes')
          .order('id', ascending: true);

      final linhasHorarios = await supabase
          .from('horarios_padrao')
          .select('hora')
          .order('hora', ascending: true);

      final novasUnidades = <Unidade>[
        for (final u in linhasUnidades)
          Unidade(
            id: u['id'] as String,
            nome: u['nome'] as String,
            bairro: u['bairro'] as String,
            endereco: u['endereco'] as String,
            horarioFuncionamento: u['horario_funcionamento'] as String,
            telefone: u['telefone'] as String,
            distanciaKm: (u['distancia_km'] as num?)?.toDouble(),
            latitude: _coordenada(u['latitude'], u['id'] as String, latitude: true),
            longitude: _coordenada(u['longitude'], u['id'] as String, latitude: false),
            servicos: [
              for (final t in (u['unidade_tipos'] as List))
                TipoAtendimento.values.byName(t['tipo'] as String),
            ],
            profissionais: [
              for (final p in (u['profissionais'] as List))
                Profissional(
                  nome: p['nome'] as String,
                  especialidade: p['especialidade'] as String,
                ),
            ],
          ),
      ];

      final novosServicos = <ServicoCatalogo>[
        for (final s in linhasServicos)
          ServicoCatalogo(
            id: (s['id'] as num).toInt(),
            tipo: TipoAtendimento.values.byName(s['tipo'] as String),
            nome: s['nome'] as String,
            especialidade: s['especialidade'] as String,
            orientacoes: List<String>.from(s['orientacoes'] as List),
          ),
      ];

      final novosHorarios = <TimeOfDay>[
        for (final h in linhasHorarios)
          // O Postgres devolve "08:00:00".
          TimeOfDay(
            hour: int.parse((h['hora'] as String).substring(0, 2)),
            minute: int.parse((h['hora'] as String).substring(3, 5)),
          ),
      ];

      if (novasUnidades.isEmpty || novosServicos.isEmpty) return;

      unidades = novasUnidades;
      _servicos = novosServicos;
      if (novosHorarios.isNotEmpty) horarios = novosHorarios;
      carregado = true;
    } catch (erro) {
      debugPrint('Catalogo: usando dados de exemplo ($erro)');
    }
  }

  /// `id` do serviço no banco (necessário para criar o agendamento).
  static int? servicoId(TipoAtendimento tipo, String nome) {
    for (final s in _servicos) {
      if (s.tipo == tipo && s.nome == nome) return s.id;
    }
    return null;
  }

  static ServicoCatalogo? _servico(TipoAtendimento tipo, String nome) {
    for (final s in _servicos) {
      if (s.tipo == tipo && s.nome == nome) return s;
    }
    return null;
  }

  /// Coordenadas das UBS pelo `id`. Usadas quando o banco ainda não tem as
  /// colunas `latitude`/`longitude` (rode o `supabase_setup.sql`).
  ///
  /// As de Cotia são as informadas pela equipe. As da capital são APROXIMADAS
  /// (centro do bairro), pois os endereços de exemplo não são reais.
  static const _coordenadasPadrao = <String, ({double lat, double lng})>{
    'vila-mariana': (lat: -23.5895, lng: -46.6346),
    'santa-cecilia': (lat: -23.5372, lng: -46.6504),
    'republica': (lat: -23.5434, lng: -46.6428),
    'bom-retiro': (lat: -23.5276, lng: -46.6348),
    'pinheiros': (lat: -23.5667, lng: -46.6818),
    'mirizola': (lat: -23.5976, lng: -46.9192),
    'atalaia': (lat: -23.6115, lng: -46.9328),
    'portao': (lat: -23.5882, lng: -46.8995),
  };

  /// Valor vindo do banco; se vazio, usa [_coordenadasPadrao]; senão `0`.
  static double _coordenada(
    Object? valorDoBanco,
    String id, {
    required bool latitude,
  }) {
    if (valorDoBanco is num) return valorDoBanco.toDouble();
    final padrao = _coordenadasPadrao[id];
    if (padrao == null) return 0;
    return latitude ? padrao.lat : padrao.lng;
  }

  static const _unidadesPadrao = <Unidade>[
    Unidade(
      id: 'vila-mariana',
      nome: 'UBS Vila Mariana',
      bairro: 'Vila Mariana',
      endereco: 'Rua Domingos de Morais, 1200 - Vila Mariana, São Paulo - SP',
      horarioFuncionamento: 'Seg a Sex • 07h às 19h',
      telefone: '(11) 5555-0101',
      distanciaKm: 1.2,
      latitude: -23.5895,
      longitude: -46.6346,
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
      latitude: -23.5372,
      longitude: -46.6504,
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
      latitude: -23.5434,
      longitude: -46.6428,
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
      latitude: -23.5276,
      longitude: -46.6348,
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
      latitude: -23.5667,
      longitude: -46.6818,
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
    Unidade(
      id: 'mirizola',
      nome: 'UBS Mirizola',
      bairro: 'Parque Mirizola',
      endereco: 'Rua Vicente Strifezzi, 139 - Parque Mirizola, Cotia - SP',
      horarioFuncionamento: 'Seg a Sex • 07h às 17h',
      telefone: '(11) 5555-0106',
      latitude: -23.5976,
      longitude: -46.9192,
      servicos: [
        TipoAtendimento.consulta,
        TipoAtendimento.exame,
        TipoAtendimento.vacinacao,
        TipoAtendimento.receita,
      ],
      profissionais: [
        Profissional(nome: 'Dra. Aline Teixeira', especialidade: 'Clínica Médica'),
        Profissional(nome: 'Dr. Henrique Matos', especialidade: 'Pediatria'),
        Profissional(nome: 'Dra. Larissa Campos', especialidade: 'Ginecologia'),
        Profissional(nome: 'Dr. Murilo Barbosa', especialidade: 'Odontologia'),
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
      id: 'atalaia',
      nome: 'UBS Atalaia',
      bairro: 'Atalaia',
      endereco: 'Bairro Atalaia, Cotia - SP',
      horarioFuncionamento: 'Seg a Sex • 07h às 17h',
      telefone: '(11) 5555-0107',
      latitude: -23.6115,
      longitude: -46.9328,
      servicos: [
        TipoAtendimento.consulta,
        TipoAtendimento.vacinacao,
        TipoAtendimento.receita,
      ],
      profissionais: [
        Profissional(nome: 'Dr. Otávio Ribeiro', especialidade: 'Clínica Médica'),
        Profissional(nome: 'Dra. Priscila Neves', especialidade: 'Pediatria'),
        Profissional(
          nome: 'Equipe de enfermagem',
          especialidade: 'Vacinação',
        ),
      ],
    ),
    Unidade(
      id: 'portao',
      nome: 'UBS Portão',
      bairro: 'Portão',
      endereco: 'Bairro Portão, Cotia - SP',
      horarioFuncionamento: 'Seg a Sex • 07h às 17h',
      telefone: '(11) 5555-0108',
      latitude: -23.5882,
      longitude: -46.8995,
      servicos: [
        TipoAtendimento.consulta,
        TipoAtendimento.exame,
        TipoAtendimento.vacinacao,
      ],
      profissionais: [
        Profissional(nome: 'Dra. Carolina Lopes', especialidade: 'Clínica Médica'),
        Profissional(nome: 'Dr. Vinícius Prado', especialidade: 'Odontologia'),
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

  static const tiposSanguineos = <String>[
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  static List<TimeOfDay> horarios = _horariosPadrao;

  static const _horariosPadrao = <TimeOfDay>[
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
      ..sort(compararPorProximidade);
    return lista;
  }

  /// Todas as unidades, da mais próxima para a mais distante.
  static List<Unidade> get unidadesOrdenadas =>
      [...unidades]..sort(compararPorProximidade);

  /// Distância real (GPS + Haversine) até a unidade, em km; `null` se a
  /// localização do usuário ainda não está disponível.
  static double? distanciaKm(Unidade unidade) =>
      LocalizacaoRepository.instance.distanciaAte(unidade);

  /// Ex.: "0,8 km"; `null` se a distância ainda não é conhecida.
  static String? distanciaTexto(Unidade unidade) {
    final km = distanciaKm(unidade);
    return km == null ? null : Unidade.formatarKm(km);
  }

  /// Com GPS: pela distância real. Sem GPS: pela distância simulada antiga
  /// (quando existe) e, por fim, pelo nome.
  static int compararPorProximidade(Unidade a, Unidade b) {
    final reaisA = distanciaKm(a);
    final reaisB = distanciaKm(b);
    if (reaisA != null && reaisB != null) return reaisA.compareTo(reaisB);
    if (reaisA != null) return -1;
    if (reaisB != null) return 1;

    final simA = a.distanciaKm;
    final simB = b.distanciaKm;
    if (simA != null && simB != null) {
      final comparacao = simA.compareTo(simB);
      if (comparacao != 0) return comparacao;
    } else if (simA != null) {
      return -1;
    } else if (simB != null) {
      return 1;
    }
    return a.nome.compareTo(b.nome);
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
    final doServidor = [
      for (final s in _servicos)
        if (s.tipo == tipo) s.nome,
    ];
    final todos = doServidor.isNotEmpty ? doServidor : switch (tipo) {
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
      _servico(tipo, servico)?.especialidade ??
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
    final doServidor = _servico(tipo, servico)?.orientacoes;
    if (doServidor != null && doServidor.isNotEmpty) return doServidor;

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
