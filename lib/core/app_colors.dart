import 'package:flutter/material.dart';

/// Paleta extraída do protótipo do Figma.
abstract final class AppColors {
  // Azuis
  static const azulHeader = Color(0xFF0D7EE8);
  static const azulPrimario = Color(0xFF0068C9);
  static const azulEscuro = Color(0xFF173B68);
  static const azulMedio = Color(0xFF335682);
  static const azulSubtitulo = Color(0xFF1B4A84);
  static const azulTexto = Color(0xFF1763B7);

  // Superfícies
  static const fundo = Color(0xFFEFF0F0);
  static const azulOnda = Color(0xFFDDEEFF);
  static const azulBordaCard = Color(0xFFD9E8F7);
  static const azulAbaInativa = Color(0xFFEAF3FF);

  // Textos / ícones neutros
  static const textoSecundario = Color(0xFF6B7E95);
  static const iconeInativo = Color(0xFFC0CCD8);

  // Cards de agendamento (borda cinza a 48% de opacidade)
  static const bordaAgendamento = Color(0x7A6B7E95);

  // Chips de status
  static const confirmadoFundo = Color(0xFFA0F5C0);
  static const confirmadoTexto = Color(0xFF187744);
  static const confirmadoBorda = Color(0x363D614B); // #3D614B a 21%
  static const realizadoFundo = Color(0xFFE5F0FF);
  static const realizadoTexto = Color(0xFF1763B7);
  static const naoCompareceuFundo = Color(0xFFF0EAFE);
  static const naoCompareceuTexto = Color(0xFF6638B8);
  static const canceladoFundo = Color(0xFFFDE8E8);
  static const canceladoTexto = Color(0xFFB3261E);
}
