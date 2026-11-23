-- =====================================================================
-- AGENDA FÁCIL - Banco de dados (Supabase / PostgreSQL)
-- Todos os dados de pacientes são informados pelo próprio usuário.
-- Nada vem do SUS. Profissionais e consultas são fictícios.
--
-- COMO USAR: Supabase > SQL Editor > New query > cole tudo > Run.
-- Antes: Authentication > Providers > Email > desligue "Confirm email".
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1. CATÁLOGO (dados públicos de leitura: UBS, serviços, horários)
-- ---------------------------------------------------------------------

-- Unidade = UBS. O id é o mesmo texto usado no app ('vila-mariana' etc.).
create table public.unidades (
  id                     text primary key,
  nome                   text not null,
  bairro                 text not null,
  endereco               text not null,
  horario_funcionamento  text not null,          -- ex.: 'Seg a Sex • 07h às 19h'
  telefone               text not null,
  distancia_km           numeric(4,1),           -- valor SIMULADO (sem geolocalização)
  criado_em              timestamptz not null default now()
);

-- Quais tipos de atendimento cada UBS oferece (Unidade.servicos no app).
create table public.unidade_tipos (
  unidade_id  text not null references public.unidades(id) on delete cascade,
  tipo        text not null check (tipo in ('consulta','exame','vacinacao','receita')),
  primary key (unidade_id, tipo)
);

-- Profissional (ou equipe) de uma UBS. Todos fictícios.
create table public.profissionais (
  id            bigint generated always as identity primary key,
  unidade_id    text not null references public.unidades(id) on delete cascade,
  nome          text not null,
  especialidade text not null,                   -- ex.: 'Clínica Médica', 'Vacinação'
  equipe        boolean not null default false,  -- true para 'Equipe de enfermagem' etc.
  ficticio      boolean not null default true,
  unique (id, unidade_id)
);
create index on public.profissionais (unidade_id, especialidade);

-- Serviços: especialidade, exame, vacina ou tipo de receita.
create table public.servicos (
  id            bigint generated always as identity primary key,
  tipo          text not null check (tipo in ('consulta','exame','vacinacao','receita')),
  nome          text not null,
  especialidade text not null,                   -- especialidade do profissional que atende
  orientacoes   text[] not null default '{}',    -- orientações de preparo
  unique (tipo, nome),
  unique (id, tipo)
);

-- Horários oferecidos na tela de novo agendamento (Catalogo.horarios).
create table public.horarios_padrao (
  hora time primary key
);


-- ---------------------------------------------------------------------
-- 2. PACIENTE (1 linha por usuário do Supabase Auth)
-- A senha NÃO fica aqui: o Supabase Auth guarda o hash (bcrypt).
-- Isso substitui o model Credencial (SHA-256) do app.
-- ---------------------------------------------------------------------

create table public.pacientes (
  id                    uuid primary key references auth.users(id) on delete cascade,
  nome                  text not null,
  cpf                   text not null unique check (cpf ~ '^[0-9]{11}$'),
  cns                   text not null unique check (cns ~ '^[0-9]{15}$'),
  data_nascimento       date not null,
  tipo_sanguineo        text check (tipo_sanguineo in ('A+','A-','B+','B-','AB+','AB-','O+','O-')),
  telefone              text not null,
  email                 text not null,
  endereco              text not null,
  unidade_referencia_id text not null references public.unidades(id),
  alergias              text[] not null default '{}',
  condicoes             text[] not null default '{}',
  -- preferências
  lembretes_ativos      boolean not null default true,
  tamanho_texto         text not null default 'normal'
                        check (tamanho_texto in ('normal','grande','muitoGrande')),
  criado_em             timestamptz not null default now(),
  atualizado_em         timestamptz not null default now()
);


-- ---------------------------------------------------------------------
-- 3. AGENDAMENTOS
-- ---------------------------------------------------------------------

create sequence public.agendamento_protocolo_seq start 1001;

