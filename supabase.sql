-- Spusťte jednou v Supabase SQL Editoru.
create extension if not exists pgcrypto;
create table if not exists public.admins (
 user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.events (
 id uuid primary key default gen_random_uuid(),
 title text not null check (char_length(title) between 1 and 120),
 event_date date not null,
 event_time time,
 place text not null default '',
 category text not null default 'Ostatní',
 description text not null default '',
 created_at timestamptz not null default now()
);
alter table public.admins enable row level security;
alter table public.events enable row level security;
revoke all on public.admins from anon, authenticated;
grant select on public.admins to authenticated;
grant select on public.events to anon, authenticated;
grant insert, update, delete on public.events to authenticated;
drop policy if exists "admin reads own membership" on public.admins;
create policy "admin reads own membership" on public.admins for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists "everyone reads events" on public.events;
create policy "everyone reads events" on public.events for select to anon, authenticated using (true);
drop policy if exists "admins insert events" on public.events;
create policy "admins insert events" on public.events for insert to authenticated with check (exists(select 1 from public.admins where user_id = (select auth.uid())));
drop policy if exists "admins update events" on public.events;
create policy "admins update events" on public.events for update to authenticated using (exists(select 1 from public.admins where user_id = (select auth.uid()))) with check (exists(select 1 from public.admins where user_id = (select auth.uid())));
drop policy if exists "admins delete events" on public.events;
create policy "admins delete events" on public.events for delete to authenticated using (exists(select 1 from public.admins where user_id = (select auth.uid())));
-- Po vytvoření účtů v Supabase Authentication přidejte jejich UUID ručně:
-- insert into public.admins(user_id) values ('UUID_STAROSTY'), ('UUID_ZASTUPITELE');
-- Nikdy nevkládejte service_role key do veřejného GitHub repozitáře.
