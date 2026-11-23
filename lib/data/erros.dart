import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Erro de regra do app, com mensagem pronta para mostrar ao usuário.
class ErroApp implements Exception {
  const ErroApp(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

const mensagemSemConexao =
    'Sem conexão com o servidor. Verifique sua internet e tente de novo.';

const mensagemSemCadastro = 'Não encontramos o cadastro desta conta no banco.';

/// Converte qualquer erro (Supabase, rede, regra do app) em texto amigável.
String mensagemDeErro(Object erro) {
  // A causa real aparece no console do `flutter run` (não vai para o usuário).
  debugPrint('mensagemDeErro -> ${erro.runtimeType}: $erro');

  if (erro is ErroApp) return erro.mensagem;

  if (erro is AuthException) {
    final m = erro.message.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'CPF/CNS ou senha incorretos.';
    }
    if (m.contains('email not confirmed')) {
      return 'Este e-mail ainda não foi confirmado.';
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
    // PGRST116 = a consulta .single() não achou a linha (conta sem cadastro).
    if (erro.code == 'PGRST116') return mensagemSemCadastro;
    // 42501 = permissão negada (RLS ou GRANT faltando).
    if (erro.code == '42501') {
      return 'O banco recusou o acesso. Confira as políticas (RLS) e permissões.';
    }
    return 'Não foi possível concluir a operação. Tente novamente.';
  }

  // Sem internet, timeout, projeto pausado, etc.
  return mensagemSemConexao;
}
