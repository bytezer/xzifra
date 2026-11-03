# Signing the APK

Android identifies an app by its signing key. The same key must sign every
update, otherwise the system refuses to install over the existing app — and the
only workaround is uninstalling, which **deletes the local database**.

## Where things live

| Item | Path |
| --- | --- |
| Keystore | `~/.android/keystores/xzifra-release.jks` |
| Credentials | `~/.android/keystores/xzifra-keystore.properties` |
| Gradle config | `app/android/key.properties` (gitignored) |

Both the keystore and the credentials file live outside the repository and are
readable only by the current user.

`app/android/key.properties` contains:

```properties
storePassword=...
keyPassword=...
keyAlias=xzifra
storeFile=/home/<user>/.android/keystores/xzifra-release.jks
```

`app/android/app/build.gradle.kts` loads it when present and falls back to the
debug key when missing. A build without `key.properties` is only useful for
local testing; never distribute it.

## Back up the keystore

Copy `xzifra-release.jks` and `xzifra-keystore.properties` to a password manager
or an encrypted backup. If they are lost:

1. Uninstall the app (data is deleted).
2. Generate a new keystore.
3. Reinstall and import the last JSON backup.

## Verify the signature

```bash
keytool -list -v -keystore ~/.android/keystores/xzifra-release.jks -alias xzifra
```

Or inspect the built APK:

```bash
apksigner verify --print-certs app/build/app/outputs/flutter-apk/app-release.apk
```

## Update flow

```bash
./scripts/build-apk.sh
adb install -r app/build/app/outputs/flutter-apk/app-release.apk
```

Because the version code comes from `pubspec.yaml`, bump `version:` before a
release (`0.1.0+1` → `0.1.1+2`).
