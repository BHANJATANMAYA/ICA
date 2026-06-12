-- supabase/migrations/20260612_seed.sql

-- 1. Seed Admin User
-- Ensure the crypto extension is active in this schema block
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Seed into auth.users (runs in Supabase Editor)
INSERT INTO auth.users (
  id,
  instance_id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  '00000000-0000-0000-0000-000000000000',
  'authenticated',
  'authenticated',
  'admin@ica.com',
  crypt('AdminChess123!', gen_salt('bf')),
  now(),
  '{"provider":"email","providers":["email"]}',
  '{"name":"ICA Head Coach"}',
  now(),
  now(),
  '',
  '',
  '',
  ''
) ON CONFLICT (id) DO NOTHING;

-- Seed into public.admins
INSERT INTO public.admins (id, auth_user_id, name, role)
VALUES (
  'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
  'ICA Head Coach',
  'super_admin'
) ON CONFLICT (auth_user_id) DO NOTHING;


-- 2. Seed Batches
INSERT INTO public.batches (id, name, description, default_timing) VALUES
('b1111111-1111-1111-1111-111111111111', 'Grandmasters', 'Advanced tactical class focusing on open file concepts, endgame tactics, and tournament preparation.', 'Mon/Wed 6:00 PM - 7:30 PM'),
('b2222222-2222-2222-2222-222222222222', 'Challengers', 'Intermediate class targeting positional play, pawn structures, and basic opening theory.', 'Tue/Thu 5:00 PM - 6:30 PM'),
('b3333333-3333-3333-3333-333333333333', 'Rookies', 'Beginner class covering piece movements, board vision, checkmates, and sportsmanship.', 'Fri/Sat 4:00 PM - 5:00 PM')
ON CONFLICT (id) DO NOTHING;


-- 3. Seed Parents (Using 'd' prefix since it is a valid hex character)
INSERT INTO public.parents (id, auth_user_id, name, phone, email) VALUES
('d1111111-1111-1111-1111-111111111111', null, 'Rajesh Kumar', '+91 9876543210', 'rajesh@gmail.com'),
('d2222222-2222-2222-2222-222222222222', null, 'Priya Sharma', '+91 9988776655', 'priya@gmail.com')
ON CONFLICT (id) DO NOTHING;


-- 4. Seed Students (Using 'e' prefix since it is a valid hex character)
INSERT INTO public.students (id, name, chess_rating, level, platform_id, parent_id, batch_id, is_deleted) VALUES
('e1111111-1111-1111-1111-111111111111', 'Aarav Kumar', 1450, 'Intermediate', 'aarav_chess_master', 'd1111111-1111-1111-1111-111111111111', 'b2222222-2222-2222-2222-222222222222', false),
('e2222222-2222-2222-2222-222222222222', 'Rohan Kumar', 850, 'Beginner', 'rohan_play', 'd1111111-1111-1111-1111-111111111111', 'b3333333-3333-3333-3333-333333333333', false),
('e3333333-3333-3333-3333-333333333333', 'Ananya Sharma', 1820, 'Advanced', 'ananya_genius', 'd2222222-2222-2222-2222-222222222222', 'b1111111-1111-1111-1111-111111111111', false),
('e4444444-4444-4444-4444-444444444444', 'Kabir Mehta', 1210, 'Intermediate', 'kabir_chess', null, 'b2222222-2222-2222-2222-222222222222', false),
('e5555555-5555-5555-5555-555555555555', 'Diya Patel', 720, 'Beginner', 'diya_rook', null, 'b3333333-3333-3333-3333-333333333333', false),
('e6666666-6666-6666-6666-666666666666', 'Ishaan Gupta', 1650, 'Advanced', 'ishaan_check', null, 'b1111111-1111-1111-1111-111111111111', false),
('e7777777-7777-7777-7777-777777777777', 'Meera Iyer', 1340, 'Intermediate', 'meera_knight', null, 'b2222222-2222-2222-2222-222222222222', false),
('e8888888-8888-8888-8888-888888888888', 'Vihaan Nair', 900, 'Beginner', 'vihaan_pawn', null, 'b3333333-3333-3333-3333-333333333333', false),
('e9999999-9999-9999-9999-999999999999', 'Aditya Joshi', 1510, 'Intermediate', 'adi_king', null, 'b2222222-2222-2222-2222-222222222222', false),
('eaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Sai Reddy', 1780, 'Advanced', 'sai_tactics', null, 'b1111111-1111-1111-1111-111111111111', false)
ON CONFLICT (id) DO NOTHING;


