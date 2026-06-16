# Indian Chess Academy (ICA) — Parent & Student Flutter Application

This is the mobile application for the **Indian Chess Academy (ICA)**, designed for parents and students to manage classes, view materials, submit homework, book trials, chat, and participate in polls. It interfaces directly with the same Supabase database as the **ICA Admin Web Panel**.

---

## Features Built
1. **Authentication**: Email/Password Sign Up and Log In.
2. **Dashboard Shell**: Unified header context switcher, notification bell badge, and bottom navigation.
3. **Schedules**: Live class calendar listings (Parent sees all children's schedules, Student sees their active batch).
4. **Student View**:
   - *Study Materials*: Worksheets and Lichess study link launcher.
   - *Assignments*: Google Drive link homework submission with validation regex.
   - *Group Chat*: Real-time cohort chat timeline.
   - *Polls*: Interactive voting and live-updated vote percentage charts.
5. **Parent View**:
   - *Profiles*: Multi-profile management (list, add, edit, soft-delete).
   - *Attendance Ledger*: Attendance rate rollup metrics and expanded history logs.
   - *Billing & Checkout*: Razorpay Sandbox Simulator sheets writing subscriptions on confirmation.
   - *Trial Booking*: Demo registration form.

---

## Directory Structure (GetX Architecture)

```
/lib
  ├── main.dart                      # App entry, environment loading, error boundary configs
  ├── app/
  │   ├── core/
  │   │   ├── theme/
  │   │   │   ├── colors.dart        # Brand hex colors
  │   │   │   └── typography.dart    # Brand typography sizes
  │   │   └── supabase/
  │   │       └── supabase_client.dart # Supabase initializations
  │   ├── data/
  │   │   └── models/                # Student, Batch, Schedule, Assignment, etc. data models
  │   ├── routes/
  │   │   ├── app_routes.dart        # Route path constants
  │   │   └── app_pages.dart         # GetX page route builders and bindings mapping
  │   └── modules/
  │       ├── auth/                  # Login/Signup screen and controllers
  │       ├── dashboard/             # Dashboard shell and context switchers
  │       ├── notifications/         # Realtime notifications listing
  │       ├── parent_view/
  │       │   ├── profiles/          # Student profile card managers
  │       │   ├── attendance/        # Attendance roller ledger
  │       │   ├── billing/           # Plans and Razorpay Checkout simulators
  │       │   └── trial_booking/     # Demo request forms
  │       └── student_view/
  │           ├── schedule/          # Sync schedules list
  │           ├── study_materials/   # PDFs and chess study lists
  │           ├── assignments/       # Homework submissions
  │           ├── group_chat/        # Realtime batch chats
  │           └── polls/             # Live polling results
```

---

## Setup & Local Development

### 1. Requirements
- Flutter SDK (Channel stable)
- Dart SDK

### 2. Configure Environment Variables
1. Ensure there is a `.env` file at the root of the project (`/x/X/ICA/icaApp/.env`).
2. Populate the `.env` file with your Supabase credentials:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-supabase-anon-key
   ```

### 3. Install Packages & Run
```bash
# Get dependencies
flutter pub get

# Run code analysis (Zero warnings check)
flutter analyze

# Run on your desktop, browser, or connected device
flutter run
```

---

## How Realtime Syncing is Wired
We make extensive use of Supabase's PostgreSQL Realtime subscriptions (`realtime` channels) in GetX Controllers:
- **Class Schedules**: `ScheduleController` subscribes to change events on the `schedules` table globally, calling `fetchSchedules()` to reload the list with correct joined batch names when schedules are updated on the admin web panel.
- **Group Chat**: `GroupChatController` listens to postgres `INSERT` events on `group_messages` filtered by the active student's `batch_id`. New messages are appended to the list instantly.
- **Poll Votes**: `PollsController` listens to postgres changes on `poll_votes`. Whenever a vote is recorded, it re-queries the votes for active polls and recalculates the progress percentages.
- **Notifications**: `DashboardController` listens to postgres change events on the `notifications` table filtered by the parent's `target_parent_id` to increment the unread badge count.

---

## Local Verification (Seed Testing)
Because email confirmation is enabled on this Supabase project, signing up with new emails requires verification. For seamless testing against seed data:
1. We mapped the seeded parent **"Rajesh Kumar"** to the pre-confirmed admin credentials (`admin@ica.com` / `AdminChess123!`).
2. Simply log in as **`admin@ica.com`** with password **`AdminChess123!`**.
3. You will immediately load into the parent panel as Rajesh Kumar, showing his seeded children **Aarav Kumar** and **Rohan Kumar** inside the student view for full feature testing.