create table public.agendamentos (
  id              uuid primary key default gen_random_uuid(),
  protocolo       text not null unique,          -- 'AF-2026-001001' (gerado por trigger)
  paciente_id     uuid not null references public.pacientes(id) on delete cascade,
  tipo            text not null,
  servico_id      bigint not null,
  unidade_id      text not null,
  profissional_id bigint not null,
  data_hora       timestamptz not null,
  status          text not null default 'confirmado'
                  check (status in ('confirmado','realizado','naoCompareceu','cancelado')),
  criado_em       timestamptz not null default now(),
  atualizado_em   timestamptz not null default now(),
  -- integridade: a UBS precisa oferecer o tipo, o serviço precisa ser do tipo
  -- e o profissional precisa trabalhar na UBS escolhida
  foreign key (unidade_id, tipo)         references public.unidade_tipos (unidade_id, tipo),
  foreign key (servico_id, tipo)         references public.servicos (id, tipo),
  foreign key (profissional_id, unidade_id) references public.profissionais (id, unidade_id)
);
create index on public.agendamentos (paciente_id, status, data_hora);

-- Regra do app: o paciente não pode ter 2 agendamentos ativos no mesmo horário.
create unique index agendamento_paciente_horario_unico
  on public.agendamentos (paciente_id, data_hora)
  where status = 'confirmado';

-- Registro de remarcações e cancelamentos.
create table public.agendamento_historico (
  id               bigint generated always as identity primary key,
  agendamento_id   uuid not null references public.agendamentos(id) on delete cascade,
  paciente_id      uuid not null references public.pacientes(id) on delete cascade,
  data_hora_antes  timestamptz,
  data_hora_depois timestamptz,
  status_antes     text,
  status_depois    text,
  alterado_em      timestamptz not null default now()
);
create index on public.agendamento_historico (agendamento_id);


-- ---------------------------------------------------------------------
-- 4. FUNÇÕES E TRIGGERS
-- ---------------------------------------------------------------------

create function public.set_atualizado_em() returns trigger
language plpgsql as $$
begin
  new.atualizado_em := now();
  return new;
end $$;

create trigger pacientes_atualizado before update on public.pacientes
  for each row execute function public.set_atualizado_em();
create trigger agendamentos_atualizado before update on public.agendamentos
  for each row execute function public.set_atualizado_em();

-- Gera o protocolo: AF-<ano>-<sequência com 6 dígitos>.
create function public.gerar_protocolo() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.protocolo is null or new.protocolo = '' then
    new.protocolo := 'AF-'
      || to_char(now() at time zone 'America/Sao_Paulo', 'YYYY')
      || '-' || lpad(nextval('public.agendamento_protocolo_seq')::text, 6, '0');
  end if;
  return new;
end $$;

create trigger agendamentos_protocolo before insert on public.agendamentos
  for each row execute function public.gerar_protocolo();

-- Regras para o usuário final (auth.uid() não nulo). O SQL Editor e a
-- service_role (equipe) não sofrem estas restrições.
create function public.validar_agendamento() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_local timestamp;
begin
  if auth.uid() is null then
    return new;
  end if;

  if tg_op = 'UPDATE' then
    if old.status <> 'confirmado' then
      raise exception 'Só é possível alterar agendamentos confirmados.';
    end if;
    if new.status not in ('confirmado','cancelado') then
      raise exception 'Status inválido para esta operação.';
    end if;
  end if;

  -- Valida data/hora em novo agendamento e em reagendamento.
  if tg_op = 'INSERT' or new.data_hora is distinct from old.data_hora then
    v_local := new.data_hora at time zone 'America/Sao_Paulo';
    if new.data_hora <= now() then
      raise exception 'O horário precisa ser no futuro.';
    end if;
    if extract(isodow from v_local) in (6, 7) then
      raise exception 'Agendamentos só em dias úteis.';
    end if;
    if not exists (select 1 from public.horarios_padrao h where h.hora = v_local::time) then
      raise exception 'Horário indisponível.';
    end if;
  end if;
  return new;
end $$;

create trigger agendamentos_validar before insert or update on public.agendamentos
  for each row execute function public.validar_agendamento();

