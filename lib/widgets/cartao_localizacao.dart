import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../data/localizacao_repository.dart';

/// Cartão "Usar minha localização atual (GPS)" com o estado da busca.
///
/// Ao aparecer, tenta obter a posição sozinho (uma vez por abertura do app).
/// O botão pede de novo ou atualiza a posição. Quem exibe listas de UBS deve
/// envolver a lista em um `ListenableBuilder` de [LocalizacaoRepository] para
/// as distâncias e a ordem se atualizarem.
class CartaoLocalizacao extends StatefulWidget {
  const CartaoLocalizacao({super.key});

  @override
  State<CartaoLocalizacao> createState() => _CartaoLocalizacaoState();
}

class _CartaoLocalizacaoState extends State<CartaoLocalizacao> {
  @override
  void initState() {
    super.initState();
    // Depois do primeiro quadro: o repositório avisa os ouvintes ao começar
    // e isso não pode acontecer no meio da construção da tela.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalizacaoRepository.instance.obterAutomaticamente();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = LocalizacaoRepository.instance;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final buscando = repo.buscando;
        final (texto, erro) = _mensagem(repo);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.azulBordaCard, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BotaoGps(
                carregando: buscando,
                onPressed: buscando ? null : repo.obter,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      erro
                          ? Icons.info_outline
                          : (repo.estado == EstadoLocalizacao.ativo
                              ? Icons.check_circle_outline
                              : Icons.location_searching),
                      size: 16,
                      color: erro
                          ? AppColors.canceladoTexto
                          : AppColors.azulPrimario,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        texto,
                        style:
                            erro ? AppText.campoErro : AppText.formAjuda,
                      ),
                    ),
                  ),
                ],
              ),
              if (repo.podeAbrirConfiguracoes)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: repo.abrirConfiguracoes,
                    child: Text(
                      'Abrir configurações',
                      style: AppText.opcao(
                        AppColors.azulPrimario,
                        peso: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Texto de status e se ele é um aviso de erro.
  (String, bool) _mensagem(LocalizacaoRepository repo) {
    return switch (repo.estado) {
      EstadoLocalizacao.inativo => (
          'Permita o acesso à localização para ver as UBS mais próximas '
              'de você.',
          false,
        ),
      EstadoLocalizacao.buscando => ('Obtendo sua localização...', false),
      EstadoLocalizacao.ativo => (
          'Distâncias calculadas a partir da sua posição atual. As unidades '
              'estão ordenadas da mais próxima para a mais distante.',
          false,
        ),
      EstadoLocalizacao.negado => (
          'Permissão de localização negada. Toque no botão para tentar de '
              'novo.',
          true,
        ),
      EstadoLocalizacao.negadoPermanente => (
          kIsWeb
              ? 'A localização está bloqueada neste site. Libere-a no ícone '
                  'de cadeado, ao lado do endereço do navegador, e tente '
                  'de novo.'
              : 'A permissão de localização está bloqueada. Libere-a nas '
                  'configurações do aparelho.',
          true,
        ),
      EstadoLocalizacao.servicoDesligado => (
          'O GPS está desligado. Ative a localização do aparelho e tente '
              'de novo.',
          true,
        ),
      EstadoLocalizacao.erro => (
          repo.temPosicao
              ? 'Não foi possível atualizar agora. Mostrando a última '
                  'posição obtida.'
              : 'Não foi possível obter sua localização agora. Tente de '
                  'novo.',
          true,
        ),
    };
  }
}

class _BotaoGps extends StatelessWidget {
  const _BotaoGps({required this.carregando, required this.onPressed});

  final bool carregando;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: 'Usar minha localização atual (GPS)',
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.azulPrimario, width: 2),
        ),
        child: InkWell(
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (carregando)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.azulPrimario,
                      ),
                    )
                  else
                    const Icon(
                      Icons.my_location,
                      size: 20,
                      color: AppColors.azulPrimario,
                    ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Usar minha localização atual (GPS)',
                      textAlign: TextAlign.center,
                      style: AppText.opcao(
                        AppColors.azulPrimario,
                        peso: FontWeight.w600,
                      ),
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
