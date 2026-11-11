import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/paciente.dart';
import 'agendamento_repository.dart';
import 'cache_local.dart';
import 'dados_demo.dart';
import 'erros.dart';
import 'paciente_repository.dart';
import 'supabase_config.dart';

/// Repositório (singleton) da sessão, apoiado no Supabase Auth.
///
/// O Supabase guarda a senha (hash bcrypt) e mantém a sessão salva no
/// aparelho. Ao entrar, carrega o paciente e os agendamentos da conta.
/// Os métodos que podem falhar devolvem uma mensagem de erro (ou `null`).
class SessaoRepository extends ChangeNotifier {
  SessaoRepository._();

  static final SessaoRepository instance = SessaoRepository._();

  bool _logado = false;

  /// `id` do usuário logado (para apagar a cópia local ao sair).
  String? _usuarioId;

  bool get logado => _logado;

  /// CPF (só dígitos) da conta logada.
  String? get cpfAtivo => PacienteRepository.instance.temPaciente
      ? PacienteRepository.instance.paciente.cpf
      : null;

  /// Restaura a sessão salva pelo Supabase (se houver) e passa a ouvir
  /// mudanças de autenticação. Chamar uma vez no `main`.
  Future<void> inicializar() async {
    supabase.auth.onAuthStateChange.listen((dados) {
      if (dados.event == AuthChangeEvent.signedOut && _logado) _limpar();
    });

    if (supabase.auth.currentSession == null) return;
    try {
      await _carregarDados();
    } catch (erro) {
      debugPrint('SessaoRepository: não restaurou a sessão ($erro)');
      await _encerrarLocalmente();
    }
  }

  /// Entra com CPF (11 dígitos) ou CNS (15 dígitos) e senha.
  ///
  /// O Supabase autentica por e-mail: a função `email_de_login` descobre o
  /// e-mail da conta a partir do CPF/CNS.
  Future<String?> entrar({
    required String identificador,
    required String senha,
  }) async {
    final digitos = identificador.replaceAll(RegExp(r'\D'), '');
    try {
      final email = await supabase.rpc(
        'email_de_login',
        params: {'p_identificador': digitos},
      ) as String?;
      if (email == null) return 'CPF/CNS ou senha incorretos.';

      return await _autenticar(email, senha);
    } catch (erro) {
      return mensagemDeErro(erro);
    }
  }

  /// Cria a conta de um novo paciente e já entra com ela.
  ///
  /// Os dados vão em `data`; o trigger `criar_paciente_no_cadastro` cria a
  /// linha em `pacientes`. (Requer "Confirm email" desligado no Supabase.)
  Future<String?> cadastrar({
    required Paciente paciente,
    required String senha,
  }) async {
    try {
      // Avisos amigáveis antes de tentar (o banco também garante a unicidade).
      if (await _existeConta(paciente.cpf)) {
        return 'Já existe uma conta com este CPF.';
      }
      if (await _existeConta(paciente.cns)) {
        return 'Já existe uma conta com este CNS.';
      }

      final resposta = await supabase.auth.signUp(
        email: paciente.email,
        password: senha,
        data: {
          'nome': paciente.nome,
          'cpf': paciente.cpf,
          'cns': paciente.cns,
          'data_nascimento': _dataIso(paciente.dataNascimento),
          'tipo_sanguineo': paciente.tipoSanguineo,
          'telefone': paciente.telefone,
          'email': paciente.email,
          'endereco': paciente.endereco,
          'unidade_referencia_id': paciente.unidadeReferenciaId,
          'alergias': paciente.alergias,
          'condicoes': paciente.condicoes,
        },
      );

      if (resposta.session == null) {
        return 'Conta criada, mas é preciso confirmar o e-mail antes de '
            'entrar. (Desligue "Confirm email" no Supabase para dispensar.)';
      }

      try {
        await _carregarDados();
      } on PostgrestException catch (erro) {
        // PGRST116 = nenhuma linha em `pacientes` para este usuário: o
        // trigger de cadastro não rodou (SQL não aplicado). Grava direto.
        final usuarioId = supabase.auth.currentUser?.id ?? resposta.user?.id;
        if (erro.code != 'PGRST116' || usuarioId == null) {
          await _encerrarLocalmente();
          return mensagemDeErro(erro);
        }
        debugPrint(
          'SessaoRepository: o trigger criar_paciente_no_cadastro não criou '
          'a linha em pacientes. Gravando direto pelo app. Rode o '
          'supabase_setup.sql para corrigir o banco.',
        );
        try {
          await _gravarPacienteDireto(usuarioId, paciente);
          await _carregarDados();
        } catch (erroDireto) {
          await _encerrarLocalmente();
          return mensagemDeErro(erroDireto);
        }
      } catch (erro) {
        await _encerrarLocalmente();
        return mensagemDeErro(erro);
      }
      return null;
    } catch (erro) {
      return mensagemDeErro(erro);
    }
  }

