import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_assets.dart';
import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../models/paciente.dart';

/// Cartão SUS Digital (CNS) com gradiente azul.
/// Com [onTap] vira um botão (ex.: abrir o cartão ampliado).
class CartaoSus extends StatelessWidget {
  const CartaoSus({
    super.key,
    required this.paciente,
    this.onTap,
    this.ampliado = false,
  });

  final Paciente paciente;
  final VoidCallback? onTap;

  /// Versão maior, usada no modal para apresentar na recepção.
  final bool ampliado;

  @override
  Widget build(BuildContext context) {
    final e = ampliado ? 1.12 : 1.0;
    final p = paciente;

    return Semantics(
      button: onTap != null,
      label: 'Cartão SUS Digital de ${p.nome}. CNS ${p.cnsFormatado}. '
          'CPF ${p.cpfFormatado}. Nascimento ${p.dataNascimentoFormatada}. '
          'Tipo sanguíneo ${p.tipoSanguineo}.'
          '${onTap != null ? ' Toque para ampliar.' : ''}',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: Ink(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.azulEscuro,
                  AppColors.azulPrimario,
                  AppColors.azulHeader,
                ],
              ),
            ),
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  const Positioned(
                    right: -24,
                    bottom: -34,
                    child: Icon(
                      Icons.add,
                      size: 170,
                      color: AppColors.cartaoMarca,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(ampliado ? 22 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'CARTÃO NACIONAL DE SAÚDE',
                                    style: AppText.cartaoTitulo,
                                  ),
                                  Text(
                                    'Cartão SUS Digital',
                                    style: AppText.cartaoRotulo,
                                  ),
                                ],
                              ),
                            ),
                            SvgPicture.asset(
                              AppAssets.botaoCentral,
                              height: 54 * e,
                            ),
                          ],
                        ),
                        SizedBox(height: 14 * e),
                        Text('CNS', style: AppText.cartaoRotulo),
                        Text(
                          p.cnsFormatado,
                          style: AppText.cartaoCns
                              .copyWith(fontSize: 20 * e),
                        ),
                        SizedBox(height: 10 * e),
                        Text(
                          p.nome,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.cartaoNome
                              .copyWith(fontSize: 18 * e),
                        ),
                        SizedBox(height: 14 * e),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _Campo(
                                rotulo: 'CPF',
                                valor: p.cpfFormatado,
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: _Campo(
                                rotulo: 'NASCIMENTO',
                                valor: p.dataNascimentoFormatada,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: _Campo(
                                rotulo: 'TIPO SANGUÍNEO',
                                valor: p.tipoSanguineo,
                              ),
                            ),
                          ],
                        ),
                        if (onTap != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.qr_code_2,
                                size: 18,
                                color: AppColors.brancoSuave,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Toque para ampliar e mostrar o QR Code',
                                style: AppText.cartaoRotulo,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: AppText.cartaoRotulo),
        Text(valor, style: AppText.cartaoValor),
      ],
    );
  }
}
