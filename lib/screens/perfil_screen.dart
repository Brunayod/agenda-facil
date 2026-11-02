import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_text.dart';
import '../data/catalogo.dart';
import '../data/paciente_repository.dart';
import '../models/paciente.dart';
import '../widgets/app_header.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/botao_app.dart';
import '../widgets/cartao_sus.dart';
import '../widgets/cartao_sus_sheet.dart';
import '../widgets/chip_editavel.dart';
import '../widgets/dialogo_adicionar_item.dart';
import '../widgets/editar_dados_sheet.dart';
import '../widgets/info_linha.dart';
import '../widgets/opcao_chip.dart';
import '../widgets/secao_card.dart';
import '../widgets/toggle_app.dart';

/// Aba "Perfil": Cartão SUS Digital, resumo de saúde, dados e preferências.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key, required this.onVoltar});

  final VoidCallback onVoltar;

  Future<void> _adicionar(
    BuildContext context, {
    required String titulo,
    required String dica,
    required bool Function(String) salvar,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final texto = await DialogoAdicionarItem.mostrar(
      context,
      titulo: titulo,
      dica: dica,
    );
    if (texto == null) return;

    if (!salvar(texto)) {
      AppSnackBar.mostrar(
        messenger,
        'Esse item já está na lista.',
        icone: Icons.info_outline,
      );
    }
  }

  /// Pede confirmação e encerra a sessão; o app volta sozinho ao login.
  Future<void> _confirmarSaida(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sair da conta?', style: AppText.listaTitulo),
        content: Text(
          'Você precisará entrar novamente com seu CPF ou Cartão SUS. '
          'Seus agendamentos e dados continuam salvos neste aparelho.',
          style: AppText.detalheCorpo,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: AppText.opcao(
                AppColors.textoSecundario,
                peso: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Sair',
              style: AppText.opcao(
                AppColors.canceladoTexto,
                peso: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    await PacienteRepository.instance.sair();
    AppSnackBar.mostrar(messenger, 'Você saiu da conta.', icone: Icons.logout);
  }

  @override
  Widget build(BuildContext context) {
    final repo = PacienteRepository.instance;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final p = repo.paciente;
        final ubs = Catalogo.unidadePorId(p.unidadeReferenciaId);

        return Column(
          children: [
            AppHeader(titulo: 'Meu perfil', onVoltar: onVoltar),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                children: [
                  CartaoSus(
                    paciente: p,
                    onTap: () => CartaoSusSheet.mostrar(context, p),
                  ),
                  const SizedBox(height: 16),
                  SecaoCard(
                    titulo: 'Resumo de saúde',
                    icone: Icons.favorite_border,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipo sanguíneo', style: AppText.formRotulo),
                        const SizedBox(height: 6),
                        _ChipInfo(rotulo: 'Tipo sanguíneo ${p.tipoSanguineo}'),
                        const SizedBox(height: 14),
                        Text('Alergias', style: AppText.formRotulo),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in p.alergias)
                              ChipEditavel(
                                rotulo: item,
                                onRemover: () => repo.removerAlergia(item),
                              ),
                            ChipAdicionar(
                              onTap: () => _adicionar(
                                context,
                                titulo: 'Adicionar alergia',
                                dica: 'Ex.: Dipirona',
                                salvar: repo.adicionarAlergia,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text('Condições', style: AppText.formRotulo),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in p.condicoes)
                              ChipEditavel(
                                rotulo: item,
                                onRemover: () => repo.removerCondicao(item),
                              ),
                            ChipAdicionar(
                              onTap: () => _adicionar(
                                context,
                                titulo: 'Adicionar condição',
                                dica: 'Ex.: Rinite',
                                salvar: repo.adicionarCondicao,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SecaoCard(
                    titulo: 'Dados cadastrais',
                    icone: Icons.badge_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoLinha(
                          icone: Icons.phone_outlined,
                          rotulo: 'Telefone',
                          valor: p.telefone,
                        ),
                        InfoLinha(
                          icone: Icons.mail_outline,
                          rotulo: 'E-mail',
                          valor: p.email,
                        ),
                        InfoLinha(
                          icone: Icons.home_outlined,
                          rotulo: 'Endereço',
                          valor: p.endereco,
                        ),
                        InfoLinha(
                          icone: Icons.local_hospital_outlined,
                          rotulo: 'UBS de referência',
                          valor: ubs.nome,
                        ),
                        BotaoApp(
                          rotulo: 'Editar dados',
                          icone: Icons.edit_outlined,
                          estilo: EstiloBotao.contorno,
                          onPressed: () => EditarDadosSheet.mostrar(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SecaoCard(
                    titulo: 'Preferências e acessibilidade',
                    icone: Icons.tune,
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
                                    'Lembretes de consulta',
                                    style: AppText.detalheValor,
                                  ),
                                  Text(
                                    'Avisar antes das suas consultas e exames',
                                    style: AppText.formAjuda,
                                  ),
                                ],
                              ),
                            ),
                            ToggleApp(
                              valor: p.lembretesAtivos,
                              rotulo: 'Lembretes de consulta',
                              onChanged: repo.definirLembretes,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text('Tamanho do texto', style: AppText.detalheValor),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final tamanho in TamanhoTexto.values)
                              OpcaoChip(
                                rotulo: tamanho.rotulo,
                                selecionado: p.tamanhoTexto == tamanho,
                                onTap: () =>
                                    repo.definirTamanhoTexto(tamanho),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Exemplo: sua consulta está confirmada.',
                          style: AppText.detalheCorpo,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  BotaoApp(
                    rotulo: 'Sair da conta',
                    icone: Icons.logout,
                    estilo: EstiloBotao.perigo,
                    onPressed: () => _confirmarSaida(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Chip fixo (sem remover) para informações como o tipo sanguíneo.
class _ChipInfo extends StatelessWidget {
  const _ChipInfo({required this.rotulo});

  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.azulOnda,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bloodtype_outlined,
            size: 16,
            color: AppColors.azulTexto,
          ),
          const SizedBox(width: 6),
          Text(rotulo, style: AppText.opcao(AppColors.azulTexto)),
        ],
      ),
    );
  }
}