-- Grava o histórico quando muda o horário ou o status.
create function public.registrar_historico() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.data_hora is distinct from old.data_hora or new.status is distinct from old.status then
    insert into public.agendamento_historico
      (agendamento_id, paciente_id, data_hora_antes, data_hora_depois, status_antes, status_depois)
    values
      (new.id, new.paciente_id, old.data_hora, new.data_hora, old.status, new.status);
  end if;
  return new;
end $$;

create trigger agendamentos_historico after update on public.agendamentos
  for each row execute function public.registrar_historico();

-- Cria o paciente automaticamente no cadastro. O app envia os dados em
-- signUp(... data: {...}). Se algo falhar (ex.: CNS repetido), o cadastro
-- inteiro é desfeito, sem deixar usuário órfão.
create function public.criar_paciente_no_cadastro() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  m jsonb := new.raw_user_meta_data;
begin
  if m ? 'cpf' then
    insert into public.pacientes
      (id, nome, cpf, cns, data_nascimento, tipo_sanguineo, telefone, email,
       endereco, unidade_referencia_id, alergias, condicoes)
    values
      (new.id, m->>'nome', m->>'cpf', m->>'cns', (m->>'data_nascimento')::date,
       nullif(m->>'tipo_sanguineo', ''), m->>'telefone', coalesce(m->>'email', new.email),
       m->>'endereco', m->>'unidade_referencia_id',
       coalesce(array(select jsonb_array_elements_text(m->'alergias')), '{}'),
       coalesce(array(select jsonb_array_elements_text(m->'condicoes')), '{}'));
  end if;
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.criar_paciente_no_cadastro();

-- Login por CPF ou CNS: devolve o e-mail da conta para o app chamar
-- signInWithPassword(email, senha).
create function public.email_de_login(p_identificador text) returns text
language sql stable security definer set search_path = '' as $$
  select u.email::text
  from public.pacientes p
  join auth.users u on u.id = p.id
  where p.cpf = regexp_replace(p_identificador, '\D', '', 'g')
     or p.cns = regexp_replace(p_identificador, '\D', '', 'g')
  limit 1
$$;

-- Profissional que atende um serviço em uma UBS (primeiro da especialidade).
create function public.profissional_para(p_unidade text, p_servico bigint) returns bigint
language sql stable set search_path = '' as $$
  select p.id
  from public.profissionais p
  join public.servicos s on s.especialidade = p.especialidade
  where p.unidade_id = p_unidade and s.id = p_servico
  order by p.id
  limit 1
$$;

-- Exclusão da própria conta (direito de exclusão da LGPD). O cascade apaga
-- paciente, agendamentos e histórico.
create function public.excluir_minha_conta() returns void
language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then
    raise exception 'Não autenticado.';
  end if;
  delete from auth.users where id = auth.uid();
end $$;


-- ---------------------------------------------------------------------
-- 5. SEGURANÇA (RLS + permissões mínimas)
-- ---------------------------------------------------------------------

alter table public.unidades              enable row level security;
alter table public.unidade_tipos         enable row level security;
alter table public.profissionais         enable row level security;
alter table public.servicos              enable row level security;
alter table public.horarios_padrao       enable row level security;
alter table public.pacientes             enable row level security;
alter table public.agendamentos          enable row level security;
alter table public.agendamento_historico enable row level security;

-- Catálogo: qualquer um lê (a tela de cadastro lista as UBS antes do login).
create policy catalogo_leitura on public.unidades        for select to anon, authenticated using (true);
create policy catalogo_leitura on public.unidade_tipos   for select to anon, authenticated using (true);
create policy catalogo_leitura on public.profissionais   for select to anon, authenticated using (true);
create policy catalogo_leitura on public.servicos        for select to anon, authenticated using (true);
create policy catalogo_leitura on public.horarios_padrao for select to anon, authenticated using (true);

-- Paciente: cada um lê e edita somente os próprios dados.
create policy paciente_le_proprio on public.pacientes
  for select to authenticated using (id = (select auth.uid()));
create policy paciente_edita_proprio on public.pacientes
  for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- Agendamentos: somente os próprios.
