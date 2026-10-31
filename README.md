# Agenda Fácil (TCC) — telas em Flutter

Telas implementadas a partir do protótipo do Figma:

1. **Home** — "Minha saúde" (Novas consultas, Meus agendamentos, Rede de saúde)
2. **Meus agendamentos › Agenda ativa**
3. **Meus agendamentos › Histórico**

Rede e Perfil ainda não existem no protótipo e têm uma tela provisória ("Em construção").

## Como rodar

Este pacote tem só o código do app (`lib/`, `assets/`, `pubspec.yaml`). Gere as pastas de plataforma (android/ios/web) e rode:

```bash
cd agenda_facil
flutter create --project-name agenda_facil .
flutter pub get
flutter run
```

## Estrutura

```
lib/
  main.dart
  core/       cores, textos (Poppins), tema e caminhos dos assets
  models/     Agendamento, TipoAgendamento, StatusAgendamento
  data/       dados de exemplo (trocar por API depois)
  widgets/    header, barra inferior, cards, chips, abas, fundo
  screens/    home, meus agendamentos, em construção, shell de navegação
assets/svg/   ícones e fundos exportados do Figma
```

## Observações

- Fonte **Poppins** via pacote `google_fonts` (baixa na primeira execução). Para funcionar offline, baixe os .ttf, coloque em `assets/fonts/` e declare no `pubspec.yaml`.
- Os SVGs foram extraídos dos exports do Figma (ícones, logo SUS, fundo). Textos do Figma saem como curvas no SVG, então foram refeitos como `Text`.
- O botão central do SUS leva à Home (ajuste em `app_shell.dart` se for outra ação).
- "Novas consultas" e o toque nos cards de agendamento mostram uma mensagem "em breve" até existirem essas telas.
