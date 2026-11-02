/// Validações de formulário (login e cadastro). Cada método devolve a
/// mensagem de erro ou `null` quando o valor é válido.
abstract final class Validadores {
  static final _regexEmail = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// Só os dígitos de [texto].
  static String digitos(String? texto) =>
      (texto ?? '').replaceAll(RegExp(r'\D'), '');

  /// Confere tamanho, sequências repetidas e os dois dígitos verificadores.
  static bool cpfValido(String digitos) {
    if (digitos.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(digitos)) return false;

    int verificador(int quantidade) {
      var soma = 0;
      for (var i = 0; i < quantidade; i++) {
        soma += int.parse(digitos[i]) * (quantidade + 1 - i);
      }
      final resto = (soma * 10) % 11;
      return resto == 10 ? 0 : resto;
    }

    return verificador(9) == int.parse(digitos[9]) &&
        verificador(10) == int.parse(digitos[10]);
  }

  static String? cpf(String? valor) {
    final d = digitos(valor);
    if (d.length != 11) return 'O CPF tem 11 dígitos.';
    if (!cpfValido(d)) return 'CPF inválido. Confira os números.';
    return null;
  }

  static String? cns(String? valor) {
    if (digitos(valor).length != 15) return 'O Cartão SUS tem 15 dígitos.';
    return null;
  }

  /// Campo de login: aceita CPF (11 dígitos) ou CNS (15 dígitos).
  static String? cpfOuCns(String? valor) {
    final d = digitos(valor);
    if (d.isEmpty) return 'Informe seu CPF ou Cartão SUS.';
    if (d.length == 11) return cpf(valor);
    if (d.length == 15) return null;
    return 'Digite 11 dígitos (CPF) ou 15 dígitos (Cartão SUS).';
  }

  static String? nome(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.length < 5 || !texto.contains(' ')) {
      return 'Informe o nome completo.';
    }
    return null;
  }

  /// Converte "dd/mm/aaaa" em data, ou `null` se não existir no calendário.
  static DateTime? converterData(String? valor) {
    final d = digitos(valor);
    if (d.length != 8) return null;
    final dia = int.parse(d.substring(0, 2));
    final mes = int.parse(d.substring(2, 4));
    final ano = int.parse(d.substring(4));
    final data = DateTime(ano, mes, dia);
    if (data.day != dia || data.month != mes || data.year != ano) return null;
    return data;
  }

  static String? dataNascimento(String? valor) {
    final data = converterData(valor);
    if (data == null) return 'Informe uma data válida (dd/mm/aaaa).';
    if (data.year < 1900 || data.isAfter(DateTime.now())) {
      return 'Data de nascimento inválida.';
    }
    return null;
  }

  static String? telefone(String? valor) {
    final d = digitos(valor);
    if (d.length < 10 || d.length > 11) return 'Informe o telefone com DDD.';
    return null;
  }

  static String? email(String? valor) {
    if (!_regexEmail.hasMatch((valor ?? '').trim())) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  static String? senha(String? valor) {
    if ((valor ?? '').length < 6) return 'Use pelo menos 6 caracteres.';
    return null;
  }
}
