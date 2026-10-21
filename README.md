<p align="center">
  <img src="android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="144" height="144" alt="BAKUDAPA MOBILE app logo">
</p>

<h1 align="center">BAKUDAPA MOBILE</h1>

<p align="center">
  <strong>Civil administration services. One connected mobile experience.</strong><br>
  A Flutter client for registration, service applications, and request tracking.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-Proprietary-D4AF37?style=flat&labelColor=222222" alt="Proprietary license"></a>
  <img src="https://img.shields.io/badge/framework-Flutter-02569B?style=flat&labelColor=222222&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-%5E3.12.0-0175C2?style=flat&labelColor=222222&logo=dart" alt="Dart SDK constraint">
  <img src="https://img.shields.io/badge/state-Riverpod-8BC34A?style=flat&labelColor=222222" alt="Riverpod state management">
</p>

<p align="center">
  <a href="#getting-started">Getting started</a> ·
  <a href="#features">Features</a> ·
  <a href="#project-structure">Architecture</a> ·
  <a href="https://github.com/SayuZX/bakudapa-app/issues">Issues</a> ·
  <a href="LICENSE">License</a>
</p>

BAKUDAPA MOBILE is a mobile client for population administration and civil registration workflows in North Maluku. It brings account registration, service discovery, application submission, document uploads, and status tracking into a shared interface.

**Guided registration** · **Service applications** · **Document uploads** · **Request tracking**

