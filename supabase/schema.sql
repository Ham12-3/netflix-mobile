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

drop policy if exists "Authenticated users can read movies" on public.movies;
create policy "Authenticated users can read movies"
on public.movies for select
to authenticated
using (true);

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile"
on public.profiles for select
to authenticated
using ((select auth.uid()) = id);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile"
on public.profiles for insert
to authenticated
with check ((select auth.uid()) = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

drop policy if exists "Users can read own watchlist" on public.watchlist;
create policy "Users can read own watchlist"
on public.watchlist for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert own watchlist" on public.watchlist;
create policy "Users can insert own watchlist"
on public.watchlist for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete own watchlist" on public.watchlist;
create policy "Users can delete own watchlist"
on public.watchlist for delete
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can read own history" on public.watch_history;
create policy "Users can read own history"
on public.watch_history for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can insert own history" on public.watch_history;
create policy "Users can insert own history"
on public.watch_history for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update own history" on public.watch_history;
create policy "Users can update own history"
on public.watch_history for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

insert into public.movies (
  id,
  title,
  description,
  poster_url,
  backdrop_url,
  video_url,
  video_type,
  genres,
  release_year,
  rating,
  duration_minutes,
  is_featured,
  source_name,
  license_note
) values
(
  '11111111-1111-4111-8111-111111111111',
  'Big Buck Bunny',
  'A bright open movie from the Blender Foundation, used here as a legal playback sample for a family-friendly animated short.',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  'mp4',
  array['Animation', 'Family', 'Open Movie'],
  2008,
  'All',
  10,
  true,
  'Blender Foundation sample catalog',
  'Creative Commons open movie sample.'
),
(
  '22222222-2222-4222-8222-222222222222',
  'Sintel',
  'A fantasy open movie with cinematic action and an HLS stream suited for testing adaptive playback on Android.',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
  'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
  'hls',
  array['Fantasy', 'Adventure', 'HLS'],
  2010,
  'PG',
  15,
  true,
  'Mux public test stream',
  'Public HLS test stream for playback validation.'
),
(
  '33333333-3333-4333-8333-333333333333',
  'Tears of Steel',
  'A sci-fi open movie sample featuring live action, visual effects, and a reliable MP4 stream.',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
  'mp4',
  array['Sci-Fi', 'Action', 'Open Movie'],
  2012,
  'PG-13',
  12,
  false,
  'Blender Foundation sample catalog',
  'Creative Commons open movie sample.'
),
(
  '44444444-4444-4444-8444-444444444444',
  'Elephants Dream',
  'A surreal animated open movie and one of the classic legal test titles for streaming applications.',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  'mp4',
  array['Animation', 'Experimental', 'Open Movie'],
  2006,
  'PG',
  11,
  false,
  'Blender Foundation sample catalog',
  'Creative Commons open movie sample.'
),
(
  '55555555-5555-4555-8555-555555555555',
  'For Bigger Blazes',
  'A short sample clip included to test quick starts, seeking, and history updates without long buffering.',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  'mp4',
  array['Shorts', 'Action', 'Sample'],
  2015,
  'All',
  1,
  false,
  'Google public sample video bucket',
  'Public sample video for app playback testing.'
),
(
  '66666666-6666-4666-8666-666666666666',
  'For Bigger Joyrides',
  'A compact sample stream for testing search, category rows, playback controls, and watch progress.',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
  'mp4',
  array['Shorts', 'Cars', 'Sample'],
  2015,
  'All',
  1,
  false,
  'Google public sample video bucket',
  'Public sample video for app playback testing.'
)
on conflict (id) do update set
  title = excluded.title,
  description = excluded.description,
  poster_url = excluded.poster_url,
  backdrop_url = excluded.backdrop_url,
  video_url = excluded.video_url,
  video_type = excluded.video_type,
  genres = excluded.genres,
  release_year = excluded.release_year,
  rating = excluded.rating,
  duration_minutes = excluded.duration_minutes,
  is_featured = excluded.is_featured,
  source_name = excluded.source_name,
  license_note = excluded.license_note;
