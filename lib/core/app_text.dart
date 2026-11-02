import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Estilos de texto do protótipo (fonte Poppins).
abstract final class AppText {
  static TextStyle _poppins(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
  }) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  // Header
  static TextStyle get headerTitulo =>
      _poppins(18, FontWeight.w700, AppColors.azulEscuro, height: 1.5);
  static TextStyle get headerSubtitulo =>
      _poppins(12, FontWeight.w400, AppColors.azulSubtitulo, height: 1.4);

  // Home
  static TextStyle get tituloSecao =>
      _poppins(24, FontWeight.w600, AppColors.azulEscuro, height: 1.5);
  static TextStyle get menuTitulo =>
      _poppins(18, FontWeight.w600, AppColors.azulEscuro, height: 1.4);
  static TextStyle get menuSubtitulo =>
      _poppins(13, FontWeight.w400, AppColors.textoSecundario, height: 1.5);

  // Agendamentos
  static TextStyle get abaTexto => _poppins(16, FontWeight.w400, Colors.white);
  static TextStyle get abaTextoInativa =>
      _poppins(16, FontWeight.w400, AppColors.azulTexto);
  static TextStyle get listaTitulo =>
      _poppins(20, FontWeight.w500, AppColors.azulMedio, height: 1.5);
  static TextStyle get listaSubtitulo =>
      _poppins(14, FontWeight.w400, AppColors.azulEscuro, height: 1.5);
  static TextStyle get cardTitulo =>
      _poppins(20, FontWeight.w500, AppColors.azulMedio, height: 1.4);
  static TextStyle get cardUnidade =>
      _poppins(14, FontWeight.w400, AppColors.textoSecundario, height: 1.4);
  static TextStyle get cardData =>
      _poppins(14, FontWeight.w400, AppColors.textoSecundario, height: 1.4);
  static TextStyle chip(Color cor) => _poppins(15, FontWeight.w400, cor);

  // Navegação
  static TextStyle get navRotulo =>
      _poppins(12, FontWeight.w400, AppColors.azulEscuro, height: 1.3);

  // Placeholder
  static TextStyle get placeholder =>
      _poppins(16, FontWeight.w400, AppColors.textoSecundario);

  // Formulário (novo agendamento / reagendar)
  static TextStyle get formSecao =>
      _poppins(16, FontWeight.w600, AppColors.azulEscuro, height: 1.4);
  static TextStyle get formRotulo =>
      _poppins(13, FontWeight.w500, AppColors.azulMedio, height: 1.4);
  static TextStyle get formAjuda =>
      _poppins(13, FontWeight.w400, AppColors.textoSecundario, height: 1.5);
  static TextStyle opcao(Color cor, {FontWeight peso = FontWeight.w500}) =>
      _poppins(14, peso, cor, height: 1.4);
  static TextStyle botao(Color cor) => _poppins(16, FontWeight.w600, cor);
  static TextStyle diaSemana(Color cor) =>
      _poppins(12, FontWeight.w500, cor, height: 1.3);
  static TextStyle diaNumero(Color cor) =>
      _poppins(20, FontWeight.w600, cor, height: 1.2);

  // Detalhes do agendamento
  static TextStyle get detalheRotulo =>
      _poppins(12, FontWeight.w500, AppColors.textoSecundario, height: 1.4);
  static TextStyle get detalheValor =>
      _poppins(14, FontWeight.w500, AppColors.azulEscuro, height: 1.45);
  static TextStyle get detalheCorpo =>
      _poppins(14, FontWeight.w400, AppColors.azulEscuro, height: 1.5);
  static TextStyle get protocolo => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.azulPrimario,
        letterSpacing: 1.2,
      );
  static TextStyle get snack =>
      _poppins(14, FontWeight.w400, Colors.white, height: 1.4);

  // Rede de saúde
  static TextStyle get unidadeNome =>
      _poppins(17, FontWeight.w600, AppColors.azulEscuro, height: 1.3);
  static TextStyle get distancia =>
      _poppins(13, FontWeight.w600, AppColors.azulPrimario, height: 1.3);
  static TextStyle get tag =>
      _poppins(12, FontWeight.w500, AppColors.azulTexto, height: 1.3);

  // Campos de texto
  static TextStyle get campo =>
      _poppins(15, FontWeight.w400, AppColors.azulEscuro, height: 1.4);
  static TextStyle get campoRotulo =>
      _poppins(14, FontWeight.w400, AppColors.textoSecundario);
  static TextStyle get campoErro =>
      _poppins(12, FontWeight.w400, AppColors.canceladoTexto, height: 1.3);

  // Cartão SUS Digital (texto branco sobre o gradiente azul)
  static TextStyle get cartaoTitulo => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 1,
      );
  static TextStyle get cartaoRotulo => GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.brancoSuave,
        letterSpacing: 0.6,
      );
  static TextStyle get cartaoNome =>
      _poppins(18, FontWeight.w700, Colors.white, height: 1.3);
  static TextStyle get cartaoCns => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 1.6,
        height: 1.3,
      );
  static TextStyle get cartaoValor =>
      _poppins(13, FontWeight.w600, Colors.white, height: 1.3);
}
