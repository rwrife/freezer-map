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

## iOS signing (automated, no local macOS required)

Signed builds are produced by the `iOS Release` workflow
(`.github/workflows/ios-release.yml`), which runs the fastlane lanes at the
repository root. No certificate or profile is stored in the repository. Xcode
provisions profiles from App Store Connect at build time using an API key. A
reusable Apple Development certificate is stored as an encrypted GitHub Actions
secret and imported into Fastlane's temporary keychain for each run.

1. The bundle identifier (`com.infinityball.freezermap`) and `DEVELOPMENT_TEAM`
   live in `ios/Runner.xcodeproj/project.pbxproj`, with
   `CODE_SIGN_STYLE = Automatic`. The Release configuration deliberately pins no
   `CODE_SIGN_IDENTITY`: under automatic signing Xcode signs the archive for
   development and re-signs for distribution at export, and naming an identity
   conflicts with that.
2. Three repository secrets authenticate to App Store Connect: `ASC_KEY_ID`,
   `ASC_ISSUER_ID`, and `ASC_KEY_P8` (the `.p8` contents, or their base64). The
   key must hold the **Admin** role so Xcode can manage provisioning and cloud
   distribution signing.
3. Two repository secrets provide the reusable Apple Development identity:
   `IOS_DEVELOPMENT_CERTIFICATE_P12` contains the base64-encoded raw `.p12`, and
   `IOS_DEVELOPMENT_CERTIFICATE_PASSWORD` contains its export password. Create
   the certificate once on a trusted Mac, export it with its private key from
   Keychain Access, and set the secrets without committing either value:

```bash
base64 -i ios-development.p12 | gh secret set IOS_DEVELOPMENT_CERTIFICATE_P12
gh secret set IOS_DEVELOPMENT_CERTIFICATE_PASSWORD
```

   Before the first run, revoke obsolete `Apple Development: Created via API`
   certificates in the Apple Developer portal if the team has reached its
   certificate limit. Keep the certificate represented by the new `.p12`.
   Reusing this identity prevents ephemeral runners from consuming another
   certificate slot on every release.
4. Run it from the Actions tab, or:

```bash
gh workflow run ios-release.yml -f lane=beta      # TestFlight
gh workflow run ios-release.yml -f lane=release   # TestFlight + submit for review
```

   Pushing a `v*` tag runs the `beta` lane.

5. Verify a compile without signing (this also runs on every PR):

```bash
flutter build ios --release --no-codesign
```

The lanes take the build number from App Store Connect
(`latest_testflight_build_number + 1`) and the marketing version from
`pubspec.yaml`, reduced to the dot-separated integers App Store Connect accepts
(`0.1.0-rc.1+7` ships as `0.1.0`). Nothing is written back into the Xcode
project, because Flutter regenerates `$(FLUTTER_BUILD_NAME)` and
`$(FLUTTER_BUILD_NUMBER)` on every build.

## Packaging guidance

- **Sideload/testing (Android):** use CI-produced release APK artifacts.
- **Store distribution (Android):** publish signed AAB/APK from secure release
  pipeline only.
- **Store distribution (iOS):** run the `iOS Release` workflow; it archives,
  exports, and uploads to TestFlight (or submits for review) without a local
  macOS host.

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
