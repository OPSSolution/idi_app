# IDI APP Mobile

Native iOS and Android application generated with Capacitor. The complete IDI APP experience is bundled locally in `www/`, including membership, partners, news, events, renewal billing, and the ABA PayWay KHQR prototype. Native projects, IDI app icons, launch screens, mobile safe-area styling, and offline web assets are included.

## Project identity

- App name: `IDI APP`
- iOS bundle identifier: `org.idiassociation.app`
- Android application ID: `org.idiassociation.app`
- Platforms: iPhone, iPad, and Android

## Open the native projects

Install dependencies and synchronize native files:

```bash
pnpm install
pnpm sync
```

Open iOS in Xcode:

```bash
pnpm ios
```

Open Android in Android Studio:

```bash
pnpm android
```

For iOS distribution, select the IDI Association Apple Developer team, configure signing, archive in Xcode, and upload through App Store Connect.

For Android distribution, configure a release signing key in Android Studio and generate an Android App Bundle (`.aab`) for Google Play.

## Updating app content

Update files inside `www/`, then run:

```bash
pnpm sync
```

## Production services still required

- Real authentication and database
- Push notification credentials for Apple and Firebase
- File and image storage
- ABA PayWay merchant credentials and secure backend callbacks
- Privacy policy, terms, support URL, and store listing metadata

#### ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈

pnpm is now installed (v11.10.0) via corepack. In your terminal, run:

cd /Users/luxlinna/Work_in_Khmer/IDI/idi-app-mobile
pnpm install
pnpm sync
Then to open the native projects:

pnpm ios # opens Xcode
pnpm android # opens Android Studio
Try pnpm install from the project root now — let me know if it errors.
