#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This bootstrap must run on macOS because the next step requires Xcode."
  exit 1
fi

expected_flutter_version="3.47.0"
expected_dart_version="3.13.0"
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mobile_directory="$repository_root/apps/mobile"
flutter_command="flutter"
dart_command="dart"

if [[ -x "$repository_root/.fvm/flutter_sdk/bin/flutter" ]]; then
  flutter_command="$repository_root/.fvm/flutter_sdk/bin/flutter"
  dart_command="$repository_root/.fvm/flutter_sdk/bin/dart"
fi

for required_command in "$flutter_command" "$dart_command" xcodebuild; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "Missing required command: $required_command"
    exit 1
  fi
done

echo "Checking Flutter and Xcode..."
flutter_version_output="$("$flutter_command" --version)"
dart_version_output="$("$dart_command" --version 2>&1)"

echo "$flutter_version_output"
echo "$dart_version_output"
xcodebuild -version

if [[ ! "$flutter_version_output" =~ Flutter[[:space:]]+${expected_flutter_version}([[:space:]]|$) ]]; then
  echo "Flutter $expected_flutter_version is required. Install/select it with FVM before continuing."
  exit 1
fi

if [[ ! "$dart_version_output" =~ Dart[[:space:]]SDK[[:space:]]version:[[:space:]]${expected_dart_version}([[:space:]]|$) ]]; then
  echo "Dart $expected_dart_version is required (bundled with Flutter $expected_flutter_version)."
  exit 1
fi

if [[ -e "$mobile_directory" && ! -d "$mobile_directory" ]]; then
  echo "Expected a directory at: $mobile_directory"
  exit 1
fi

if [[ -d "$mobile_directory" ]]; then
  if [[ ! -f "$mobile_directory/pubspec.yaml" ]]; then
    echo "Existing mobile directory has no pubspec.yaml: $mobile_directory"
    exit 1
  fi

  if [[ ! -d "$mobile_directory/ios" || ! -d "$mobile_directory/android" ]]; then
    echo "Generating missing iOS and Android host projects..."
    (
      cd "$mobile_directory"
      "$flutter_command" create \
        --platforms=ios,android \
        --org com.devnamu \
        --project-name dopa \
        --no-pub \
        .
    )
  else
    echo "iOS and Android host projects already exist; keeping them unchanged."
  fi
else
  echo "Creating the Dopa Flutter application..."
  "$flutter_command" create \
    --platforms=ios,android \
    --org com.devnamu \
    --project-name dopa \
    --no-pub \
    "$mobile_directory"
fi

echo "Resolving Flutter dependencies..."
(
  cd "$repository_root"
  "$flutter_command" pub get
)

echo "Bootstrap complete."
echo "Next: open $mobile_directory/ios/Runner.xcworkspace in Xcode."
echo "Then add the four Screen Time extensions from the Apple launch runbook."
