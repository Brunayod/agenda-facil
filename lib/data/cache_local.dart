import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cópia local (somente leitura) dos dados do usuário, em `shared_preferences`.
///
/// A fonte da verdade é o Supabase. Depois de cada leitura ou gravação
/// bem-sucedida o app guarda aqui uma cópia; se a internet cair ao abrir o
/// app, as telas mostram esta cópia em vez de deslogar o usuário. Alterações
/// feitas sem conexão NÃO são aceitas (o app mostra o erro de conexão).
///
/// Nunca lança: falhas de disco só aparecem no `debugPrint`.
abstract final class CacheLocal {
  static String _chave(String tipo, String usuarioId) =>
      'af.cache.$tipo.$usuarioId';

  static const _tipos = ['paciente', 'agendamentos'];

  static Future<void> salvar(String tipo, String usuarioId, Object json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chave(tipo, usuarioId), jsonEncode(json));
    } catch (erro) {
      debugPrint('CacheLocal: não salvou "$tipo" ($erro)');
    }
  }

  /// Devolve o JSON decodificado (mapa ou lista), ou `null` se não houver.
  static Future<Object?> ler(String tipo, String usuarioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bruto = prefs.getString(_chave(tipo, usuarioId));
      return bruto == null ? null : jsonDecode(bruto) as Object?;
    } catch (erro) {
      debugPrint('CacheLocal: não leu "$tipo" ($erro)');
      return null;
    }
  }

  /// Apaga as cópias do usuário (ao sair da conta ou excluí-la).
  static Future<void> limparUsuario(String usuarioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final tipo in _tipos) {
        await prefs.remove(_chave(tipo, usuarioId));
      }
    } catch (erro) {
      debugPrint('CacheLocal: não limpou o cache ($erro)');
    }
  }
}
