-- supabase/migrations/20260701_checkin_policies.sql

-- 1. Add INSERT/UPDATE policies for parents on public.attendance_records
CREATE POLICY "Parents insert student attendance" ON public.attendance_records
  FOR INSERT TO authenticated
  WITH CHECK (
    student_id IN (
      SELECT id FROM public.students 
      WHERE parent_id = public.get_parent_id() AND is_deleted = false
    )
  );

CREATE POLICY "Parents update student attendance" ON public.attendance_records
  FOR UPDATE TO authenticated
  USING (
    student_id IN (
      SELECT id FROM public.students 
      WHERE parent_id = public.get_parent_id() AND is_deleted = false
    )
  )
  WITH CHECK (
    student_id IN (
      SELECT id FROM public.students 
      WHERE parent_id = public.get_parent_id() AND is_deleted = false
    )
  );

-- 2. Add INSERT policy for parents on public.geofence_logs
CREATE POLICY "Allow parent insert geofence_logs" ON public.geofence_logs
  FOR INSERT TO authenticated
  WITH CHECK (
    student_id IN (
      SELECT id FROM public.students 
      WHERE parent_id = public.get_parent_id() AND is_deleted = false
    )
  );
