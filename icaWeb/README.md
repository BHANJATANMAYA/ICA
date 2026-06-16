# Indian Chess Academy (ICA) — Admin Panel & Supabase Backend

This is the administrator web workspace for the **Indian Chess Academy (ICA)**. It enables academy staff to manage batches, schedule class instances, log student attendance, process billing plans/subscriptions, share worksheets, track homework submissions, communicate via group chats, launch polls, and capture trial requests.

The database runs on **Supabase** (Postgres + Realtime), sharing a single source of truth with the Flutter mobile application (built separately for parents and students).

---

## Technical Stack
- **Framework**: Next.js 14 (App Router, TypeScript)
- **Styling**: Tailwind CSS (customized with Deep Navy `#1A3C5E` and Chess Gold `#C8922A` colors)
- **Icons**: Lucide React
- **ORM / Client**: Supabase JS (Session management, RLS, and Realtime subscriptions)
- **Form Validation**: React Hook Form + Zod

---

## Directory Structure
- `supabase/migrations/`
  - `20260612_init.sql` — Schema definition, RLS triggers, security helper functions, and Realtime publications.
  - `20260612_seed.sql` — Seed script including 1 admin account, 3 batches, 2 parent profiles, 10 student profiles, schedules, plans, subscriptions, and sample trial leads.
- `src/app/` — App Router pages (Login, Dashboard, Students, Attendance, Billing, Materials, Assignments, Chat/Polls, Trials, Errors).
- `src/components/` — Shared structural UI layouts (e.g., Left Navigation Sidebar).
- `src/utils/supabase/` — Browser, Server, and Middleware wrappers.

---

## Setup & Running Locally

### 1. Database Migrations
1. Create a new project in your **Supabase Dashboard**.
2. Go to the **SQL Editor** in your Supabase Console.
3. Paste and run the contents of [supabase/migrations/20260612_init.sql](file:///x:/X/ICA/icaWeb/supabase/migrations/20260612_init.sql) to set up all tables, triggers, helper functions, and RLS policies.
4. Paste and run the contents of [supabase/migrations/20260612_seed.sql](file:///x:/X/ICA/icaWeb/supabase/migrations/20260612_seed.sql) to seed the database.
   * This seeds a default admin account:
     - **Email**: `admin@ica.com`
     - **Password**: `AdminChess123!`

### 2. Configure Environment Variables
1. Rename `.env.example` to `.env.local` in the project root:
   ```bash
   cp .env.example .env.local
   ```
2. Populate the keys with your Supabase credentials:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
   SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key
   ```

### 3. Install Packages & Run
```bash
# Install dependencies
npm install

# Run the development server
npm run dev
```
Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## Mobile App (Flutter) Integration Guide

The Flutter mobile application interfaces with the same Supabase database. Below is the mapping of which tables the mobile app will read from and write into:

### 1. Authentication
- Parents sign up via Supabase Auth.
- Upon signup, the mobile app creates a profile record in the **`parents`** table with their linked `auth_user_id`.

### 2. Read-Only Tables for Mobile (Flutter)
The mobile app reads from these tables to show class information and resources:
- **`students`** — To render the child profiles linked to `parent_id`.
- **`schedules`** — To display the calendar events of batches the student is assigned to.
- **`batches`** — To display cohort information.
- **`study_materials`** — To fetch PDFs or study external Lichess links shared by coaches.
- **`assignments`** — To read homework items.
- **`plans`** — To review billing tiers.
- **`subscriptions`** — To display active subscription end-dates.
- **`notifications`** — To fetch alert broadcasts.

### 3. Read/Write Tables for Mobile (Flutter)
The mobile app writes logs and data into these tables:
- **`homework_submissions`** — Parents/Students submit Google Drive links for assignments.
  - *Writes*: `assignment_id`, `student_id`, `drive_link`, `status` (`'submitted'`), `submitted_at`.
- **`group_messages`** — Parents post messages in the batch chat.
  - *Writes*: `batch_id`, `sender_id` (`parent_id`), `sender_name`, `sender_type` (`'parent'`), `message`.
  - *Reads*: All messages for the batch.
- **`poll_votes`** — Parents vote in polls.
  - *Writes*: `poll_id`, `option_id`, `voter_id` (`parent_id`).

### 4. Realtime Channels for Flutter Sync
To ensure live updates between the web admin panel and the mobile app:
- Listen to **`schedules`** changes on the channel for class rescheduling alerts.
- Listen to **`group_messages`** for active chat rooms.
- Listen to **`poll_votes`** to show live voting results.
