import '../core/app_assets.dart';
import '../models/agendamento.dart';

/// Ícone (círculo azul claro + desenho) de cada tipo de atendimento.
extension TipoAtendimentoIcone on TipoAtendimento {
  String get icone => switch (this) {
        TipoAtendimento.consulta => AppAssets.icMedico,
        TipoAtendimento.exame => AppAssets.icExame,
        TipoAtendimento.vacinacao => AppAssets.icVacina,
        TipoAtendimento.receita => AppAssets.icReceita,
      };
}
