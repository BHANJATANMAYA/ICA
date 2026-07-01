-- supabase/migrations/20260620_round2.sql

-- 1. Add geofence_verified to attendance_records
ALTER TABLE public.attendance_records 
  ADD COLUMN IF NOT EXISTS geofence_verified BOOLEAN DEFAULT false;

-- 2. Extend notifications table
ALTER TABLE public.notifications 
  ADD COLUMN IF NOT EXISTS title TEXT,
  ADD COLUMN IF NOT EXISTS body TEXT,
  ADD COLUMN IF NOT EXISTS read_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS deep_link TEXT;

-- Drop NOT NULL constraint on message since body takes precedence
ALTER TABLE public.notifications ALTER COLUMN message DROP NOT NULL;

-- Trigger to sync message <-> body for backward compatibility
CREATE OR REPLACE FUNCTION public.sync_notification_message_body()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.body IS NULL AND NEW.message IS NOT NULL THEN
    NEW.body := NEW.message;
  ELSIF NEW.message IS NULL AND NEW.body IS NOT NULL THEN
    NEW.message := NEW.body;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_sync_notification_message_body ON public.notifications;
CREATE TRIGGER trigger_sync_notification_message_body
  BEFORE INSERT OR UPDATE ON public.notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_notification_message_body();

-- 3. New: geofence_logs
CREATE TABLE IF NOT EXISTS public.geofence_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES public.students(id) ON DELETE CASCADE,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  accuracy DOUBLE PRECISION,
  event_type TEXT NOT NULL, -- 'enter' | 'exit'
  timestamp TIMESTAMPTZ DEFAULT now()
);

-- 4. New: payments
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES public.students(id) ON DELETE CASCADE,
  plan_id UUID REFERENCES public.plans(id) ON DELETE SET NULL,
  amount NUMERIC NOT NULL,
  status TEXT NOT NULL, -- 'pending' | 'success' | 'failed'
  gateway_ref TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. New: batch_students join table
CREATE TABLE IF NOT EXISTS public.batch_students (
  batch_id UUID REFERENCES public.batches(id) ON DELETE CASCADE,
  student_id UUID REFERENCES public.students(id) ON DELETE CASCADE,
  PRIMARY KEY (batch_id, student_id)
);

-- 6. Add duration_months to plans
ALTER TABLE public.plans 
  ADD COLUMN IF NOT EXISTS duration_months INTEGER;

-- 7. New: fcm_tokens table
CREATE TABLE IF NOT EXISTS public.fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID REFERENCES public.parents(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT, -- 'android' | 'ios'
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 8. New: academy_config table
CREATE TABLE IF NOT EXISTS public.academy_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Insert defaults if config keys do not exist
INSERT INTO public.academy_config (key, value, updated_at) VALUES 
  ('geofence_lat', '22.2678', now()),
  ('geofence_lng', '73.1433', now()),
  ('geofence_radius_meters', '200', now())
ON CONFLICT (key) DO NOTHING;

-- 9. Fix Realtime publications — ADD missing tables
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_rel pr
    JOIN pg_class c ON pr.prrelid = c.oid
    JOIN pg_publication p ON pr.prpubid = p.oid
    WHERE p.pubname = 'supabase_realtime' AND c.relname = 'notifications'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_rel pr
    JOIN pg_class c ON pr.prrelid = c.oid
    JOIN pg_publication p ON pr.prpubid = p.oid
    WHERE p.pubname = 'supabase_realtime' AND c.relname = 'study_materials'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.study_materials;
  END IF;
END $$;

-- 10. Enable RLS + policies on new tables
ALTER TABLE public.geofence_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.batch_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.academy_config ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- academy_config policies
CREATE POLICY "Allow public read on academy_config" ON public.academy_config
  FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow admin write on academy_config" ON public.academy_config
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());

-- batch_students policies
CREATE POLICY "Allow admin all on batch_students" ON public.batch_students
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Allow parent read batch_students" ON public.batch_students
  FOR SELECT TO authenticated USING (
    batch_id IN (
      SELECT batch_id FROM public.students 
      WHERE parent_id = public.get_parent_id() AND is_deleted = false
    )
  );

-- geofence_logs policies
CREATE POLICY "Allow admin all on geofence_logs" ON public.geofence_logs
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Allow parent read geofence_logs" ON public.geofence_logs
  FOR SELECT TO authenticated USING (
    student_id IN (
      SELECT id FROM public.students 
      WHERE parent_id = public.get_parent_id() AND is_deleted = false
    )
  );

-- payments policies
CREATE POLICY "Allow admin all on payments" ON public.payments
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Allow parent read payments" ON public.payments
  FOR SELECT TO authenticated USING (
    student_id IN (
      SELECT id FROM public.students 
      WHERE parent_id = public.get_parent_id() AND is_deleted = false
    )
  );

-- fcm_tokens policies
CREATE POLICY "Allow admin all on fcm_tokens" ON public.fcm_tokens
  FOR ALL TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());
CREATE POLICY "Allow parent all on fcm_tokens" ON public.fcm_tokens
  FOR ALL TO authenticated USING (parent_id = public.get_parent_id()) WITH CHECK (parent_id = public.get_parent_id());
