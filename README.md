# Beacon

Beacon is an iOS app for exploring nearby cafes, restaurants, and hotels.

## Requirements

- Xcode 26 or later
- A Geoapify API key

## Configure the Geoapify API key

Copy `Config.local.xcconfig.example` to `Config.local.xcconfig` and replace the
placeholder with your Geoapify API key. The local file is ignored by Git. The app
reads the setting from its generated `Info.plist`.

API keys embedded in an iOS app can be extracted from the app. Use a key
restricted to the services this app needs, set usage limits, and rotate any key
that has been exposed.

## Open the project

Open `Beacon.xcodeproj` in Xcode, configure the API key, then build and run the
**Beacon** scheme.
