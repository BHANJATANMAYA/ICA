# Indian Chess Academy (ICA) — Parent & Student Flutter Application

This is the mobile application for the **Indian Chess Academy (ICA)**, designed for parents and students to manage classes, view materials, submit homework, book trials, chat, and participate in polls. It interfaces directly with the same Supabase database as the **ICA Admin Web Panel**.

---

## Round 2 Additions

### MODULE 1 — Local SQL Cache (drift)
- Drift SQLite database (`ica_cache.sqlite`) caches all key data for offline-first resilience
- Tables: `CachedSchedules`, `CachedAttendance`, `CachedNotifications`, `GeofenceLogs`, `CachedPlans`
- Schema version: **1** (drift `MigrationStrategy` with `onCreate`)
- Sync strategy: Supabase remains source of truth; drift syncs on foreground + Realtime events
- `GeofenceLogs` are write-first (offline-safe) and synced to Supabase when online

### MODULE 2 — Push Notifications (FCM)
- Firebase Cloud Messaging for Android push notifications
- Two notification channels:
  - `class_updates` (HIGH importance) — class schedule notifications
  - `payments_alerts` (HIGH importance) — billing and payment confirmations
- FCM tokens stored in Supabase `fcm_tokens` table: `(parent_id, token, platform, updated_at)`
- All received notifications persisted to drift `CachedNotifications`
- Deep-link routing via `deep_link` payload field → GetX navigation
- Supported deep-link routes: `/attendance`, `/billing`, `/schedule`, `/chat`, `/assignments`

#### FCM Setup Steps
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a project and register Android app with package name: `com.indianchessacademy.ica_app`
3. Download `google-services.json` and replace the placeholder in `android/app/`
4. Enable Cloud Messaging in **Project Settings → Cloud Messaging**
5. The FCM Server Key is used by your backend to send push notifications

### MODULE 3 — Geolocation & Geofencing
- **Academy Geofence**: Parul University, Vadodara
  - **Latitude**: `22.2678`
  - **Longitude**: `73.1433`
  - **Radius**: `200 metres`
- One-shot geofence check on "Check In" tap (no background tracking)
- Privacy disclosure screen shown ONCE before OS permission dialog
- Manual check-in fallback when location is denied
- Permission flow: `whileInUse` → denied → rationale → settings deep-link → manual fallback

### MODULE 4 — Biometric Auth
- Opt-in at first login: fingerprint enrollment bottom sheet
- Subsequent app opens: biometric unlocks existing Supabase session
- Payment gate: `local_auth.authenticate()` before "Simulate Success" in BillingScreen
- Degrades gracefully: if biometrics unavailable, payment proceeds without gate

### MODULE 5 — App Security
- **5a. Certificate Pinning**: Dio client with SHA-256 fingerprint check for `*.supabase.co`
  - **Certificate pin placeholder**: `REPLACE_WITH_SHA256_FINGERPRINT_OF_SUPABASE_CERT`
  - To get the real pin: `openssl s_client -connect YOUR_PROJECT.supabase.co:443 | openssl x509 -noout -fingerprint -sha256`
  - Debug toggle: set `FORCE_PIN_FAILURE=true` in `.env` to force rejection (evaluator demo)
  - **Limitation**: supabase_flutter uses its own HTTP client; this Dio client covers supplemental HTTP calls
- **5b. Root/Jailbreak Detection**: Blocks app in release mode, logs warning in debug mode
- **5c. Screen Capture Prevention**: `FLAG_SECURE` in `MainActivity.kt` — no screenshots across all screens
- **5d. Secure Session Storage**: Supabase session tokens stored in Android Keystore via `flutter_secure_storage`
- **5e. Session Timeout**: 15-minute idle timeout — signs out and navigates to login
- **5f. Deep-link Security**: `AuthGuardMiddleware` on all GetX routes — blocks unauthenticated navigation

---

## Features Built (Round 1)
1. **Authentication**: Email/Password Sign Up and Log In
2. **Dashboard Shell**: Context switcher, notification bell badge, bottom navigation
3. **Schedules**: Live class calendar listings
4. **Student View**: Study Materials, Assignments, Group Chat, Polls, **Check In** (Round 2)
5. **Parent View**: Profiles, Attendance Ledger, Billing & Checkout, Trial Booking

---

## Directory Structure (GetX Architecture)

