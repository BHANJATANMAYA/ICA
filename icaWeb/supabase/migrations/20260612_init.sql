-- supabase/migrations/20260612_init.sql

-- Enable Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Clean schema (optional, since this is initial migration)
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.trial_requests CASCADE;
DROP TABLE IF EXISTS public.subscriptions CASCADE;
DROP TABLE IF EXISTS public.plans CASCADE;
DROP TABLE IF EXISTS public.attendance_records CASCADE;
DROP TABLE IF EXISTS public.poll_votes CASCADE;
DROP TABLE IF EXISTS public.poll_options CASCADE;
DROP TABLE IF EXISTS public.polls CASCADE;
DROP TABLE IF EXISTS public.group_messages CASCADE;
DROP TABLE IF EXISTS public.homework_submissions CASCADE;
DROP TABLE IF EXISTS public.assignments CASCADE;
DROP TABLE IF EXISTS public.study_materials CASCADE;
DROP TABLE IF EXISTS public.schedules CASCADE;
DROP TABLE IF EXISTS public.students CASCADE;
DROP TABLE IF EXISTS public.parents CASCADE;
DROP TABLE IF EXISTS public.admins CASCADE;
DROP TABLE IF EXISTS public.batches CASCADE;

-- 1. Batches Table
CREATE TABLE public.batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    default_timing TEXT, -- e.g. "Mon/Wed 5:00 PM - 6:00 PM"
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Admins Table
CREATE TABLE public.admins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID NOT NULL UNIQUE, -- Links to auth.users
    name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'staff', -- 'super_admin' or 'staff'
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Parents Table
CREATE TABLE public.parents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID UNIQUE, -- Nullable initially; linked when parent signs up via mobile
    name TEXT NOT NULL,
    phone TEXT,
    email TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Students Table
CREATE TABLE public.students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    chess_rating INTEGER DEFAULT 1000,
    level TEXT NOT NULL DEFAULT 'Beginner', -- 'Beginner', 'Intermediate', 'Advanced'
    platform_id TEXT, -- e.g. Lichess/Chess.com username
    parent_id UUID REFERENCES public.parents(id) ON DELETE SET NULL,
    batch_id UUID REFERENCES public.batches(id) ON DELETE SET NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Schedules Table (Core REALTIME Table)
CREATE TABLE public.schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    class_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled', -- 'scheduled', 'completed', 'cancelled'
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 6. Study Materials Table
CREATE TABLE public.study_materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    file_url TEXT, -- If uploaded to Supabase Storage
    link_url TEXT, -- If external link (e.g. Lichess study)
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 7. Assignments Table
CREATE TABLE public.assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 8. Homework Submissions Table
CREATE TABLE public.homework_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID NOT NULL REFERENCES public.assignments(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    drive_link TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending', -- 'pending', 'submitted', 'reviewed'
    submitted_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (assignment_id, student_id)
);

-- 9. Group Messages Table (REALTIME Table)
CREATE TABLE public.group_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL, -- references admins.id, parents.id or students.id
    sender_name TEXT NOT NULL, -- Cached for rendering simplicity
    sender_type TEXT NOT NULL, -- 'admin', 'parent', 'student'
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 10. Polls Table
CREATE TABLE public.polls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 11. Poll Options Table
CREATE TABLE public.poll_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    poll_id UUID NOT NULL REFERENCES public.polls(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL
);

-- 12. Poll Votes Table (REALTIME Table)
CREATE TABLE public.poll_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    poll_id UUID NOT NULL REFERENCES public.polls(id) ON DELETE CASCADE,
    option_id UUID NOT NULL REFERENCES public.poll_options(id) ON DELETE CASCADE,
    voter_id UUID NOT NULL, -- associated parent_id or student_id
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (poll_id, voter_id)
);

-- 13. Attendance Records Table
CREATE TABLE public.attendance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    class_date DATE NOT NULL,
    status TEXT NOT NULL, -- 'present', 'absent'
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (student_id, batch_id, class_date)
);

