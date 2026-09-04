# Poddrunk Development & Release Protocols

Whenever changes or new features are implemented in this repository, always adhere to the following established release and update workflow:

## 1. Versioning Protocol
- Always update `version: X.Y.Z+N` in `pubspec.yaml`:
  - Increment the semantic version `X.Y.Z` appropriately.
  - **Always increment the build number / versionCode `+N` by 1** (e.g., `1.0.0+1` -> `1.1.0+2`). This is required by Android and F-Droid to recognize updates.

## 2. Fastlane & F-Droid Store Changelogs
- Whenever a new version is prepared, create the corresponding changelog text file:
  - Path: `fastlane/metadata/android/en-US/changelogs/<versionCode>.txt` (e.g. `2.txt` for `+2`).
  - Keep it to 3–4 punchy, clear bullet points summarizing the user-facing improvements and fixes.

## 3. Git Release Tagging & GitHub Releases
- After verifying changes with `flutter analyze` and `flutter test`:
  1. Commit changes to `main`.
  2. Tag the commit with the matching version tag: `git tag vX.Y.Z`.
  3. Push to origin with tags: `git push origin main --tags`.
  4. Build the production APK: `flutter build apk --release`.
  5. Upload the compiled APK (`build/app/outputs/flutter-apk/app-release.apk`) to the corresponding GitHub Release on `https://github.com/paperlinkos/poddrunk`.

## 4. F-Droid Automation
- F-Droid's build bot automatically polls tags (`UpdateCheckMode: Tags`). Once the new tag is pushed to GitHub, F-Droid automatically triggers a build and publishes the update to F-Droid client users.
