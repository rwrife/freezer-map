# Signing and packaging guide (secret-free)

This repository does **not** store signing credentials. Use these steps as a
repeatable checklist while keeping secrets in local secure storage or CI secret
vaults.

## Android signing (local or CI)

1. Create an upload keystore locally (example placeholders):

```bash
keytool -genkeypair \
  -alias upload \
  -keyalg RSA \
  -keysize 4096 \
  -validity 3650 \
  -keystore ~/secure/freezer-map-upload.jks
```

2. Keep passwords and keystore path out of git. Configure them through local
   environment variables or CI secrets.
3. Build unsigned/release candidate binary in CI first:

```bash
flutter build apk --release
```

4. If signed APK/AAB is required, inject signing values only in private build
   contexts (never committed files).

## iOS signing (local macOS)

1. Open `ios/Runner.xcworkspace` in Xcode on a trusted macOS host.
2. Configure Team, Bundle Identifier, and Provisioning Profile.
3. Keep certificates/profiles in Apple-managed secure keychain contexts.
4. Verify compile without signing in CI:

```bash
flutter build ios --release --no-codesign
```

5. Produce signed archives only from controlled release hosts after the release
   checklist passes.

## Packaging guidance

- **Sideload/testing (Android):** use CI-produced release APK artifacts.
- **Store distribution (Android):** publish signed AAB/APK from secure release
  pipeline only.
- **Store distribution (iOS):** publish signed archive via TestFlight/App Store
  Connect from Xcode/Fastlane release automation.

## Provenance and release assets

After successful verification/build jobs, generate source archive + checksum:

```bash
mkdir -p dist
TAG_OR_SHA=$(git rev-parse --short=12 HEAD)
git archive --format=tar.gz --output="dist/freezer-map-${TAG_OR_SHA}.tar.gz" HEAD
sha256sum "dist/freezer-map-${TAG_OR_SHA}.tar.gz" > "dist/freezer-map-${TAG_OR_SHA}.sha256"
```

Attach artifacts/checksums to a GitHub Release and mark each binary as
unsigned/signed explicitly.
