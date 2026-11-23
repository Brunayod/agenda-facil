import 'package:flutter/services.dart';

/// Funções que recebem só dígitos e devolvem o texto formatado.
abstract final class Mascaras {
  static String apenasDigitos(String texto) =>
      texto.replaceAll(RegExp(r'\D'), '');

  /// 000.000.000-00
  static String cpf(String digitos) {
    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i == 3 || i == 6) buffer.write('.');
      if (i == 9) buffer.write('-');
      buffer.write(digitos[i]);
    }
    return buffer.toString();
  }

  /// 000 0000 0000 0000
  static String cns(String digitos) {
    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i == 3 || i == 7 || i == 11) buffer.write(' ');
      buffer.write(digitos[i]);
    }
    return buffer.toString();
  }

  /// CPF até 11 dígitos; a partir do 12º vira CNS.
  static String cpfOuCns(String digitos) =>
      digitos.length <= 11 ? cpf(digitos) : cns(digitos);

  /// (11) 91234-5678 ou (11) 1234-5678
  static String telefone(String digitos) {
    if (digitos.isEmpty) return '';
    final posicaoHifen = digitos.length > 10 ? 7 : 6;
    final buffer = StringBuffer('(');
    for (var i = 0; i < digitos.length; i++) {
      if (i == 2) buffer.write(') ');
      if (i == posicaoHifen) buffer.write('-');
      buffer.write(digitos[i]);
    }
    return buffer.toString();
  }

  /// dd/MM/aaaa
  static String data(String digitos) {
    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(digitos[i]);
    }
    return buffer.toString();
  }
}

/// Formatter de campo de texto: mantém só os dígitos, limita o tamanho e
/// aplica a máscara enquanto o usuário digita.
class MascaraInput extends TextInputFormatter {
  const MascaraInput(this.formatar, {required this.maxDigitos});

  final String Function(String digitos) formatar;
  final int maxDigitos;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue valorAntigo,
    TextEditingValue valorNovo,
  ) {
    var digitos = Mascaras.apenasDigitos(valorNovo.text);
    if (digitos.length > maxDigitos) digitos = digitos.substring(0, maxDigitos);

    final texto = formatar(digitos);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
