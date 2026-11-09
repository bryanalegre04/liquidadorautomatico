-- =====================================================================
--  LIQUIDACIÓN DE INVENTARIO — tablas para Supabase
--  Pega todo esto en Supabase → SQL Editor → New query → Run
-- =====================================================================

-- 1) Liquidaciones (una fila por PDF importado; "datos" guarda todo el detalle)
create table if not exists public.liquidaciones (
  id            text primary key,
  periodo       text not null,              -- 'YYYY-MM'
  conductor     text,
  num_viaje     text,
  placa         text,
  fecha_entrega text,
  datos         jsonb not null,
  subido_por    text,
  updated_at    timestamptz not null default now()
);
create index if not exists liquidaciones_periodo_idx on public.liquidaciones (periodo);

-- 1b) Control diario de anomalías (una fila por viaje; "datos" guarda todo el registro)
create table if not exists public.liquidaciones_control (
  id         text primary key,
  periodo    text not null,              -- 'YYYY-MM'
  fecha      text,                       -- 'YYYY-MM-DD'
  placa      text,
  datos      jsonb not null,
  subido_por text,
  updated_at timestamptz not null default now()
);
create index if not exists liquidaciones_control_periodo_idx on public.liquidaciones_control (periodo);

-- 2) Configuración compartida (precios de envases, catálogo de precios, flota placa→BK/reparto)
create table if not exists public.liquidaciones_config (
  clave           text primary key,
  valor           jsonb not null,
  actualizado_por text,
  updated_at      timestamptz not null default now()
);

-- 3) Registro de actividad (quién subió / movió / eliminó qué)
create table if not exists public.liquidaciones_actividad (
  id         bigint generated always as identity primary key,
  accion     text not null,
  detalle    text,
  usuario    text,
  created_at timestamptz not null default now()
);

-- 4) Seguridad (RLS):
--    · Cualquiera que abra el archivo PUEDE VER (lectura).
--    · Solo usuarios con sesión iniciada pueden subir, cambiar o borrar.
alter table public.liquidaciones           enable row level security;
alter table public.liquidaciones_config    enable row level security;
alter table public.liquidaciones_control   enable row level security;
alter table public.liquidaciones_actividad enable row level security;

drop policy if exists "ver liquidaciones"      on public.liquidaciones;
drop policy if exists "editar liquidaciones"   on public.liquidaciones;
drop policy if exists "ver control"            on public.liquidaciones_control;
drop policy if exists "editar control"         on public.liquidaciones_control;
drop policy if exists "ver config"             on public.liquidaciones_config;
drop policy if exists "editar config"          on public.liquidaciones_config;
drop policy if exists "ver actividad"          on public.liquidaciones_actividad;
drop policy if exists "registrar actividad"    on public.liquidaciones_actividad;

create policy "ver liquidaciones"    on public.liquidaciones           for select to anon, authenticated using (true);
create policy "editar liquidaciones" on public.liquidaciones           for all    to authenticated using (true) with check (true);
create policy "ver control"          on public.liquidaciones_control   for select to anon, authenticated using (true);
create policy "editar control"       on public.liquidaciones_control   for all    to authenticated using (true) with check (true);
create policy "ver config"           on public.liquidaciones_config    for select to anon, authenticated using (true);
create policy "editar config"        on public.liquidaciones_config    for all    to authenticated using (true) with check (true);
create policy "ver actividad"        on public.liquidaciones_actividad for select to anon, authenticated using (true);
create policy "registrar actividad"  on public.liquidaciones_actividad for insert to authenticated with check (true);

-- 5) Tiempo real (para que los demás vean los cambios al instante)
do $$
begin
  begin alter publication supabase_realtime add table public.liquidaciones;           exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.liquidaciones_control;   exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.liquidaciones_config;    exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.liquidaciones_actividad; exception when duplicate_object then null; end;
end $$;

-- ---------------------------------------------------------------------
-- OPCIONAL: si prefieres que SOLO personas con usuario puedan VER,
-- ejecuta además estas 3 líneas (los demás tendrán que iniciar sesión):
--   drop policy "ver liquidaciones" on public.liquidaciones;
--   drop policy "ver config"        on public.liquidaciones_config;
--   drop policy "ver actividad"     on public.liquidaciones_actividad;
--   drop policy "ver control"       on public.liquidaciones_control;
--   y crea las mismas políticas pero con "to authenticated" en vez de "to anon, authenticated".
-- ---------------------------------------------------------------------
