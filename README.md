# Agenda Fácil (TCC) — telas em Flutter

## Funcionalidades
- **Home**: os 3 cards funcionam (Novas consultas → novo agendamento, Meus agendamentos → agenda, Rede de saúde → aba Rede).
- **Novo agendamento** (botão central SUS, card da Home ou "Agendar nesta unidade"): tipo, serviço (dinâmico), unidade, data e horário.
- **Meus agendamentos**: Agenda ativa / Histórico em tempo real; detalhes, reagendar e cancelar.
- **Rede**: 5 UBS com busca por nome/bairro, filtro por tipo de atendimento, detalhes com profissionais e botão de agendar na unidade.
- **Login e cadastro**: entrada por CPF ou Cartão SUS + senha (mostrar/ocultar), "Criar minha conta" (nome, CPF, CNS, nascimento, tipo sanguíneo, telefone, e-mail, UBS de referência e senha) e "Acesso Rápido (Demo Banca)", que entra como Jheniffer Almeida Santos. Conta de demonstração: CPF `123.456.789-09`, senha `demo123`.
- **Perfil**: Cartão SUS Digital (toque para ampliar com QR Code/código de barras ilustrativos), resumo de saúde (alergias e condições editáveis), dados cadastrais editáveis e preferências (lembretes e tamanho do texto); botão **Sair da conta** (com confirmação) no final da página.

## Como rodar
```bash
flutter create --project-name agenda_facil .   # só na primeira vez
flutter pub get
flutter run -d chrome
```

## Estrutura
```
lib/
  core/      cores, textos (Poppins), tema, campos de formulário, máscaras e validadores, assets
  models/    Agendamento, Paciente, Unidade, Profissional, TipoAtendimento (todos com toJson/fromJson quando aplicável)
  data/      catalogo.dart (UBS, serviços, horários, orientações)
             agendamento_repository.dart e paciente_repository.dart (estado reativo + persistência local, sessão e contas)
  widgets/   componentes reutilizáveis (header, nav, cards, chips, sheets, cartão SUS...)
  screens/   home, rede, perfil, novo agendamento, meus agendamentos, shell
```

## Persistência (`shared_preferences`)
Tudo é salvo automaticamente no aparelho (no navegador, `localStorage`):
- `af.contas` — contas cadastradas (`Paciente.toJson()` + senha com hash e salt). Alterações de dados, alergias, condições e preferências de acessibilidade são gravadas aqui.
- `af.sessao` — CPF do paciente logado; ao reabrir o app a sessão é restaurada.
- `af.agendamentos.<cpf>` — agendamentos de cada paciente (criados, remarcados e cancelados) via `Agendamento.toJson()/fromJson()`.
- `af.sequencia` — contador dos protocolos.

Na primeira abertura a conta demo (Jheniffer) é criada com os agendamentos de demonstração. Novas contas começam sem agendamentos. Ao reabrir, agendamentos "Confirmado" cuja data já passou viram "Realizado".
Para zerar os dados no Chrome: DevTools → Application → Local Storage → Clear.

> O hash de senha é didático (protótipo sem servidor). Em produção use uma API (ex.: login gov.br) com bcrypt/argon2.

## Observações
- Endereços, telefones, distâncias, profissionais, orientações e dados do paciente são EXEMPLOS fictícios.
- O QR Code e o código de barras do Cartão SUS são ilustrativos (não legíveis por leitores).
- "Lembretes de consulta" guarda a preferência; notificações reais exigem um pacote de notificações.