create policy agendamento_le_proprio on public.agendamentos
  for select to authenticated using (paciente_id = (select auth.uid()));
create policy agendamento_cria_proprio on public.agendamentos
  for insert to authenticated with check (paciente_id = (select auth.uid()));
create policy agendamento_altera_proprio on public.agendamentos
  for update to authenticated
  using (paciente_id = (select auth.uid()))
  with check (paciente_id = (select auth.uid()));

create policy historico_le_proprio on public.agendamento_historico
  for select to authenticated using (paciente_id = (select auth.uid()));

-- Permissões por coluna: o app só pode mexer no que precisa.
revoke all on all tables    in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke all on all functions in schema public from public, anon, authenticated;

grant usage on schema public to anon, authenticated;

grant select on public.unidades, public.unidade_tipos, public.profissionais,
                public.servicos, public.horarios_padrao to anon, authenticated;

grant select on public.pacientes to authenticated;
grant update (nome, tipo_sanguineo, telefone, email, endereco, unidade_referencia_id,
              alergias, condicoes, lembretes_ativos, tamanho_texto)
  on public.pacientes to authenticated;                 -- cpf, cns e nascimento são imutáveis

grant select on public.agendamentos to authenticated;
grant insert (paciente_id, tipo, servico_id, unidade_id, profissional_id, data_hora)
  on public.agendamentos to authenticated;
grant update (data_hora, status) on public.agendamentos to authenticated;

grant select on public.agendamento_historico to authenticated;

grant execute on function public.email_de_login(text)             to anon, authenticated;
grant execute on function public.profissional_para(text, bigint)  to authenticated;
grant execute on function public.excluir_minha_conta()            to authenticated;


-- ---------------------------------------------------------------------
-- 6. DADOS INICIAIS (cópia do catalogo.dart)
-- ATENÇÃO: endereços e telefones das UBS são os de EXEMPLO do app.
-- Substitua pelos dados reais de cada UBS antes da apresentação.
-- ---------------------------------------------------------------------

insert into public.unidades (id, nome, bairro, endereco, horario_funcionamento, telefone, distancia_km) values
  ('vila-mariana','UBS Vila Mariana','Vila Mariana','Rua Domingos de Morais, 1200 - Vila Mariana, São Paulo - SP','Seg a Sex • 07h às 19h','(11) 5555-0101',1.2),
  ('santa-cecilia','UBS Santa Cecília','Santa Cecília','Rua Vitorino Carmilo, 400 - Santa Cecília, São Paulo - SP','Seg a Sex • 07h às 18h','(11) 5555-0102',2.8),
  ('republica','UBS República','República','Praça da República, 150 - República, São Paulo - SP','Seg a Sex • 08h às 17h','(11) 5555-0103',3.4),
  ('bom-retiro','UBS Bom Retiro','Bom Retiro','Rua Prates, 600 - Bom Retiro, São Paulo - SP','Seg a Sex • 07h às 19h','(11) 5555-0104',4.1),
  ('pinheiros','UBS Pinheiros','Pinheiros','Rua Teodoro Sampaio, 1100 - Pinheiros, São Paulo - SP','Seg a Sáb • 07h às 13h','(11) 5555-0105',5.6);

insert into public.unidade_tipos (unidade_id, tipo) values
  ('vila-mariana','consulta'),('vila-mariana','exame'),('vila-mariana','vacinacao'),('vila-mariana','receita'),
  ('santa-cecilia','consulta'),('santa-cecilia','exame'),('santa-cecilia','vacinacao'),
  ('republica','consulta'),('republica','vacinacao'),('republica','receita'),
  ('bom-retiro','consulta'),('bom-retiro','exame'),('bom-retiro','vacinacao'),('bom-retiro','receita'),
  ('pinheiros','consulta'),('pinheiros','exame'),('pinheiros','vacinacao'),('pinheiros','receita');

