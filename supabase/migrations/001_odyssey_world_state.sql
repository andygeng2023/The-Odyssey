create table if not exists public.player_world_state (
  player_id uuid primary key references auth.users(id) on delete cascade,
  discovered_locations jsonb not null default '{}'::jsonb,
  inventory_bulk jsonb not null default '{}'::jsonb,
  equipment jsonb not null default '[]'::jsonb,
  important_objects jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.player_world_state enable row level security;
drop policy if exists "players can read own world state" on public.player_world_state;
create policy "players can read own world state" on public.player_world_state for select using (auth.uid() = player_id);
drop policy if exists "players can insert own world state" on public.player_world_state;
create policy "players can insert own world state" on public.player_world_state for insert with check (auth.uid() = player_id);
drop policy if exists "players can update own world state" on public.player_world_state;
create policy "players can update own world state" on public.player_world_state for update using (auth.uid() = player_id) with check (auth.uid() = player_id);
create index if not exists player_world_state_updated_at_idx on public.player_world_state(updated_at);
