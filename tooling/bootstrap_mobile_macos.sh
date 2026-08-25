#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap must run on macOS because the next step requires Xcode."
  exit 1
fi

for required_command in flutter xcodebuild; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "Missing required command: $required_command"
    exit 1
  fi
done

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mobile_directory="$repository_root/apps/mobile"

if [[ -e "$mobile_directory" ]]; then
  echo "Refusing to overwrite existing path: $mobile_directory"
  exit 1
fi

echo "Checking Flutter and Xcode..."
flutter --version
xcodebuild -version

echo "Creating the Dopa Flutter application..."
flutter create \
  --platforms=ios,android \
  --org com.devnamu \
  --project-name dopa \
  "$mobile_directory"

echo "Resolving Flutter dependencies..."
(
  cd "$mobile_directory"
  flutter pub get
)

echo "Bootstrap complete."
echo "Next: open $mobile_directory/ios/Runner.xcworkspace in Xcode."
echo "Then add the four Screen Time extensions from the Apple launch runbook."
