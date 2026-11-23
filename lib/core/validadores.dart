import 'mascaras.dart';

/// Validações de formulário (devolvem `null` quando o valor é válido).
abstract final class Validadores {
  static final _regexEmail = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  /// CPF com dígitos verificadores corretos.
  static bool cpfValido(String texto) {
    final d = Mascaras.apenasDigitos(texto);
    if (d.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;

    int digitoVerificador(int quantidade) {
      var soma = 0;
      for (var i = 0; i < quantidade; i++) {
        soma += int.parse(d[i]) * (quantidade + 1 - i);
      }
      final resto = (soma * 10) % 11;
      return resto == 10 ? 0 : resto;
    }

    return digitoVerificador(9) == int.parse(d[9]) &&
        digitoVerificador(10) == int.parse(d[10]);
  }

  /// CNS (15 dígitos) com dígito verificador correto.
  static bool cnsValido(String texto) {
    final d = Mascaras.apenasDigitos(texto);
    if (d.length != 15) return false;

    int soma(int quantidade) {
      var total = 0;
      for (var i = 0; i < quantidade; i++) {
        total += int.parse(d[i]) * (15 - i);
      }
      return total;
    }

    final primeiro = d[0];
    if (primeiro == '1' || primeiro == '2') {
      final pis = d.substring(0, 11);
      var total = soma(11);
      var dv = 11 - (total % 11);
      if (dv == 11) dv = 0;
      if (dv == 10) {
        total += 2;
        dv = 11 - (total % 11);
        return d == '${pis}001$dv';
      }
      return d == '${pis}000$dv';
    }
    if (primeiro == '7' || primeiro == '8' || primeiro == '9') {
      return soma(15) % 11 == 0;
    }
    return false;
  }

  /// Data no formato dd/MM/aaaa, existente, de 1900 até hoje.
  static DateTime? dataNascimento(String texto) {
    final d = Mascaras.apenasDigitos(texto);
    if (d.length != 8) return null;

    final dia = int.parse(d.substring(0, 2));
    final mes = int.parse(d.substring(2, 4));
    final ano = int.parse(d.substring(4));
    final data = DateTime(ano, mes, dia);

    final existe = data.year == ano && data.month == mes && data.day == dia;
    if (!existe || ano < 1900 || data.isAfter(DateTime.now())) return null;
    return data;
  }

  static bool emailValido(String texto) => _regexEmail.hasMatch(texto.trim());

  static bool telefoneValido(String texto) {
    final tamanho = Mascaras.apenasDigitos(texto).length;
    return tamanho == 10 || tamanho == 11;
  }

  /// Campo "CPF ou CNS" do login.
  static String? cpfOuCns(String? texto) {
    final d = Mascaras.apenasDigitos(texto ?? '');
    if (d.isEmpty) return 'Informe seu CPF ou Cartão SUS.';
    if (d.length == 11) return cpfValido(d) ? null : 'CPF inválido.';
    if (d.length == 15) return cnsValido(d) ? null : 'Cartão SUS (CNS) inválido.';
    return 'Informe 11 dígitos (CPF) ou 15 dígitos (CNS).';
  }
}
