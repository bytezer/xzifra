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
flutter build apk --release "$@"

echo
echo "APK: $ROOT/app/build/app/outputs/flutter-apk/app-release.apk"
