import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'erros.dart';
import 'supabase_config.dart';

/// Mantém a autorização para redefinir a senha apenas nesta tela, em memória.
class RecuperacaoSenha {
  String? _token;

  bool get codigoVerificado => _token != null;

  Future<void> enviarCodigo(String email) async {
    try {
      await supabase.auth
          .resetPasswordForEmail(email)
          .timeout(const Duration(seconds: 20));
    } on AuthException catch (erro) {
      if (erro.code == 'user_not_found') return;
      if (erro.statusCode == '429') {
        throw const ErroApp(
          'Aguarde um pouco antes de solicitar outro código.',
        );
      }
      throw const ErroApp('Não foi possível enviar o código. Tente novamente.');
    }
  }

  Future<void> verificarCodigo(String email, String codigo) async {
    // verifyOTP no cliente principal criaria uma sessão de login persistida.
    // A resposta de /verify fica restrita ao fluxo de recuperação.
    final resposta = await http
        .post(
          _url('verify'),
          headers: _headers(),
          body: jsonEncode({'type': 'recovery', 'email': email, 'token': codigo}),
        )
        .timeout(const Duration(seconds: 20));

    if (resposta.statusCode == 429) {
      throw const ErroApp('Muitas tentativas. Aguarde e tente novamente.');
    }
    if (resposta.statusCode == 400 ||
        resposta.statusCode == 401 ||
        resposta.statusCode == 403 ||
        resposta.statusCode == 422) {
      throw const ErroApp('Código inválido ou expirado. Confira ou reenvie.');
    }
    if (resposta.statusCode != 200) {
      throw const ErroApp('Não foi possível validar o código. Tente novamente.');
    }

    final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
    final token = dados['access_token'];
    if (token is! String || token.isEmpty) {
      throw const ErroApp('Não foi possível validar o código. Solicite outro.');
    }
    _token = token;
  }

  Future<void> redefinir(String senha) async {
    final token = _token;
    if (token == null) {
      throw const ErroApp('Valide o código antes de redefinir sua senha.');
    }

    final resposta = await http
        .put(
          _url('user'),
          headers: _headers(token),
          body: jsonEncode({'password': senha}),
        )
        .timeout(const Duration(seconds: 20));

    if (resposta.statusCode == 200) {
      unawaited(encerrar());
      return;
    }
    if (resposta.statusCode == 401 || resposta.statusCode == 403) {
      unawaited(encerrar());
      throw const ErroApp('A validação expirou. Solicite outro código.');
    }
    if (resposta.statusCode == 429) {
      throw const ErroApp('Muitas tentativas. Aguarde e tente novamente.');
    }

    final codigo = _codigoErro(resposta.body);
    if (codigo == 'same_password') {
      throw const ErroApp('Escolha uma senha diferente da anterior.');
    }
    if (codigo == 'weak_password' || codigo == 'validation_failed') {
      throw const ErroApp('A senha não atende aos requisitos de segurança.');
    }
    throw const ErroApp('Não foi possível redefinir a senha. Tente novamente.');
  }

  Future<void> encerrar() async {
    final token = _token;
    _token = null;
    if (token == null) return;

    try {
      await http
          .post(
            _url('logout').replace(queryParameters: {'scope': 'local'}),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // A autorização já foi descartada localmente.
    }
  }

  static Uri _url(String caminho) =>
      Uri.parse('${SupabaseConfig.url}/auth/v1/$caminho');

  static Map<String, String> _headers([String? token]) => {
        'apikey': SupabaseConfig.anonKey,
        'Content-Type': 'application/json',
        'X-Supabase-Api-Version': '2024-01-01',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Object? _codigoErro(String corpo) {
    try {
      final dados = jsonDecode(corpo);
      return dados is Map<String, dynamic>
          ? dados['code'] ?? dados['error_code']
          : null;
    } on FormatException {
      return null;
    }
  }
}