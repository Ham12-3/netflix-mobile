# DevOps

This repo is set up for a simple mobile CI/CD flow:

- GitHub Actions verifies every push and pull request.
- Manual Android release builds can target `dev`, `staging`, or `prod`.
- Supabase schema changes live in versioned SQL migrations.
- Supabase keys are passed at build time with `--dart-define`.

## Environments

Create GitHub environments with these names:

```text
dev
staging
prod
```

Each environment should have these secrets:

```text
SUPABASE_URL
SUPABASE_ANON_KEY
```

Use a separate Supabase project or branch per environment when the app is ready
for real users. The current `luma-stream` Supabase project can serve as `dev`.

## Workflows

`Flutter CI` runs on pushes and pull requests:

```text
flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --release
```

`Android Release Build` runs manually from GitHub Actions and produces:

```text
app-release.apk
app-release.aab
```

Use the `.aab` for Play Store releases later.

## Local Verification

PowerShell:

```powershell
$env:SUPABASE_URL="https://YOUR_PROJECT.supabase.co"
$env:SUPABASE_ANON_KEY="YOUR_PUBLISHABLE_OR_ANON_KEY"
.\scripts\verify.ps1
```

If the environment variables are empty, the app still builds and falls back to
demo mode at runtime.

## Emulator Streaming Workaround

If the Android emulator cannot reach the public internet, run the local media
bridge and build with `MEDIA_BASE_URL`:

```powershell
.\scripts\download_demo_media.ps1
node scripts\media_proxy.js
flutter build apk --release --dart-define=MEDIA_BASE_URL=http://10.0.2.2:8787
```

This is for emulator testing only. Supabase and production builds should keep
using the normal HTTPS Internet Archive URLs.

## Database Migrations

The canonical schema snapshot is:

```text
supabase/schema.sql
```

Versioned migrations are in:

```text
supabase/migrations/
```

Apply migrations to the matching Supabase environment before building a release
against that environment. Never put a Supabase `service_role` key in Flutter,
GitHub artifacts, or checked-in files.

## Release Checklist

1. Merge only after CI passes.
2. Apply database migrations to the target Supabase environment.
3. Run the `Android Release Build` workflow.
4. Smoke test signup/login, catalog loading, watchlist, and playback.
5. Promote the `.aab` to Play Store internal testing when ready.
