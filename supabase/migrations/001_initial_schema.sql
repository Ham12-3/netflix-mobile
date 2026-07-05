create extension if not exists "pgcrypto";

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.movies (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  poster_url text not null,
  backdrop_url text not null,
  video_url text not null,
  video_type text not null check (video_type in ('hls', 'mp4')),
  genres text[] not null default '{}',
  release_year int not null,
  rating text,
  duration_minutes int,
  is_featured boolean not null default false,
  source_name text not null,
  license_note text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.watchlist (
  user_id uuid not null references auth.users(id) on delete cascade,
  movie_id uuid not null references public.movies(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, movie_id)
);

create table if not exists public.watch_history (
  user_id uuid not null references auth.users(id) on delete cascade,
  movie_id uuid not null references public.movies(id) on delete cascade,
  position_seconds int not null default 0,
  completed boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, movie_id)
);

create index if not exists watchlist_movie_id_idx on public.watchlist(movie_id);
create index if not exists watch_history_movie_id_idx on public.watch_history(movie_id);

alter table public.profiles enable row level security;
alter table public.movies enable row level security;
alter table public.watchlist enable row level security;
alter table public.watch_history enable row level security;

create policy "Authenticated users can read movies"
on public.movies for select
to authenticated
using (true);

create policy "Users can read own profile"
on public.profiles for select
to authenticated
using ((select auth.uid()) = id);

create policy "Users can insert own profile"
on public.profiles for insert
to authenticated
with check ((select auth.uid()) = id);

create policy "Users can update own profile"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

create policy "Users can read own watchlist"
on public.watchlist for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can insert own watchlist"
on public.watchlist for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can delete own watchlist"
on public.watchlist for delete
to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can read own history"
on public.watch_history for select
to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can insert own history"
on public.watch_history for insert
to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can update own history"
on public.watch_history for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