```
/lib
  ├── main.dart                          # App entry, Firebase, drift, Supabase, security init
  ├── app/
  │   ├── core/
  │   │   ├── theme/
  │   │   │   ├── colors.dart            # Brand hex colors
  │   │   │   └── typography.dart        # Brand typography sizes
  │   │   ├── supabase/
  │   │   │   └── supabase_client.dart   # Supabase initializations
  │   │   ├── database/                  # [Round 2]
  │   │   │   └── app_database.dart      # drift SQLite schema (5 tables, schemaVersion=1)
  │   │   ├── network/                   # [Round 2]
  │   │   │   └── pinned_dio_client.dart # Certificate pinning Dio client
  │   │   ├── security/                  # [Round 2]
  │   │   │   └── root_detector.dart     # Root/jailbreak detection wrapper
  │   │   ├── storage/                   # [Round 2]
  │   │   │   └── secure_local_storage.dart # Supabase LocalStorage via flutter_secure_storage
  │   │   └── services/                  # [Round 2]
  │   │       ├── fcm_service.dart       # FCM token, channels, message handlers
  │   │       ├── geofence_service.dart  # Location permission, check, drift log, Supabase sync
  │   │       ├── biometric_service.dart # local_auth wrapper + SharedPreferences opt-in
  │   │       └── session_timeout_service.dart # 15-min idle session timeout
  │   ├── data/
  │   │   └── models/                    # Data models
  │   ├── routes/
  │   │   ├── app_routes.dart            # Route constants + Round 2 routes
  │   │   └── app_pages.dart             # GetPage routes + AuthGuardMiddleware
  │   └── modules/
  │       ├── auth/                      # Login + biometric opt-in
  │       ├── dashboard/                 # Dashboard + session timeout + drift count
  │       ├── notifications/             # drift cache + Supabase sync
  │       ├── parent_view/
  │       │   ├── profiles/
  │       │   ├── attendance/
  │       │   ├── billing/               # + biometric gate + payments table write
  │       │   └── trial_booking/
  │       └── student_view/
  │           ├── schedule/
  │           ├── study_materials/
  │           ├── assignments/
  │           ├── group_chat/
  │           ├── polls/
  │           └── checkin/               # [Round 2] Geofence check-in module
  │               ├── geofence_disclosure_screen.dart
  │               ├── checkin_controller.dart
  │               └── checkin_screen.dart
```

---

## Setup & Local Development

### 1. Requirements
- Flutter SDK 3.11+
- Dart SDK 3.11+
- Android SDK with minSdk 23+
- Java 17

### 2. Configure Environment Variables
1. Copy `.env.example` to `.env` and fill in your credentials:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-supabase-anon-key
   ICA_VERIFICATION_KEY=ICA-ACTIVE-RUN-8840X
   FORCE_PIN_FAILURE=false   # Set to true to demo certificate pin rejection
   ```

### 3. Firebase Setup
1. Replace `android/app/google-services.json` with your real Firebase file (see FCM setup above)
2. The placeholder file will cause a Gradle build error

### 4. Build & Run
```bash
# Install dependencies
flutter pub get

# Generate drift database code (REQUIRED after first setup)
dart run build_runner build --delete-conflicting-outputs

# Analyze for errors
flutter analyze

# Run on connected device
flutter run

# Build release APK
flutter build apk --release
```

---

## Security Notes

| Feature | Implementation | Note |
|---|---|---|
| Session storage | `flutter_secure_storage` → Android Keystore | Replaces default Hive |
| Screen capture | `FLAG_SECURE` in `MainActivity.kt` | All screens protected |
| Root detection | `flutter_jailbreak_detection` | Blocks in release, logs in debug |
| Session timeout | 15-minute idle timer | Periodic 60s check |
| Cert pinning | SHA-256 via Dio custom adapter | Supplemental calls only |
| Deep-link auth | `AuthGuardMiddleware` on all routes | Rejects unauthenticated navigation |

---

## Geofence Configuration

| Parameter | Value |
|---|---|
| Academy | Parul University, Vadodara |
| Latitude | `22.2678` |
| Longitude | `73.1433` |
| Radius | `200 metres` |
| Location access | `whileInUse` only |
| Log retention | 90 days (purge via Supabase scheduled function) |

---

## Drift Migration History

| Version | Date | Changes |
|---|---|---|
| 1 | 2026-06-26 | Initial schema: CachedSchedules, CachedAttendance, CachedNotifications, GeofenceLogs, CachedPlans |

---

## Local Verification (Seed Testing)
Because email confirmation is enabled on this Supabase project, signing up with new emails requires verification. For seamless testing against seed data:
1. Log in as **`admin@ica.com`** with password **`AdminChess123!`**
2. You will immediately load into the parent panel as Rajesh Kumar, with seeded children **Aarav Kumar** and **Rohan Kumar**
