import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../models/unidade.dart';

/// Situação da busca pela localização do usuário.
enum EstadoLocalizacao {
  /// Ainda não tentou.
  inativo,
  buscando,

  /// Posição obtida.
  ativo,

  /// O usuário negou a permissão (dá para pedir de novo).
  negado,

  /// Permissão bloqueada: só o usuário libera nas configurações.
  negadoPermanente,

  /// GPS/serviço de localização desligado no aparelho.
  servicoDesligado,

  /// Timeout ou outra falha.
  erro,
}

/// Repositório (singleton) da posição atual do usuário.
///
/// Usa o pacote `geolocator`, que funciona no Android, iOS e no navegador
/// (API de geolocalização do browser; exige `https` ou `localhost`).
/// É um [ChangeNotifier]: telas com `ListenableBuilder` recalculam as
/// distâncias e a ordem das UBS quando a posição chega.
class LocalizacaoRepository extends ChangeNotifier {
  LocalizacaoRepository._();

  static final LocalizacaoRepository instance = LocalizacaoRepository._();

  EstadoLocalizacao _estado = EstadoLocalizacao.inativo;
  double? _latitude;
  double? _longitude;
  bool _tentouAutomatico = false;

  EstadoLocalizacao get estado => _estado;

  bool get buscando => _estado == EstadoLocalizacao.buscando;

  /// `true` se já existe uma posição (mesmo que uma atualização tenha falhado).
  bool get temPosicao => _latitude != null && _longitude != null;

  /// Só no celular dá para abrir as configurações do sistema.
  bool get podeAbrirConfiguracoes =>
      !kIsWeb &&
      (_estado == EstadoLocalizacao.negadoPermanente ||
          _estado == EstadoLocalizacao.servicoDesligado);

  /// Tenta obter a posição uma única vez por abertura do app (usado ao abrir
  /// as telas com lista de UBS). Depois disso, só pelo botão.
  Future<void> obterAutomaticamente() async {
    if (_tentouAutomatico || temPosicao) return;
    _tentouAutomatico = true;
    await obter();
  }

  /// Pede permissão (se preciso) e lê a posição atual.
  Future<void> obter() async {
    if (buscando) return;
    _definir(EstadoLocalizacao.buscando);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _definir(EstadoLocalizacao.servicoDesligado);
        return;
      }

      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }
      if (permissao == LocationPermission.deniedForever) {
        _definir(EstadoLocalizacao.negadoPermanente);
        return;
      }
      if (permissao == LocationPermission.denied) {
        _definir(EstadoLocalizacao.negado);
        return;
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      _latitude = posicao.latitude;
      _longitude = posicao.longitude;
      debugPrint(
        'LocalizacaoRepository: posição obtida '
        '(${posicao.latitude}, ${posicao.longitude}, '
        'precisão ${posicao.accuracy.toStringAsFixed(0)} m)',
      );
      _definir(EstadoLocalizacao.ativo);
    } on TimeoutException {
      debugPrint('LocalizacaoRepository: tempo esgotado ao obter a posição.');
      _definir(EstadoLocalizacao.erro);
    } catch (erro) {
      debugPrint('LocalizacaoRepository: falha ao obter a posição ($erro)');
      _definir(EstadoLocalizacao.erro);
    }
  }

  /// Abre as configurações do sistema (só celular) para liberar a permissão
  /// ou ligar o GPS.
  Future<void> abrirConfiguracoes() async {
    if (!podeAbrirConfiguracoes) return;
    if (_estado == EstadoLocalizacao.servicoDesligado) {
      await Geolocator.openLocationSettings();
    } else {
      await Geolocator.openAppSettings();
    }
  }

  /// Distância real, em km, da posição atual até [unidade] (fórmula de
  /// Haversine). `null` se não há posição ou a UBS não tem coordenadas.
  double? distanciaAte(Unidade unidade) {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null || !unidade.temCoordenadas) return null;
    return calcularKm(lat, lng, unidade.latitude, unidade.longitude);
  }

  /// Distância entre dois pontos da Terra (Haversine), em quilômetros.
  static double calcularKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const raioTerraKm = 6371.0088;
    final dLat = _radianos(lat2 - lat1);
    final dLng = _radianos(lng2 - lng1);
    final senLat = math.sin(dLat / 2);
    final senLng = math.sin(dLng / 2);
    final a = senLat * senLat +
        math.cos(_radianos(lat1)) *
            math.cos(_radianos(lat2)) *
            senLng *
            senLng;
    return 2 * raioTerraKm * math.asin(math.min(1.0, math.sqrt(a)));
  }

  static double _radianos(double graus) => graus * math.pi / 180;

  void _definir(EstadoLocalizacao novo) {
    _estado = novo;
    notifyListeners();
  }
}
