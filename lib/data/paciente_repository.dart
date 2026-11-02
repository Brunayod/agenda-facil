import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/paciente.dart';
import 'agendamento_repository.dart';

/// Repositório (singleton) das contas de paciente e da sessão atual.
///
/// É um [ChangeNotifier]: telas reagem às mudanças com `ListenableBuilder`.
/// Tudo é salvo no armazenamento local (`shared_preferences`):
///  * `af.contas`  — todas as contas cadastradas (dados do paciente + senha
///    protegida por hash com salt);
///  * `af.sessao`  — CPF do paciente logado (ausente = deslogado).
///
/// Chame [carregar] uma vez em `main()` antes de `runApp`.
class PacienteRepository extends ChangeNotifier {
  PacienteRepository._();

  static final PacienteRepository instance = PacienteRepository._();

  static const _chaveContas = 'af.contas';
  static const _chaveSessao = 'af.sessao';

  /// CPF da paciente de demonstração (usada no "Acesso Rápido").
  static const cpfDemo = '12345678909';

  /// Senha da conta de demonstração, para quem preferir digitar o login.
  static const senhaDemo = 'demo123';

  /// Dados de demonstração (fictícios) da primeira abertura do app.
  static Paciente get _pacienteDemo => Paciente(
        nome: 'Jheniffer Almeida Santos',
        cns: '700123456789012',
        cpf: cpfDemo,
        dataNascimento: DateTime(1998, 5, 14),
        tipoSanguineo: 'O+',
        telefone: '(11) 98765-4321',
        email: 'jheniffer.santos@email.com',
        endereco: 'Rua das Flores, 120 - Vila Mariana, São Paulo - SP',
        unidadeReferenciaId: 'vila-mariana',
        alergias: const ['Dipirona'],
        condicoes: const ['Rinite'],
      );

  final List<_Conta> _contas = [];
  Paciente? _ativo;

  // ----- Sessão -----

  bool get logado => _ativo != null;

  /// Paciente logado. Só use depois do login (telas internas do app).
  Paciente get paciente {
    final ativo = _ativo;
    if (ativo == null) {
      throw StateError('Nenhum paciente logado.');
    }
    return ativo;
  }

  /// Preferência de texto do paciente logado ("normal" na tela de login).
  TamanhoTexto get tamanhoTexto => _ativo?.tamanhoTexto ?? TamanhoTexto.normal;

  /// Lê contas e sessão do armazenamento local. Na primeira abertura cria a
  /// conta de demonstração; se havia sessão salva, restaura o login.
  Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();

    _contas.clear();
    final bruto = prefs.getString(_chaveContas);
    if (bruto != null) {
      try {
        final lista = jsonDecode(bruto) as List;
        _contas.addAll(
          lista.map((e) => _Conta.fromJson(e as Map<String, dynamic>)),
        );
      } on Object {
        _contas.clear(); // dados corrompidos: recomeça com a demonstração
      }
    }

    if (!_contas.any((c) => c.paciente.cpf == cpfDemo)) {
      _contas.add(_Conta.nova(_pacienteDemo, senhaDemo));
      await _salvarContas();
    }