insert into public.profissionais (unidade_id, nome, especialidade, equipe) values
  ('vila-mariana','Dra. Helena Martins','Clínica Médica',false),
  ('vila-mariana','Dr. Rafael Souza','Pediatria',false),
  ('vila-mariana','Dra. Camila Duarte','Ginecologia',false),
  ('vila-mariana','Dr. Lucas Ferreira','Odontologia',false),
  ('vila-mariana','Equipe de enfermagem','Vacinação',true),
  ('vila-mariana','Equipe do laboratório','Exames laboratoriais',true),

  ('santa-cecilia','Dr. André Lima','Clínica Médica',false),
  ('santa-cecilia','Dra. Patrícia Gomes','Pediatria',false),
  ('santa-cecilia','Equipe de enfermagem','Vacinação',true),
  ('santa-cecilia','Equipe do laboratório','Exames laboratoriais',true),

  ('republica','Dra. Marina Costa','Clínica Médica',false),
  ('republica','Dra. Beatriz Nogueira','Saúde mental',false),
  ('republica','Dr. Tiago Ramos','Odontologia',false),
  ('republica','Equipe de enfermagem','Vacinação',true),

  ('bom-retiro','Dr. Eduardo Prado','Clínica Médica',false),
  ('bom-retiro','Dra. Sofia Almeida','Ginecologia',false),
  ('bom-retiro','Dr. Bruno Carvalho','Pediatria',false),
  ('bom-retiro','Equipe de enfermagem','Vacinação',true),
  ('bom-retiro','Equipe do laboratório','Exames laboratoriais',true),

  ('pinheiros','Dra. Luiza Fernandes','Clínica Médica',false),
  ('pinheiros','Dra. Renata Moraes','Ginecologia',false),
  ('pinheiros','Dr. Felipe Azevedo','Odontologia',false),
  ('pinheiros','Dr. Gustavo Pires','Saúde mental',false),
  ('pinheiros','Equipe de enfermagem','Vacinação',true),
  ('pinheiros','Equipe do laboratório','Exames laboratoriais',true);

insert into public.servicos (tipo, nome, especialidade, orientacoes) values
  ('consulta','Clínica Médica','Clínica Médica',
    array['Levar documento com foto e carteirinha do SUS','Chegar com 15 minutos de antecedência','Levar exames e receitas anteriores, se houver']),
  ('consulta','Pediatria','Pediatria',
    array['Levar documento com foto e carteirinha do SUS','Chegar com 15 minutos de antecedência','Levar exames e receitas anteriores, se houver']),
  ('consulta','Ginecologia','Ginecologia',
    array['Levar documento com foto e carteirinha do SUS','Chegar com 15 minutos de antecedência','Levar exames e receitas anteriores, se houver']),
  ('consulta','Odontologia','Odontologia',
    array['Levar documento com foto e carteirinha do SUS','Chegar com 15 minutos de antecedência','Levar exames e receitas anteriores, se houver','Escovar os dentes antes da consulta']),

  ('exame','Hemograma completo','Exames laboratoriais',
    array['Levar documento com foto e carteirinha do SUS','Chegar com 15 minutos de antecedência','Jejum de 8 horas (pode beber apenas água)']),
  ('exame','Glicemia em jejum','Exames laboratoriais',
    array['Levar documento com foto e carteirinha do SUS','Chegar com 15 minutos de antecedência','Jejum de 8 horas (pode beber apenas água)']),
  ('exame','Perfil lipídico','Exames laboratoriais',
    array['Levar documento com foto e carteirinha do SUS','Chegar com 15 minutos de antecedência','Jejum de 8 horas (pode beber apenas água)']),
  ('exame','Exame de urina','Exames laboratoriais',
    array['Levar documento com foto e carteirinha do SUS','Chegar com 15 minutos de antecedência','Coletar a primeira urina da manhã em frasco apropriado']),

  ('vacinacao','Vacina da gripe','Vacinação',
    array['Levar documento com foto e carteirinha do SUS','Levar a caderneta de vacinação','Avisar a equipe se estiver com febre ou sintomas de gripe']),
  ('vacinacao','Covid-19','Vacinação',
    array['Levar documento com foto e carteirinha do SUS','Levar a caderneta de vacinação','Avisar a equipe se estiver com febre ou sintomas de gripe']),
  ('vacinacao','Hepatite B','Vacinação',
    array['Levar documento com foto e carteirinha do SUS','Levar a caderneta de vacinação','Avisar a equipe se estiver com febre ou sintomas de gripe']),
  ('vacinacao','Tétano (dT)','Vacinação',
    array['Levar documento com foto e carteirinha do SUS','Levar a caderneta de vacinação','Avisar a equipe se estiver com febre ou sintomas de gripe']),

  ('receita','Clínica Médica','Clínica Médica',
    array['Levar documento com foto e carteirinha do SUS','Levar a receita anterior ou as caixas dos medicamentos','Informar mudanças de dose ou efeitos colaterais']),
  ('receita','Hipertensão e diabetes','Clínica Médica',
    array['Levar documento com foto e carteirinha do SUS','Levar a receita anterior ou as caixas dos medicamentos','Informar mudanças de dose ou efeitos colaterais']),
  ('receita','Saúde mental','Saúde mental',
    array['Levar documento com foto e carteirinha do SUS','Levar a receita anterior ou as caixas dos medicamentos','Informar mudanças de dose ou efeitos colaterais']);

