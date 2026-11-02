import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../models/paciente.dart';
import 'cartao_sus.dart';
import 'codigos_simulados.dart';

/// Modal com o cartão ampliado, QR Code e código de barras (simulados)
/// para apresentar na recepção da UBS.
abstract final class CartaoSusSheet {
  static Future<void> mostrar(BuildContext context, Paciente paciente) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _Conteudo(paciente: paciente),
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.paciente});

  final Paciente paciente;

  @override
  Widget build(BuildContext context) {
    final inferior = MediaQuery.paddingOf(context).bottom;
    final altura = MediaQuery.sizeOf(context).height;

    return Container(
      constraints: BoxConstraints(maxHeight: altura * 0.95),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.iconeInativo,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + inferior),
              child: Column(
                children: [
                  Semantics(
                    header: true,
                    child: Text('Cartão SUS Digital', style: AppText.listaTitulo),
                  ),
                  Text(
                    'Apresente na recepção da UBS',
                    style: AppText.formAjuda,
                  ),
                  const SizedBox(height: 16),
                  CartaoSus(paciente: paciente, ampliado: true),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.azulBordaCard,
                        width: 2,
                      ),
                    ),
                    child: Semantics(
                      image: true,
                      label: 'QR Code ilustrativo do Cartão SUS',
                      child: CustomPaint(
                        size: const Size(210, 210),
                        painter: QrSimuladoPainter(paciente.cns),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 260,
                    height: 56,
                    child: Semantics(
                      image: true,
                      label: 'Código de barras ilustrativo do Cartão SUS',
                      child: CustomPaint(
                        painter: CodigoBarrasSimuladoPainter(paciente.cns),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    paciente.cnsFormatado,
                    style: AppText.opcao(
                      AppColors.azulEscuro,
                      peso: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Códigos ilustrativos do protótipo: ainda não são '
                    'legíveis por leitores da UBS.',
                    textAlign: TextAlign.center,
                    style: AppText.formAjuda,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
