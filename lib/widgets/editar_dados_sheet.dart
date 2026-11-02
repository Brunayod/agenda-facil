import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_input.dart';
import '../core/app_text.dart';
import '../data/catalogo.dart';
import '../data/paciente_repository.dart';
import '../models/paciente.dart';
import 'app_snack_bar.dart';
import 'botao_app.dart';
import 'opcao_chip.dart';
import 'tile_unidade.dart';

/// BottomSheet para editar os dados cadastrais do paciente (em memória).
abstract final class EditarDadosSheet {
  static Future<void> mostrar(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _Conteudo(),
    ).then((salvou) {
      if (salvou == true) {
        AppSnackBar.mostrar(messenger, 'Dados atualizados com sucesso.');
      }
    });
  }
}

class _Conteudo extends StatefulWidget {
  const _Conteudo();

  @override
  State<_Conteudo> createState() => _ConteudoState();
}

class _ConteudoState extends State<_Conteudo> {
  static const _tiposSanguineos = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  static final _regexEmail = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _telefone;
  late final TextEditingController _email;
  late final TextEditingController _endereco;
  late String _tipoSanguineo;
  late String _unidadeId;

  @override
  void initState() {
    super.initState();
    final p = PacienteRepository.instance.paciente;
    _telefone = TextEditingController(text: p.telefone);
    _email = TextEditingController(text: p.email);
    _endereco = TextEditingController(
      text: p.endereco == Paciente.enderecoNaoInformado ? '' : p.endereco,
    );
    _tipoSanguineo = p.tipoSanguineo;
    _unidadeId = p.unidadeReferenciaId;
  }

  @override
  void dispose() {
    _telefone.dispose();
    _email.dispose();
    _endereco.dispose();
    super.dispose();
  }

  String? _validarTelefone(String? valor) {
    final digitos = (valor ?? '').replaceAll(RegExp(r'\D'), '');
    if (digitos.length < 10 || digitos.length > 11) {
      return 'Informe o telefone com DDD.';
    }
    return null;
  }

  String? _validarEmail(String? valor) {
    if (!_regexEmail.hasMatch((valor ?? '').trim())) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  String? _validarEndereco(String? valor) {
    if ((valor ?? '').trim().length < 8) return 'Informe o endereço completo.';
    return null;
  }

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final repo = PacienteRepository.instance;
    repo.atualizar(
      repo.paciente.copyWith(
        telefone: _telefone.text.trim(),
        email: _email.text.trim(),
        endereco: _endereco.text.trim(),
        tipoSanguineo: _tipoSanguineo,
        unidadeReferenciaId: _unidadeId,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final teclado = MediaQuery.viewInsetsOf(context).bottom;
    final inferior = MediaQuery.paddingOf(context).bottom;
    final altura = MediaQuery.sizeOf(context).height;

    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: Container(
        constraints: BoxConstraints(maxHeight: (altura - teclado) * 0.94),
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text('Editar dados', style: AppText.listaTitulo),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefone,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        style: AppText.campo,
                        validator: _validarTelefone,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: CampoDecoracao.criar(
                          rotulo: 'Telefone',
                          prefixo: const Icon(
                            Icons.phone_outlined,
                            color: AppColors.azulPrimario,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: AppText.campo,
                        validator: _validarEmail,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: CampoDecoracao.criar(
                          rotulo: 'E-mail',
                          prefixo: const Icon(
                            Icons.mail_outline,
                            color: AppColors.azulPrimario,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _endereco,
                        keyboardType: TextInputType.streetAddress,
                        textInputAction: TextInputAction.done,
                        maxLines: 2,
                        style: AppText.campo,
                        validator: _validarEndereco,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: CampoDecoracao.criar(
                          rotulo: 'Endereço',
                          prefixo: const Icon(
                            Icons.home_outlined,
                            color: AppColors.azulPrimario,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Tipo sanguíneo', style: AppText.formSecao),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final tipo in _tiposSanguineos)
                            OpcaoChip(
                              rotulo: tipo,
                              selecionado: _tipoSanguineo == tipo,
                              onTap: () =>
                                  setState(() => _tipoSanguineo = tipo),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('UBS de referência', style: AppText.formSecao),
                      const SizedBox(height: 10),
                      for (final unidade in Catalogo.unidades)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TileUnidade(
                            unidade: unidade,
                            selecionada: unidade.id == _unidadeId,
                            onTap: () => setState(() => _unidadeId = unidade.id),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                16 + (teclado > 0 ? 0 : inferior),
              ),
              child: BotaoApp(
                rotulo: 'Salvar alterações',
                icone: Icons.check,
                onPressed: _salvar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
