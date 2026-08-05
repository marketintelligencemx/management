-- Meridian Consulting & Solutions · checklist de arranque
-- Esquema de sincronizacion entre socios.
-- Correr completo en el SQL Editor de Supabase. Es idempotente:
-- se puede volver a correr sin romper nada.

-- ── Tabla de estado ─────────────────────────────────────────────
-- Un solo renglon con el snapshot completo, en el mismo formato
-- que hoy se guarda en localStorage. Sin cambio de formato: lo que
-- viaja es el mismo JSON.

create table if not exists public.checklist_state (
  id         text primary key,
  payload    jsonb       not null,
  updated_at timestamptz not null default now()
);

-- El renglon unico de esta herramienta. Si ya existe, no lo toca.
insert into public.checklist_state (id, payload)
values ('arranque', '{}'::jsonb)
on conflict (id) do nothing;

-- ── Permisos ────────────────────────────────────────────────────
-- Decision tomada: llave compartida, sin cuentas por socio. La llave
-- publica vive en index.html y el repo es publico, asi que hay que
-- asumir que cualquiera puede tenerla.
--
-- Lo que se acota aqui es el dano posible: el rol anonimo solo puede
-- LEER y ACTUALIZAR. No puede insertar renglones nuevos, no puede
-- borrar y no puede vaciar la tabla. El unico dano posible es
-- sobrescribir el contenido del renglon 'arranque', que se recupera
-- desde el respaldo JSON o desde el espejo en localStorage.

revoke all on table public.checklist_state from anon;
grant select, update on table public.checklist_state to anon;

alter table public.checklist_state enable row level security;

drop policy if exists "anon lee arranque" on public.checklist_state;
create policy "anon lee arranque"
  on public.checklist_state
  for select
  to anon
  using (id = 'arranque');

drop policy if exists "anon actualiza arranque" on public.checklist_state;
create policy "anon actualiza arranque"
  on public.checklist_state
  for update
  to anon
  using (id = 'arranque')
  with check (id = 'arranque');

-- ── Marca de tiempo automatica ──────────────────────────────────
-- updated_at se pone en el servidor, no lo dicta el cliente: asi la
-- deteccion de cambios entre socios no depende del reloj de cada
-- maquina.

create or replace function public.checklist_touch()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists checklist_state_touch on public.checklist_state;
create trigger checklist_state_touch
  before update on public.checklist_state
  for each row execute function public.checklist_touch();

-- ── Verificacion ────────────────────────────────────────────────
-- Debe devolver un renglon con id = 'arranque'.
select id, updated_at, pg_column_size(payload) as bytes
from public.checklist_state;
