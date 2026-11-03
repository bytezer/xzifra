#!/usr/bin/env bash
# Builds a signed release APK using the local toolchain.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLCHAIN="${XZIFRA_TOOLCHAIN:-$ROOT/../.toolchains}"

if [[ -d "$TOOLCHAIN/flutter" ]]; then
  export PATH="$TOOLCHAIN/flutter/bin:$PATH"
fi
if [[ -d "$TOOLCHAIN/jdk" ]]; then
  export JAVA_HOME="$TOOLCHAIN/jdk"
  export PATH="$JAVA_HOME/bin:$PATH"
fi
if [[ -d "$TOOLCHAIN/android-sdk" ]]; then
  export ANDROID_HOME="$TOOLCHAIN/android-sdk"
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export PATH="$ANDROID_HOME/platform-tools:$PATH"
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter not found. Install it or set XZIFRA_TOOLCHAIN." >&2
  exit 1
fi

cd "$ROOT/app"
flutter pub get

GIT_COMMIT="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo dev)"
GIT_BRANCH="$(git -C "$ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || echo main)"
BUILD_DATE="$(date -u +%Y-%m-%d)"

flutter build apk --release \
  --dart-define=BUILD_COMMIT="$GIT_COMMIT" \
  --dart-define=BUILD_BRANCH="$GIT_BRANCH" \
  --dart-define=BUILD_DATE="$BUILD_DATE" \
  "$@"

echo
echo "APK: $ROOT/app/build/app/outputs/flutter-apk/app-release.apk"