-- 14. Plans Table
CREATE TABLE public.plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    duration_type TEXT NOT NULL, -- 'monthly', 'quarterly', 'annual'
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 15. Subscriptions Table
CREATE TABLE public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    plan_id UUID NOT NULL REFERENCES public.plans(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'overdue', 'expired'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 16. Trial Requests Table
CREATE TABLE public.trial_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    contact_phone TEXT,
    contact_email TEXT,
    preferred_batch_id UUID REFERENCES public.batches(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'new', -- 'new', 'contacted', 'scheduled', 'closed'
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 17. Notifications Table
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_parent_id UUID NOT NULL REFERENCES public.parents(id) ON DELETE CASCADE,
    type TEXT NOT NULL, -- e.g. 'alert', 'billing', 'submission'
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS) & HELPERS
-- ==========================================

-- Helper function to check if the current user is an Admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.admins 
    WHERE auth_user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to get the current user's Parent ID
CREATE OR REPLACE FUNCTION public.get_parent_id()
RETURNS UUID AS $$
BEGIN
  RETURN (
    SELECT id FROM public.parents 
    WHERE auth_user_id = auth.uid()
    LIMIT 1
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable RLS on all tables
ALTER TABLE public.batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.study_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.homework_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.poll_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.poll_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trial_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- ------------------------------------------
-- Admin RLS Policies (Full Read/Write Access)
-- ------------------------------------------
CREATE POLICY "Admins have full access to batches" ON public.batches FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
-- Recursion-free policies for admins table to prevent infinite loops
CREATE POLICY "Allow public read access to admins" ON public.admins FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "Admins can manage their own profile" ON public.admins FOR ALL TO authenticated USING (auth_user_id = auth.uid()) WITH CHECK (auth_user_id = auth.uid());
CREATE POLICY "Admins have full access to parents" ON public.parents FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to students" ON public.students FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to schedules" ON public.schedules FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to study_materials" ON public.study_materials FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to assignments" ON public.assignments FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to homework_submissions" ON public.homework_submissions FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to group_messages" ON public.group_messages FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to polls" ON public.polls FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to poll_options" ON public.poll_options FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to poll_votes" ON public.poll_votes FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to attendance_records" ON public.attendance_records FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to plans" ON public.plans FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to subscriptions" ON public.subscriptions FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to trial_requests" ON public.trial_requests FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Admins have full access to notifications" ON public.notifications FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "Allow public inserts to trial_requests" ON public.trial_requests FOR INSERT TO authenticated, anon WITH CHECK (true);

-- ------------------------------------------
-- Commented Placeholder Policies for Parent Access (Mobile App)
-- ------------------------------------------
/*
-- 1. Parents can read and update their own profile
CREATE POLICY "Parents read/update own profile" ON public.parents
  FOR ALL TO authenticated
  USING (auth_user_id = auth.uid())
  WITH CHECK (auth_user_id = auth.uid());

-- 2. Parents can read their own students
CREATE POLICY "Parents read own students" ON public.students
  FOR SELECT TO authenticated
  USING (parent_id = public.get_parent_id() AND is_deleted = false);

-- 3. Parents can read schedules for batches their students belong to
CREATE POLICY "Parents read student schedules" ON public.schedules
  FOR SELECT TO authenticated
  USING (batch_id IN (
    SELECT batch_id FROM public.students 
    WHERE parent_id = public.get_parent_id() AND is_deleted = false
  ));

-- 4. Parents can read study materials for batches their students belong to
CREATE POLICY "Parents read student study materials" ON public.study_materials
  FOR SELECT TO authenticated
  USING (batch_id IN (
    SELECT batch_id FROM public.students 
    WHERE parent_id = public.get_parent_id() AND is_deleted = false
  ));

-- 5. Parents can read assignments for batches their students belong to
CREATE POLICY "Parents read student assignments" ON public.assignments
  FOR SELECT TO authenticated
  USING (batch_id IN (
    SELECT batch_id FROM public.students 
    WHERE parent_id = public.get_parent_id() AND is_deleted = false
  ));

-- 6. Parents can submit/update homework submissions for their students
CREATE POLICY "Parents submit homework for students" ON public.homework_submissions
  FOR ALL TO authenticated
  USING (student_id IN (
    SELECT id FROM public.students 
    WHERE parent_id = public.get_parent_id() AND is_deleted = false
  ))
  WITH CHECK (student_id IN (
    SELECT id FROM public.students 
    WHERE parent_id = public.get_parent_id() AND is_deleted = false
  ));

-- 7. Parents can read/send messages in group chat of their students' batches
CREATE POLICY "Parents participate in student group chat" ON public.group_messages
  FOR ALL TO authenticated
  USING (batch_id IN (
    SELECT batch_id FROM public.students 
    WHERE parent_id = public.get_parent_id() AND is_deleted = false
  ))
  WITH CHECK (
    batch_id IN (
      SELECT batch_id FROM public.students 
      WHERE parent_id = public.get_parent_id() AND is_deleted = false
    )
    AND sender_id = public.get_parent_id()
    AND sender_type = 'parent'
  );

-- 8. Parents can read polls and options for their students' batches
CREATE POLICY "Parents read polls" ON public.polls
  FOR SELECT TO authenticated
  USING (batch_id IN (
    SELECT batch_id FROM public.students 
    WHERE parent_id = public.get_parent_id() AND is_deleted = false
  ));

CREATE POLICY "Parents read poll options" ON public.poll_options
  FOR SELECT TO authenticated
  USING (poll_id IN (
    SELECT id FROM public.polls 
    WHERE batch_id IN (
      SELECT batch_id FROM public.students 
      WHERE parent_id = public.get_parent_id() AND is_deleted = false
    )
  ));

-- 9. Parents can vote in polls
CREATE POLICY "Parents vote in polls" ON public.poll_votes
  FOR ALL TO authenticated
  USING (voter_id = public.get_parent_id())
  WITH CHECK (voter_id = public.get_parent_id());

-- 10. Parents can read attendance records for their students
CREATE POLICY "Parents read student attendance" ON public.attendance_records
  FOR SELECT TO authenticated
  USING (student_id IN (
    SELECT id FROM public.students 
    WHERE parent_id = public.get_parent_id() AND is_deleted = false
  ));

-- 11. Parents can read subscriptions for their students
CREATE POLICY "Parents read student subscriptions" ON public.subscriptions
  FOR SELECT TO authenticated
  USING (student_id IN (
    SELECT id FROM public.students 
    WHERE parent_id = public.get_parent_id() AND is_deleted = false
  ));

-- 12. Parents can read their notifications
CREATE POLICY "Parents read own notifications" ON public.notifications
  FOR SELECT TO authenticated
  USING (target_parent_id = public.get_parent_id());
*/

-- ==========================================
-- REALTIME ENABLEMENT
-- ==========================================

-- Enable Realtime by adding tables to supabase_realtime publication
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;
END $$;

-- Safely add tables to publication if not already present
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_rel pr
    JOIN pg_class c ON pr.prrelid = c.oid
    JOIN pg_publication p ON pr.prpubid = p.oid
    WHERE p.pubname = 'supabase_realtime' AND c.relname = 'schedules'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.schedules;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_rel pr
    JOIN pg_class c ON pr.prrelid = c.oid
    JOIN pg_publication p ON pr.prpubid = p.oid
    WHERE p.pubname = 'supabase_realtime' AND c.relname = 'group_messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.group_messages;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_rel pr
    JOIN pg_class c ON pr.prrelid = c.oid
    JOIN pg_publication p ON pr.prpubid = p.oid
    WHERE p.pubname = 'supabase_realtime' AND c.relname = 'poll_votes'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.poll_votes;
  END IF;
END $$;

