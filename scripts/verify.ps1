$ErrorActionPreference = "Stop"

flutter pub get
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --release `
  --dart-define=SUPABASE_URL="$env:SUPABASE_URL" `
  --dart-define=SUPABASE_ANON_KEY="$env:SUPABASE_ANON_KEY"