    final cpfSessao = prefs.getString(_chaveSessao);
    final conta = cpfSessao == null ? null : _buscarPorCpf(cpfSessao);
    if (conta != null) {
      _ativo = conta.paciente;
      await AgendamentoRepository.instance.carregarPara(
        conta.paciente.cpf,
        semearSeVazio: conta.paciente.cpf == cpfDemo,
      );
    } else if (cpfSessao != null) {
      await prefs.remove(_chaveSessao);
    }
    notifyListeners();
  }

  /// Login por CPF (11 dígitos) ou Cartão SUS (15 dígitos) e senha.
  /// Devolve a mensagem de erro, ou `null` se entrou.
  Future<String?> entrar({
    required String identificador,
    required String senha,
  }) async {
    final digitos = identificador.replaceAll(RegExp(r'\D'), '');
    _Conta? conta;
    for (final c in _contas) {
      if (c.paciente.cpf == digitos || c.paciente.cns == digitos) {
        conta = c;
        break;
      }
    }
    if (conta == null || !conta.confere(senha)) {
      return 'CPF/Cartão SUS ou senha incorretos.';
    }
    await iniciarSessao(conta.paciente.cpf);
    return null;
  }

  /// Entra direto como a paciente de demonstração (sem digitar nada).
  Future<void> acessoRapido() => iniciarSessao(cpfDemo);

  /// Cria uma conta nova (não inicia a sessão — use [iniciarSessao]).
  /// Devolve a mensagem de erro, ou `null` se salvou.
  Future<String?> cadastrar({
    required Paciente paciente,
    required String senha,
  }) async {
    if (_buscarPorCpf(paciente.cpf) != null) {
      return 'Já existe uma conta com este CPF.';
    }
    if (_contas.any((c) => c.paciente.cns == paciente.cns)) {
      return 'Já existe uma conta com este Cartão SUS.';
    }
    _contas.add(_Conta.nova(paciente, senha));
    await _salvarContas();
    return null;
  }

  /// Abre a sessão do paciente de [cpf]: carrega os agendamentos dele,
  /// grava a sessão e avisa as telas (o app troca o login pela Home).
  Future<void> iniciarSessao(String cpf) async {
    final conta = _buscarPorCpf(cpf);
    if (conta == null) return;

    await AgendamentoRepository.instance.carregarPara(
      cpf,
      semearSeVazio: cpf == cpfDemo,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveSessao, cpf);
    _ativo = conta.paciente;
    notifyListeners();
  }

  /// Encerra a sessão. As contas e os agendamentos continuam salvos.
  Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveSessao);
    _ativo = null;
    AgendamentoRepository.instance.descarregar();
    notifyListeners();
  }

  // ----- Dados do paciente -----

  /// Substitui os dados cadastrais (usado pelo formulário "Editar dados").
  void atualizar(Paciente novo) {
    _aplicar(novo);
  }

  // ----- Alergias e condições -----

  /// Devolve `false` se o texto for vazio ou já existir na lista.
  bool adicionarAlergia(String item) {
    final texto = item.trim();
    if (texto.isEmpty || _contem(paciente.alergias, texto)) return false;
    _aplicar(paciente.copyWith(alergias: [...paciente.alergias, texto]));
    return true;
  }

  void removerAlergia(String item) {
    _aplicar(
      paciente.copyWith(
        alergias: paciente.alergias.where((a) => a != item).toList(),
      ),
    );
  }

  /// Devolve `false` se o texto for vazio ou já existir na lista.
  bool adicionarCondicao(String item) {
    final texto = item.trim();
    if (texto.isEmpty || _contem(paciente.condicoes, texto)) return false;
    _aplicar(paciente.copyWith(condicoes: [...paciente.condicoes, texto]));
    return true;
  }

  void removerCondicao(String item) {
    _aplicar(
      paciente.copyWith(
        condicoes: paciente.condicoes.where((c) => c != item).toList(),
      ),
    );
  }

  // ----- Preferências -----

  void definirLembretes(bool ativos) {
    _aplicar(paciente.copyWith(lembretesAtivos: ativos));
  }

  void definirTamanhoTexto(TamanhoTexto tamanho) {
    _aplicar(paciente.copyWith(tamanhoTexto: tamanho));
  }

  // ----- Internos -----

  /// Atualiza o paciente ativo, a conta correspondente e o disco.
  void _aplicar(Paciente novo) {
    _ativo = novo;
    final indice = _contas.indexWhere((c) => c.paciente.cpf == novo.cpf);
    if (indice >= 0) {
      _contas[indice] = _contas[indice].comPaciente(novo);
    }
    notifyListeners();
    unawaited(_salvarContas());
  }

  _Conta? _buscarPorCpf(String cpf) {
    for (final c in _contas) {
      if (c.paciente.cpf == cpf) return c;
    }
    return null;
  }

  Future<void> _salvarContas() async {
    // O JSON é montado antes do await: grava o estado deste instante.
    final json = jsonEncode(_contas.map((c) => c.toJson()).toList());
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveContas, json);
  }

  static bool _contem(List<String> lista, String texto) {
    final alvo = texto.toLowerCase();
    return lista.any((item) => item.toLowerCase() == alvo);
  }
}

/// Conta salva no aparelho: paciente + senha protegida por hash com salt.
///
/// ATENÇÃO: o hash abaixo é didático (protótipo local, sem servidor). Em
/// produção a autenticação deve ser feita por uma API (ex.: gov.br) com
/// bcrypt/argon2 — nunca guarde senhas no aparelho.
class _Conta {
  const _Conta({
    required this.paciente,
    required this.salt,
    required this.hash,
  });

  factory _Conta.nova(Paciente paciente, String senha) {
    final sorteio = Random.secure();
    final salt = List.generate(
      4,
      (_) => sorteio.nextInt(1 << 16).toRadixString(16).padLeft(4, '0'),
    ).join();
    return _Conta(paciente: paciente, salt: salt, hash: _gerarHash(senha, salt));
  }

  factory _Conta.fromJson(Map<String, dynamic> json) => _Conta(
        paciente: Paciente.fromJson(json['paciente'] as Map<String, dynamic>),
        salt: json['salt'] as String,
        hash: json['hash'] as String,
      );

  final Paciente paciente;
  final String salt;
  final String hash;

  bool confere(String senha) => _gerarHash(senha, salt) == hash;

  _Conta comPaciente(Paciente novo) =>
      _Conta(paciente: novo, salt: salt, hash: hash);

  Map<String, dynamic> toJson() => {
        'paciente': paciente.toJson(),
        'salt': salt,
        'hash': hash,
      };

  /// Mistura iterada de salt + senha em dois acumuladores de 32 bits
  /// (só usa números < 2^53, então dá o mesmo resultado no navegador).
  static String _gerarHash(String senha, String salt) {
    final dados = '$salt:$senha'.codeUnits;
    var a = 7;
    var b = 13;
    for (var rodada = 0; rodada < 2000; rodada++) {
      for (final c in dados) {
        a = (a * 31 + c + b) % 4294967296;
        b = (b * 131 + c + a) % 4294967296;
      }
    }
    return a.toRadixString(16).padLeft(8, '0') +
        b.toRadixString(16).padLeft(8, '0');
  }
}