  /// Plano B do cadastro: insere o paciente da conta recém-criada. Exige a
  /// política `paciente_insere_proprio` do `supabase_setup.sql` (RLS).
  Future<void> _gravarPacienteDireto(String usuarioId, Paciente p) async {
    await supabase.from('pacientes').insert({
      'id': usuarioId,
      'nome': p.nome,
      'cpf': p.cpf,
      'cns': p.cns,
      'data_nascimento': _dataIso(p.dataNascimento),
      'tipo_sanguineo': p.tipoSanguineo.isEmpty ? null : p.tipoSanguineo,
      'telefone': p.telefone,
      'email': p.email,
      'endereco': p.endereco,
      'unidade_referencia_id': p.unidadeReferenciaId,
      'alergias': p.alergias,
      'condicoes': p.condicoes,
    });
  }

  /// Entra direto com a paciente de demonstração (criada no Supabase pela
  /// seção 7 do SQL).
  Future<String?> entrarComoDemo() async {
    try {
      return await _autenticar(DadosDemo.email, DadosDemo.senha);
    } catch (erro) {
      final m = mensagemDeErro(erro);
      return m == 'CPF/CNS ou senha incorretos.'
          ? 'Conta de demonstração não encontrada no Supabase. '
              'Crie-a conforme a seção 7 do SQL.'
          : m;
    }
  }

  /// Encerra a sessão. Os dados continuam salvos na nuvem.
  Future<void> sair() async {
    try {
      await supabase.auth.signOut();
    } catch (erro) {
      debugPrint('SessaoRepository: falha ao sair no servidor ($erro)');
      await _encerrarLocalmente();
    }
    _limpar();
  }

  /// Exclui a conta e todos os dados (direito de exclusão da LGPD).
  /// Devolve uma mensagem de erro, ou `null` se deu certo.
  Future<String?> excluirConta() async {
    try {
      await supabase.rpc('excluir_minha_conta');
    } catch (erro) {
      return mensagemDeErro(erro);
    }
    // O usuário já não existe: só limpa a sessão guardada no aparelho.
    await _encerrarLocalmente();
    _limpar();
    return null;
  }

  // ----- Internos -----

  Future<String?> _autenticar(String email, String senha) async {
    await supabase.auth.signInWithPassword(email: email, password: senha);
    try {
      await _carregarDados();
    } catch (erro) {
      await _encerrarLocalmente();
      return mensagemDeErro(erro);
    }
    return null;
  }

  Future<bool> _existeConta(String cpfOuCns) async {
    final email = await supabase.rpc(
      'email_de_login',
      params: {'p_identificador': cpfOuCns},
    );
    return email != null;
  }

  Future<void> _carregarDados() async {
    await PacienteRepository.instance.carregar();
    await AgendamentoRepository.instance.carregar();
    _usuarioId = supabase.auth.currentUser?.id;
    _logado = true;
    notifyListeners();
  }

  Future<void> _encerrarLocalmente() async {
    try {
      await supabase.auth.signOut(scope: SignOutScope.local);
    } catch (erro) {
      debugPrint('SessaoRepository: falha ao limpar sessão local ($erro)');
    }
  }

  void _limpar() {
    // Primeiro troca a tela (AppRaiz volta ao login), depois apaga os dados.
    final usuarioId = _usuarioId;
    _usuarioId = null;
    if (usuarioId != null) CacheLocal.limparUsuario(usuarioId);
    _logado = false;
    notifyListeners();
    PacienteRepository.instance.limpar();
    AgendamentoRepository.instance.limpar();
  }

  static String _dataIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
