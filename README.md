# Luma Stream

Android-first Flutter streaming app with an original Netflix-inspired layout,
Supabase-ready auth/data, legal seeded videos, search, watchlist, details pages,
watch history, and real playback through `video_player`.

The app intentionally does not include pirated premium films or Netflix assets.
Seed entries are public sample/open-movie streams with source and license notes.

## Run locally

```powershell
flutter pub get
flutter run
```

Without Supabase environment values the app runs in local demo mode, so you can
sign up, log in, save titles, search, and play sample videos immediately.

## Use Supabase

1. Create a Supabase project.
2. Run `supabase/schema.sql` in the Supabase SQL editor.
3. Start Flutter with your project values:

```powershell
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_OR_ANON_KEY
```

The mobile app reads movies and writes only the signed-in user's own profile,
watchlist, and watch history through RLS. Movie insert/update/delete remains
admin-only through the dashboard/service role.

## Verify

```powershell
flutter analyze
flutter test
flutter build apk
```

## DevOps

GitHub Actions workflows are included for CI and manual Android releases:

- `.github/workflows/flutter-ci.yml`
- `.github/workflows/android-release.yml`

Add these secrets to each GitHub environment (`dev`, `staging`, `prod`):

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

More detail is in `docs/DEVOPS.md`.

## Main Features

- Email signup/login with Supabase or local demo fallback.
- Auth-aware navigation with `go_router`.
- Home feed with featured title and horizontal genre rows.
- Search across title, genre, source, and description.
- Movie details with source/license notes.
- Watchlist add/remove persisted per user.
- Watch history position saved on player exit.
- HLS and MP4 playback with loading, errors, play/pause, seek, and immersive player UI.
