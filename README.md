# Agenda Fácil (TCC) — telas em Flutter

## Funcionalidades
- **Home**: os 3 cards funcionam (Novas consultas → novo agendamento, Meus agendamentos → agenda, Rede de saúde → aba Rede).
- **Novo agendamento** (botão central SUS, card da Home ou "Agendar nesta unidade"): tipo, serviço (dinâmico), unidade, data e horário.
- **Meus agendamentos**: Agenda ativa / Histórico em tempo real; detalhes, reagendar e cancelar.
- **Rede**: 5 UBS com busca por nome/bairro, filtro por tipo de atendimento, detalhes com profissionais e botão de agendar na unidade.
- **Perfil**: Cartão SUS Digital (toque para ampliar com QR Code/código de barras ilustrativos), resumo de saúde (alergias e condições editáveis), dados cadastrais editáveis e preferências (lembretes e tamanho do texto).

## Acesso e persistência
- Login por **CPF ou CNS** + senha; "Criar minha conta" faz o cadastro completo; "Acesso Rápido (Demo Banca)" entra como Jheniffer.
- Conta de demonstração: CPF `123.456.789-09` (ou CNS `700 1234 5678 9010`), senha `agenda123`.
- Sessão, contas, paciente e agendamentos são salvos em JSON com `shared_preferences` (dispositivo/navegador). No primeiro acesso grava os dados de demonstração.
- Senhas guardadas só como hash SHA-256 com sal (proteção básica local; a autenticação real deve ficar no servidor).
- Para zerar os dados no navegador: limpe os dados do site (localhost) nas ferramentas do Chrome.

## Como rodar
```bash
flutter create --project-name agenda_facil .   # só na primeira vez
flutter pub get
flutter run -d chrome
```

## Estrutura
```
lib/
  core/      cores, textos (Poppins), tema, campos de formulário, assets
  models/    Agendamento, Paciente, Unidade, Profissional, TipoAtendimento (todos com toJson/fromJson quando aplicável)
  data/      catalogo.dart (UBS, serviços, horários, orientações) · dados_demo.dart (seed)
             armazenamento.dart (interface Armazenamento + implementação local)
             sessao_repository.dart · paciente_repository.dart · agendamento_repository.dart
  widgets/   componentes reutilizáveis (header, nav, cards, chips, sheets, cartão SUS...)
  screens/   home, rede, perfil, novo agendamento, meus agendamentos, shell
```

## Próximo passo: nuvem
Os repositórios só dependem da interface `Armazenamento` (ler/gravar/remover). Para sincronizar com um banco em nuvem, crie outra implementação (ou um repositório remoto) e troque no `main.dart`; as telas não mudam.

## Observações
- Endereços, telefones, distâncias, profissionais, orientações e dados do paciente são EXEMPLOS fictícios.
- O QR Code e o código de barras do Cartão SUS são ilustrativos (não legíveis por leitores).
- "Lembretes de consulta" guarda a preferência; notificações reais exigem um pacote de notificações.
