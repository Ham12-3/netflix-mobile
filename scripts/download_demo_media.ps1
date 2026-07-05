$ErrorActionPreference = "Stop"

$mediaDir = Join-Path $PSScriptRoot "..\dev_media"
New-Item -ItemType Directory -Force $mediaDir | Out-Null

$files = @(
  @{
    Url = "https://archive.org/download/BigBuckBunny_328/BigBuckBunny_512kb.mp4"
    Out = "BigBuckBunny_512kb.mp4"
  },
  @{
    Url = "https://archive.org/services/img/BigBuckBunny_328"
    Out = "BigBuckBunny_328.jpg"
  }
)

foreach ($file in $files) {
  $target = Join-Path $mediaDir $file.Out
  if (Test-Path $target) {
    Write-Host "Already exists: $target"
    continue
  }

  Write-Host "Downloading $($file.Url)"
  curl.exe -L --fail --max-time 300 -o $target $file.Url
}
