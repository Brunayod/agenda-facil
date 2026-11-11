import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Erro de regra do app, com mensagem pronta para mostrar ao usuário.
class ErroApp implements Exception {
  const ErroApp(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Escreve no console (`debugPrint`) o erro COMPLETO do Supabase, com código,
/// detalhes e uma dica de correção. Chamada por [mensagemDeErro], então todo
/// erro que chega a uma tela fica registrado.
void registrarErro(Object erro) {
  if (erro is ErroApp) return;

  if (erro is PostgrestException) {
    debugPrint(
      '[Supabase/Postgrest] code=${erro.code} message="${erro.message}" '
      'details=${erro.details} hint=${erro.hint}',
    );
    final dica = _dicaDePostgrest(erro);
    if (dica != null) debugPrint('[Supabase] DICA: $dica');
  } else if (erro is AuthException) {
    debugPrint(
      '[Supabase/Auth] status=${erro.statusCode} message="${erro.message}"',
    );
    if (erro.message.toLowerCase().contains('database error')) {
      debugPrint(
        '[Supabase] DICA: o trigger criar_paciente_no_cadastro falhou ao '
        'inserir em public.pacientes. Causas comuns: a UBS escolhida não '
        'existe em public.unidades, CPF/CNS repetidos ou fora do formato, '
        'ou o supabase_setup.sql não foi executado. Veja o erro exato em '
        'Supabase > Logs > Postgres.',
      );
    }
  } else {
    debugPrint('[Erro] ${erro.runtimeType}: $erro');
  }
}

String? _dicaDePostgrest(PostgrestException erro) {
  final texto = '${erro.message} ${erro.details ?? ''}'.toLowerCase();
  if (erro.code == '42501' || texto.contains('row-level security')) {
    return 'Política RLS ou permissão (GRANT) faltando para esta operação. '
        'Rode o supabase_setup.sql no SQL Editor do Supabase.';
  }
  if (erro.code == '42703' ||
      erro.code == 'PGRST204' ||
      (texto.contains('column') && texto.contains('does not exist')) ||
      texto.contains("could not find the '")) {
    return 'Coluna inexistente no banco (ex.: latitude/longitude em '
        'public.unidades). Rode o supabase_setup.sql no SQL Editor.';
  }
  if (erro.code == '42P01' || erro.code == 'PGRST205') {
    return 'Tabela não encontrada. Rode o supabase_setup.sql no SQL Editor.';
  }
  if (erro.code == 'PGRST202' ||
      texto.contains('could not find the function')) {
    return 'Função (RPC) não encontrada. Rode o supabase_setup.sql.';
  }
  if (erro.code == '23503') {
    return 'Chave estrangeira violada (ex.: unidade_referencia_id que não '
        'existe em public.unidades). Rode o supabase_setup.sql.';
  }
  if (erro.code == 'PGRST116') {
    return 'A consulta não devolveu a linha esperada (ex.: o paciente não '
        'foi criado em public.pacientes, ou a RLS escondeu a linha).';
  }
  return null;
}

/// Converte qualquer erro (Supabase, rede, regra do app) em texto amigável.
/// Também registra o erro completo no console (veja [registrarErro]).
String mensagemDeErro(Object erro) {
  registrarErro(erro);
  if (erro is ErroApp) return erro.mensagem;

  if (erro is AuthException) {
    final m = erro.message.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'CPF/CNS ou senha incorretos.';
    }
    if (m.contains('already registered') || m.contains('already been')) {
      return 'Já existe uma conta com este e-mail.';
    }
    if (m.contains('database error')) {
      // O trigger de cadastro falhou (CPF, CNS ou dados inválidos/repetidos).
      return 'Não foi possível criar a conta. Confira se CPF, CNS e e-mail '
          'ainda não estão cadastrados.';
    }
    if (m.contains('password')) {
      return 'A senha não atende aos requisitos mínimos.';
    }
    if (m.contains('rate limit') || m.contains('too many')) {
      return 'Muitas tentativas. Aguarde um instante e tente de novo.';
    }
    return erro.message;
  }

  if (erro is PostgrestException) {
    // 23505 = violação de unicidade (ex.: dois agendamentos no mesmo horário).
    if (erro.code == '23505') {
      return 'Você já tem um agendamento nesse horário.';
    }
    // Regras dos triggers (ex.: "Agendamentos só em dias úteis.").
    if (erro.code == 'P0001') return erro.message;
    // Em modo debug mostra o código técnico para facilitar o diagnóstico.
    return kDebugMode
        ? 'Não foi possível concluir a operação '
            '(${erro.code}: ${erro.message}).'
        : 'Não foi possível concluir a operação. Tente novamente.';
  }

  // Sem internet, timeout, etc.
  return 'Sem conexão com o servidor. Verifique sua internet e tente de novo.';
}