Original project material is maintained by **Raihan Nugroho** ([SayuZX](https://github.com/SayuZX)). Institutional names and marks identify the application's service context; they do not establish personal ownership of government branding or imply an endorsement of this repository.

> [!IMPORTANT]
> This repository contains the mobile client, not a standalone civil-registration backend. Functional service flows require an authorized, compatible backend and appropriate accounts. Do not submit real identity documents or biometric data to development environments.

## Features

### 01 · Guided account registration

Registration is organized into identity, document photo, face photo, liveness, consent, and completion stages. The client includes OTP authentication and password recovery flows. Backend validation remains authoritative.

### 02 · Discover and apply for services

Browse available services, review service details, complete application forms, and submit supporting documents. Service definitions and processing outcomes depend on the connected backend.

### 03 · Track applications and documents

Review submitted requests, inspect application details, and access result-document workflows. Upload progress is surfaced during submission rather than leaving users without feedback.

### 04 · Manage profiles and device sessions

Profile settings, language preferences, password changes, device-session history, and session revocation have dedicated client flows. Local biometric and device-related modules support the application's authentication experience; their presence is not a claim of independently audited security.

### 05 · Stay informed and find assistance

Notifications, help, tutorials, and AI assistance have separate feature areas. Maintenance handling provides a dedicated state when services are unavailable. AI assistance requires the corresponding backend endpoints.

### 06 · Shared mobile foundations

Riverpod coordinates application state, GoRouter handles navigation, and Dio provides HTTP access. Shared modules cover storage, camera access, regional data, localization, uploads, themes, and validation.

## Getting started

### Requirements

- Flutter with a bundled Dart SDK satisfying **`^3.12.0`**.
- Android SDK and a configured Android device or emulator for Android development.
- macOS, Xcode, and the required signing setup for iOS development.
- Access to an authorized backend compatible with the routes in `lib/core/config/endpoints.dart`.

```bash
git clone https://github.com/SayuZX/bakudapa-app.git
cd bakudapa-app
flutter --version
flutter doctor
flutter pub get
```

Repository access does not grant permission to modify or redistribute the project. Obtain authorization under [LICENSE](LICENSE) before using these development instructions beyond rights granted by applicable law or a separate agreement.

### Configure a development backend

The environment configuration is defined in `lib/core/config/lingkungan.dart`.

| Define | Purpose |
|---|---|
| `APP_ENV=dev_lokal` | Select the Android emulator development endpoint, `https://10.0.2.2:3000/api`. |
| `BAKUDAPA_HOST` | Override the complete backend API base URL. |
| `TANGGAL_BUILD` | Supply an optional build-date label. |

```bash
# Android emulator with an authorized local backend
flutter run --dart-define=APP_ENV=dev_lokal

# An explicitly configured development environment
flutter run --dart-define=BAKUDAPA_HOST=https://your-development-host.example/api
```

> [!WARNING]
> The current configuration disables certificate pinning when `APP_ENV=dev_lokal` or `BAKUDAPA_HOST` is supplied. Do not ship development overrides as a production security configuration. Pinning configuration alone is not evidence that every runtime security check is effective.

Without an override, the application selects the production endpoint configured in the source. Use a deliberate development configuration when testing; do not direct test submissions at production by accident.

### Build an Android package

```bash
flutter build apk --release
```

Default Flutter APK output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Configure release signing and confirm backend settings before distribution. This documentation change does not certify a successful build or an approved production release.

## Project structure

```text
bakudapa-app/
├── lib/
│   ├── core/           Configuration, networking, storage, device services, and themes
│   ├── features/       Registration, authentication, applications, and customer flows
│   └── shared/         Shared application components
├── assets/             Images, icons, and sounds
├── android/            Android platform project
├── ios/                iOS platform project
├── test/               Feature and widget checks
├── tool/               Project tooling
├── tools/              Additional development utilities
├── pubspec.yaml        Application metadata and dependencies
├── README.md           Project documentation
└── LICENSE             Ownership and permission terms
```

## Verification

```bash
flutter analyze
flutter test
```

The repository includes checks for service details, application forms, navigation, device flows, registration liveness, maintenance links, and regional data. Run them in your configured environment; their presence does not mean they have passed on your device or deployment.

Exercise camera permissions, uploads, navigation, authentication, and failure states on actual target devices. Use synthetic records and test documents, not personal production data.

## Data handling

This application handles workflows involving identity documents, face capture, location, and device information. Only enable collection required by the authorized service and its consent process.

- Keep credentials, tokens, signing keys, and personal records out of commits.
- Redact identity numbers, contact details, document images, and biometric data from logs and issue reports.
- Restrict development backends and test accounts appropriately.
- Review backend authorization and retention separately; client checks are not a substitute for server controls.

## Troubleshooting

| Symptom | Check |
|---|---|
| Dependencies cannot resolve | Confirm the installed Dart SDK satisfies `^3.12.0`. |
| The emulator cannot reach the backend | Check the complete API URL, emulator routing, local server, and HTTPS setup. |
| Registration or OTP fails | Confirm backend availability, credentials, validation responses, and service rate limits. |
| A document upload fails | Check MIME type, file size, permissions, and the backend response. Limits are defined in `lib/core/config/limits.dart`. |
| Camera or biometric features are unavailable | Review device capabilities and platform permissions. |
| The maintenance page appears | Inspect maintenance and configuration responses before retrying submissions. |

## Issues and permission requests

Report reproducible defects through [GitHub Issues](https://github.com/SayuZX/bakudapa-app/issues). Include the app version, platform, reproduction steps, and sanitized logs. Do not post credentials or personal identity data.

Request written permission from **Raihan Nugroho** at [pixelraihan77@gmail.com](mailto:pixelraihan77@gmail.com) before modifying, renaming, rebranding, or redistributing original project material. A request or unanswered email is not approval.

## License and ownership

**Copyright © 2026 Raihan Nugroho. All rights reserved for original project material.**

The project uses a proprietary license. Without prior written authorization, you may not modify original project material, rename or rebrand it, redistribute it, remove its notices, or claim it as your own. You may not alter the license notice to represent that additional permissions have been granted.

See [LICENSE](LICENSE) for the complete terms. Third-party libraries, assets, institutional marks, and separately licensed material remain subject to their respective owners' rights and applicable licenses. The project license does not revoke permissions independently granted by those licenses or by applicable law.