-- 5. Seed Schedules (For current week around 2026-06-12)
INSERT INTO public.schedules (id, batch_id, class_date, start_time, end_time, status) VALUES
('c1111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111', '2026-06-10', '18:00:00', '19:30:00', 'completed'),
('c2222222-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', '2026-06-11', '17:00:00', '18:30:00', 'completed'),
('c3333333-3333-3333-3333-333333333333', 'b3333333-3333-3333-3333-333333333333', '2026-06-12', '16:00:00', '17:00:00', 'scheduled'), -- Today
('c4444444-4444-4444-4444-444444444444', 'b1111111-1111-1111-1111-111111111111', '2026-06-15', '18:00:00', '19:30:00', 'scheduled'), -- Next Monday
('c5555555-5555-5555-5555-555555555555', 'b2222222-2222-2222-2222-222222222222', '2026-06-16', '17:00:00', '18:30:00', 'scheduled')
ON CONFLICT (id) DO NOTHING;


-- 6. Seed Plans (Using 'f' prefix since it is a valid hex character)
INSERT INTO public.plans (id, name, price, duration_type, is_active) VALUES
('f1111111-1111-1111-1111-111111111111', 'Monthly Standard', 2000.00, 'monthly', true),
('f2222222-2222-2222-2222-222222222222', 'Quarterly Pro', 5000.00, 'quarterly', true),
('f3333333-3333-3333-3333-333333333333', 'Annual Elite', 18000.00, 'annual', true)
ON CONFLICT (id) DO NOTHING;


-- 7. Seed Subscriptions (Using numeric prefix '0')
INSERT INTO public.subscriptions (id, student_id, plan_id, status, start_date, end_date) VALUES
('01111111-1111-1111-1111-111111111111', 'e1111111-1111-1111-1111-111111111111', 'f2222222-2222-2222-2222-222222222222', 'active', '2026-05-01', '2026-08-01'),
('02222222-2222-2222-2222-222222222222', 'e2222222-2222-2222-2222-222222222222', 'f1111111-1111-1111-1111-111111111111', 'expired', '2026-04-10', '2026-05-10'),
('03333333-3333-3333-3333-333333333333', 'e3333333-3333-3333-3333-333333333333', 'f3333333-3333-3333-3333-333333333333', 'active', '2026-01-01', '2026-12-31'),
('04444444-4444-4444-4444-444444444444', 'e4444444-4444-4444-4444-444444444444', 'f1111111-1111-1111-1111-111111111111', 'overdue', '2026-05-01', '2026-06-01')
ON CONFLICT (id) DO NOTHING;


-- 8. Seed Trial Requests (Using numeric prefix '0')
INSERT INTO public.trial_requests (id, name, contact_phone, contact_email, preferred_batch_id, status) VALUES
('00000000-1111-1111-1111-111111111111', 'Vikram Sen', '+91 9000011111', 'vikram.sen@outlook.com', 'b3333333-3333-3333-3333-333333333333', 'new'),
('00000000-2222-2222-2222-222222222222', 'Karan Johar', '+91 9222233333', 'karan@johar.com', 'b2222222-2222-2222-2222-222222222222', 'contacted'),
('00000000-3333-3333-3333-333333333333', 'Sneha Reddy', '+91 9444455555', 'sneha@reddy.com', 'b1111111-1111-1111-1111-111111111111', 'scheduled')
ON CONFLICT (id) DO NOTHING;


-- 9. Seed Group Messages (Using numeric prefix '1')
INSERT INTO public.group_messages (id, batch_id, sender_id, sender_name, sender_type, message, created_at) VALUES
('10000000-1111-1111-1111-111111111111', 'b2222222-2222-2222-2222-222222222222', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'ICA Head Coach', 'admin', 'Welcome intermediate players! Remember to complete your homework on double attacks.', now() - interval '2 days'),
('10000000-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'd1111111-1111-1111-1111-111111111111', 'Rajesh Kumar', 'parent', 'Sure, Aarav is working on it right now.', now() - interval '1 day')
ON CONFLICT (id) DO NOTHING;
