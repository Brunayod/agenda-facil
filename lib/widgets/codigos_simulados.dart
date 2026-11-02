import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// Gera uma sequência numérica repetível a partir de um texto.
class _Aleatorio {
  _Aleatorio(String semente) {
    _estado = semente.codeUnits.fold<int>(7, (h, c) => (h * 31 + c) & 0x7fffffff);
  }

  late int _estado;

  int proximo() {
    _estado = (_estado * 1103515245 + 12345) & 0x7fffffff;
    return _estado >> 16;
  }
}

/// Desenha um "QR Code" ilustrativo (não é um QR válido para leitura).
class QrSimuladoPainter extends CustomPainter {
  QrSimuladoPainter(this.semente, {this.cor = AppColors.azulEscuro});

  final String semente;
  final Color cor;

  static const int _modulos = 29;

  /// Padrão dos três quadrados de posicionamento (7x7).
  static bool _localizador(int x, int y) {
    final borda = x == 0 || x == 6 || y == 0 || y == 6;
    final centro = x >= 2 && x <= 4 && y >= 2 && y <= 4;
    return borda || centro;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final lado = size.shortestSide / _modulos;
    final pincel = Paint()..color = cor;
    final aleatorio = _Aleatorio(semente);

    for (var y = 0; y < _modulos; y++) {
      for (var x = 0; x < _modulos; x++) {
        final bit = aleatorio.proximo() & 1 == 1;

        bool ativo;
        final noTopoEsq = x < 8 && y < 8;
        final noTopoDir = x >= _modulos - 8 && y < 8;
        final noBaseEsq = x < 8 && y >= _modulos - 8;

        if (noTopoEsq) {
          ativo = x < 7 && y < 7 && _localizador(x, y);
        } else if (noTopoDir) {
          final lx = x - (_modulos - 7);
          ativo = lx >= 0 && y < 7 && _localizador(lx, y);
        } else if (noBaseEsq) {
          final ly = y - (_modulos - 7);
          ativo = ly >= 0 && x < 7 && _localizador(x, ly);
        } else {
          ativo = bit;
        }

        if (ativo) {
          canvas.drawRect(
            Rect.fromLTWH(x * lado, y * lado, lado + 0.5, lado + 0.5),
            pincel,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QrSimuladoPainter oldDelegate) =>
      oldDelegate.semente != semente || oldDelegate.cor != cor;
}

/// Desenha um "código de barras" ilustrativo (não é legível por leitores).
class CodigoBarrasSimuladoPainter extends CustomPainter {
  CodigoBarrasSimuladoPainter(this.semente, {this.cor = AppColors.azulEscuro});

  final String semente;
  final Color cor;

  List<int> _larguras() {
    final larguras = <int>[1, 1, 3, 1]; // início
    for (final unidade in semente.codeUnits) {
      final d = unidade % 10;
      larguras
        ..add(1 + d % 3)
        ..add(1 + (d ~/ 3) % 3)
        ..add(1 + (d + 1) % 2)
        ..add(1 + (d ~/ 2) % 2);
    }
    larguras.addAll([3, 1, 1]); // fim
    return larguras;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final larguras = _larguras();
    final total = larguras.fold<int>(0, (soma, l) => soma + l);
    final unidade = size.width / total;
    final pincel = Paint()..color = cor;

    var x = 0.0;
    for (var i = 0; i < larguras.length; i++) {
      final largura = larguras[i] * unidade;
      if (i.isEven) {
        canvas.drawRect(Rect.fromLTWH(x, 0, largura, size.height), pincel);
      }
      x += largura;
    }
  }

  @override
  bool shouldRepaint(covariant CodigoBarrasSimuladoPainter oldDelegate) =>
      oldDelegate.semente != semente || oldDelegate.cor != cor;
}
