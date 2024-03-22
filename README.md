# Smily mobile App

The is the project app for Smily

## Getting Started

The project is ready for production.

### Firebase setup

To build the project the configuration files for Firebase are needed. These files are not included in the repository because they contain API Keys.
Steps to setup firebase:

1. Login to [Firebase console](https://console.firebase.google.com)
2. Select the project (mobile-app-staging / mobile-app-production)
3. Go to Project settings
4. Select Android App, download `google-services.json` and copy it to `/android/app/`
5. Select iOS App, download `GoogleService-Info.plist` and copy it to `/ios/Runner/`
6. Install [FlutterFire](https://firebase.flutter.dev/docs/cli) if you don't have it yet
7. run `flutterfire configure` and select iOS + Android apps. It should generate `firebase_options.dart` file in `/lib/`

### Install Flutter

Before considering working on this project, please make sure Flutter framework is correctly installed and up to date.
You can do that following guidance on flutter website on that link: https://docs.flutter.dev/get-started/install

### Android build

To build the android apk you can simply use this command:

`flutter build apk --split-per-abi`

the option `--split-per-abi` lets you build an apk for each architecture type.
You'll find more on that at https://docs.flutter.dev/deployment/android

### iOS build

To build the iOS app you'll need to follow steps detailed on iOS deployment page of flutter docmentation here: https://docs.flutter.dev/deployment/ios
