import 'package:flutter/services.dart';

/// Base dos formatadores que mantêm só dígitos e aplicam uma máscara.
abstract class _FormatoDigitos extends TextInputFormatter {
  const _FormatoDigitos(this.maxDigitos);

  final int maxDigitos;

  String formatar(String digitos);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue antigo,
    TextEditingValue novo,
  ) {
    var digitos = novo.text.replaceAll(RegExp(r'\D'), '');
    if (digitos.length > maxDigitos) {
      digitos = digitos.substring(0, maxDigitos);
    }
    final texto = formatar(digitos);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

String _mascaraCpf(String d) {
  if (d.length <= 3) return d;
  if (d.length <= 6) return '${d.substring(0, 3)}.${d.substring(3)}';
  if (d.length <= 9) {
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6)}';
  }
  return '${d.substring(0, 3)}.${d.substring(3, 6)}.'
      '${d.substring(6, 9)}-${d.substring(9)}';
}

String _mascaraCns(String d) {
  final partes = <String>[];
  const cortes = [3, 7, 11, 15];
  var inicio = 0;
  for (final fim in cortes) {
    if (inicio >= d.length) break;
    partes.add(d.substring(inicio, fim < d.length ? fim : d.length));
    inicio = fim;
  }
  return partes.join(' ');
}

/// "123.456.789-09".
class FormatoCpf extends _FormatoDigitos {
  const FormatoCpf() : super(11);

  @override
  String formatar(String digitos) => _mascaraCpf(digitos);
}

/// "700 1234 5678 9012".
class FormatoCns extends _FormatoDigitos {
  const FormatoCns() : super(15);

  @override
  String formatar(String digitos) => _mascaraCns(digitos);
}

/// Campo único de login: até 11 dígitos vira CPF, de 12 a 15 vira CNS.
class FormatoCpfOuCns extends _FormatoDigitos {
  const FormatoCpfOuCns() : super(15);

  @override
  String formatar(String digitos) =>
      digitos.length <= 11 ? _mascaraCpf(digitos) : _mascaraCns(digitos);
}

/// "(11) 98765-4321" ou "(11) 3456-7890".
class FormatoTelefone extends _FormatoDigitos {
  const FormatoTelefone() : super(11);

  @override
  String formatar(String digitos) {
    if (digitos.isEmpty) return '';
    if (digitos.length <= 2) return '($digitos';
    final ddd = digitos.substring(0, 2);
    final resto = digitos.substring(2);
    if (resto.length <= 4) return '($ddd) $resto';
    if (digitos.length <= 10) {
      return '($ddd) ${resto.substring(0, 4)}-${resto.substring(4)}';
    }
    return '($ddd) ${resto.substring(0, 5)}-${resto.substring(5)}';
  }
}

/// "14/05/1998".
class FormatoData extends _FormatoDigitos {
  const FormatoData() : super(8);

  @override
  String formatar(String digitos) {
    if (digitos.length <= 2) return digitos;
    if (digitos.length <= 4) {
      return '${digitos.substring(0, 2)}/${digitos.substring(2)}';
    }
    return '${digitos.substring(0, 2)}/${digitos.substring(2, 4)}/'
        '${digitos.substring(4)}';
  }
}
