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

## Connecting to a real database (Supabase)

Auth, the company directory, news, events, and membership/renewal data can be backed by a real
[Supabase](https://supabase.com) project instead of the hardcoded demo data in `www/app.js`.

1. Create a free project at supabase.com.
2. Open the project's SQL Editor and run `supabase/schema.sql` — it creates the tables, Row Level
   Security policies, and seeds the demo companies/news/events.
3. In **Authentication → Users**, create the demo accounts listed at the bottom of `schema.sql`
   (e.g. `admin@idiapp.org`, `sokha@uniholding.com`, ...). Give every account except the admin the
   password `IdiDemo#2026` (this is the shared password the app's one-click demo login buttons use);
   give the admin account the password shown in the app UI. After creating each user, run the
   matching `update public.profiles ...` statement from the bottom of `schema.sql` so their tier,
   role, and permissions match the app.
4. Copy the project's URL and `anon` public API key (Settings → API) into `www/supabase-config.js`.
5. Reload the app — companies/news/events now load from Postgres, and login goes through Supabase
   Auth. If `supabase-config.js` is left unfilled, the app keeps working exactly as before using the
   hardcoded demo data, so there's no hard dependency on Supabase being set up.

Everything else (investment pipeline, deals, conversations, staff roles, pitches, campaigns,
funding requests, and the KHQR/PayWay billing simulation) remains local demo data.

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
