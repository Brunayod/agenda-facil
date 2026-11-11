# Agenda Fácil (TCC) — Flutter + Supabase

App de agendamento de consultas, exames e vacinas das UBS (SUS).
Todos os dados de pacientes são informados pelo usuário; profissionais, telefones e endereços de exemplo são fictícios.

## Como rodar
```bash
flutter create --project-name agenda_facil .   # só na primeira vez (gera android/, ios/, web/)
flutter pub get
flutter run -d chrome
```
Para outro projeto Supabase: `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

## Banco de dados (Supabase)
1. Supabase → Authentication → Providers → Email → desligue **Confirm email**.
2. Supabase → SQL Editor → cole e rode **`supabase_setup.sql`** (pode rodar de novo a qualquer momento: não apaga dados).
3. Conta de demonstração ("Acesso Rápido"): siga a seção 7 do SQL.
4. Feche e reabra o app (o catálogo de UBS é lido ao iniciar).

Fluxos que gravam no Supabase: cadastro (Auth + trigger → `pacientes`), edição de perfil/alergias/condições/preferências (`update pacientes`), criar/remarcar/cancelar agendamento (`insert/update agendamentos`).
Erros do Supabase aparecem completos no console (`debugPrint`: código, detalhes e dica de correção, ex.: RLS ou coluna faltando).
Sem internet, o app mostra a última cópia salva no aparelho (`shared_preferences`, somente leitura); alterações exigem conexão.

## Geolocalização (GPS)
- Pacote `geolocator` (web + Android + iOS). A aba **Rede** e a etapa **Unidade** do novo agendamento têm o botão "Usar minha localização atual (GPS)" e tentam obter a posição ao abrir.
- A distância é calculada pela fórmula de Haversine até as coordenadas de cada UBS (`latitude`/`longitude` em `unidades`), exibida no selo (ex.: `0,8 km`), e a lista é ordenada da mais próxima para a mais distante.
- **Web:** precisa de `localhost` ou `https`. O navegador pede permissão.
- **Android** — `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`:
  ```xml
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
  ```
- **iOS** — `ios/Runner/Info.plist`:
  ```xml
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Usamos sua localização para mostrar as UBS mais próximas.</string>
  ```

## Estrutura
```
lib/
  core/      cores, textos (Poppins), tema, campos, máscaras e validadores
  models/    Agendamento, Paciente, Unidade (com lat/lng), Profissional, TipoAtendimento
  data/      catalogo (UBS/serviços do Supabase + fallback), repositórios (sessão, paciente,
             agendamento, localizacao), cache_local, erros, supabase_config
  widgets/   componentes reutilizáveis (inclui cartao_localizacao)
  screens/   login, cadastro, home, rede, perfil, novo agendamento, meus agendamentos, shell
supabase_setup.sql   estrutura, RLS, UBS de Cotia e coordenadas (idempotente)
```

## Observações
- Coordenadas de Cotia (Mirizola, Atalaia, Portão) e o endereço da UBS Mirizola foram informados pela equipe; as coordenadas da capital são aproximadas (centro do bairro).
- O QR Code e o código de barras do Cartão SUS são ilustrativos.
- "Lembretes de consulta" guarda a preferência; notificações reais exigem um pacote de notificações.