insert into public.horarios_padrao (hora) values
  ('08:00'),('09:30'),('11:00'),('14:00'),('15:30');


-- ---------------------------------------------------------------------
-- 7. CONTA DE DEMONSTRAÇÃO ("Acesso Rápido")
-- 1) Authentication > Users > Add user: e-mail jheniffer.santos@email.com,
--    senha agenda123, marque "Auto Confirm User". Copie o UUID criado.
-- 2) No SQL Editor rode:  select public.seed_demo('COLE-O-UUID-AQUI');
-- (função restrita: o app não consegue chamá-la)
-- ---------------------------------------------------------------------

create function public.dia_util(p_dias int, p_hora time) returns timestamptz
language plpgsql stable set search_path = '' as $$
declare
  d date := (now() at time zone 'America/Sao_Paulo')::date + p_dias;
begin
  while extract(isodow from d) in (6, 7) loop
    d := d + 1;
  end loop;
  return (d + p_hora) at time zone 'America/Sao_Paulo';
end $$;

create function public.seed_demo(p_user uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  v_unidade text := 'vila-mariana';
begin
  insert into public.pacientes
    (id, nome, cpf, cns, data_nascimento, tipo_sanguineo, telefone, email,
     endereco, unidade_referencia_id, alergias, condicoes)
  values
    (p_user, 'Jheniffer Almeida Santos', '12345678909', '700123456789010', '1998-05-14', 'O+',
     '(11) 98765-4321', 'jheniffer.santos@email.com',
     'Rua das Flores, 120 - Vila Mariana, São Paulo - SP', v_unidade,
     array['Dipirona'], array['Rinite'])
  on conflict (id) do nothing;

  if exists (select 1 from public.agendamentos where paciente_id = p_user) then
    return;
  end if;

  insert into public.agendamentos
    (paciente_id, tipo, servico_id, unidade_id, profissional_id, data_hora, status)
  select p_user, s.tipo, s.id, v_unidade,
         public.profissional_para(v_unidade, s.id),
         public.dia_util(x.dias, x.hora), x.status
  from (values
    ('consulta',  'Clínica Médica',    3, time '09:30', 'confirmado'),
    ('vacinacao', 'Vacina da gripe',   7, time '11:00', 'confirmado'),
    ('exame',     'Hemograma completo',12, time '08:00', 'confirmado'),
    ('consulta',  'Clínica Médica',  -14, time '11:00', 'realizado'),
    ('vacinacao', 'Vacina da gripe', -40, time '15:30', 'realizado'),
    ('exame',     'Glicemia em jejum',-22, time '08:00', 'naoCompareceu')
  ) as x(tipo, nome, dias, hora, status)
  join public.servicos s on s.tipo = x.tipo and s.nome = x.nome;
end $$;

revoke all on function public.seed_demo(uuid) from public, anon, authenticated;
revoke all on function public.dia_util(int, time) from public, anon, authenticated;
