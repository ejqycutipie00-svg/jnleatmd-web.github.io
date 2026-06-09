-- ============================================================
-- BCC STUDENT ATTENDANCE MONITOR - SUPABASE SCHEMA
-- Run in Supabase Dashboard > SQL Editor > New query > Run.
-- ============================================================

create extension if not exists pgcrypto;


-- Users table for teacher/student login.
create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  password text not null,
  full_name text not null,
  role text not null check (role in ('teacher', 'student')),
  student_number text,
  created_at timestamptz not null default now()
);

-- Students table used by lib/models/student.dart and SupabaseDataService.
create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  student_number text not null unique,
  full_name text not null,
  course text not null default 'BSIT',
  section text not null default '2G',
  created_at timestamptz not null default now()
);

-- Attendance records table.
create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.students(id) on delete cascade,
  status text not null check (status in ('Present', 'Late', 'Absent', 'Excused')) default 'Present',
  remarks text default '',
  marked_by uuid references public.users(id) on delete set null,
  attendance_date date not null default current_date,
  attendance_time timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create index if not exists students_full_name_idx on public.students (full_name);
create index if not exists students_student_number_idx on public.students (student_number);
create index if not exists attendance_student_id_idx on public.attendance (student_id);
create index if not exists attendance_time_idx on public.attendance (attendance_time desc);

-- Keep this classroom project writable from the Flutter app's anon key.
alter table public.users disable row level security;
alter table public.students disable row level security;
alter table public.attendance disable row level security;

grant usage on schema public to anon, authenticated;
grant all privileges on public.users to anon, authenticated;
grant all privileges on public.students to anon, authenticated;
grant all privileges on public.attendance to anon, authenticated;
grant usage, select on all sequences in schema public to anon, authenticated;
grant execute on all functions in schema public to anon, authenticated;
alter default privileges in schema public grant all on tables to anon, authenticated;
alter default privileges in schema public grant usage, select on sequences to anon, authenticated;

-- If RLS is enabled later, these policies still allow the current app to save data.
drop policy if exists anon_users_all on public.users;
drop policy if exists anon_students_all on public.students;
drop policy if exists anon_attendance_all on public.attendance;
create policy anon_users_all on public.users
  for all to anon, authenticated
  using (true)
  with check (true);
create policy anon_students_all on public.students
  for all to anon, authenticated
  using (true)
  with check (true);
create policy anon_attendance_all on public.attendance
  for all to anon, authenticated
  using (true)
  with check (true);


insert into public.users (email, password, full_name, role, student_number) values
('teacher@test.com', 'teacher123', 'BCC Teacher', 'teacher', null),
('teacher@bcc.edu', 'teacher123', 'BCC Teacher', 'teacher', null)
on conflict (email) do update set
  password = excluded.password,
  full_name = excluded.full_name,
  role = excluded.role,
  student_number = excluded.student_number;


where email in ('student@test.com', 'student@bcc.edu');


insert into public.students (student_number, full_name, course, section) values
('024-1059', 'Glenn Henry A. De Guzman', 'BSIT', '2G'),
('024-402', 'Kathleen R. Paragas', 'BSIT', '2G'),
('024-1054', 'Liezel R. Quintas', 'BSIT', '2G'),
('024-1049', 'John Lloyd B. Mangande', 'BSIT', '2G'),
('023-1839', 'John Kenneth Tamayo', 'BSIT', '2G'),
('024-367', 'Ran Michael T. Aganad', 'BSIT', '2G'),
('024-1041', 'Kathlyn Clier B. De Guzman', 'BSIT', '2G'),
('024-408', 'Jerika De Guzman', 'BSIT', '2G'),
('023-121', 'Jayrald Nava Lumilang', 'BSIT', '2G'),
('024-1038', 'Marjorie D. Tamondong', 'BSIT', '2G'),
('024-411', 'Rich Anne De Guzman', 'BSIT', '2G'),
('024-410', 'Oliver Magandi', 'BSIT', '2G'),
('024-405', 'Eugene M. Doldol', 'BSIT', '2G'),
('024-368', 'Gelyn D. Pinlac', 'BSIT', '2G'),
('024-369', 'Ashley Ira S. Marcial', 'BSIT', '2G'),
('024-1048', 'Khiel P. Resuello', 'BSIT', '2G'),
('024-1624', 'Abegail D. Mislang', 'BSIT', '2G'),
('024-1354', 'James B. Delos Santos', 'BSIT', '2G'),
('024-370', 'Joel S. Jose', 'BSIT', '2G'),
('024-374', 'Revin Kyle V. Domantay', 'BSIT', '2G'),
('024-375', 'Maricel T. De Guzman', 'BSIT', '2G'),
('024-371', 'Dennis C. Garcia', 'BSIT', '2G'),
('024-373', 'Ma. Honey Gerica R. De Vera', 'BSIT', '2G'),
('024-351', 'Regine T. Panganiban', 'BSIT', '2G'),
('024-1062', 'Jenniel A. Bajamundi', 'BSIT', '2G'),
('024-1052', 'Christine S. Chua', 'BSIT', '2G'),
('024-353', 'Bernadeth P. Dela Cruz', 'BSIT', '2G'),
('024-1342', 'Jasmin F. Ferrer', 'BSIT', '2G'),
('024-350', 'Jasmine D. Almado', 'BSIT', '2G'),
('023-1840', 'Mark Daniel Ramos', 'BSIT', '2G'),
('024-366', 'Justin Bravo', 'BSIT', '2G'),
('024-1040', 'Eva Lucille Macaraeg', 'BSIT', '2G'),
('024-382', 'Krisly Valencia', 'BSIT', '2G'),
('024-1043', 'Oliver Lopez', 'BSIT', '2G'),
('024-397', 'Mecca-ella De Vera', 'BSIT', '2G'),
('024-1332', 'Jennilyn I. Torio', 'BSIT', '2G'),
('024-1044', 'Nicole R. Delos Santos', 'BSIT', '2G'),
('024-352', 'Cristine D. De Guzman', 'BSIT', '2G'),
('024-1061', 'Shiela Mae Dg. Dangangan', 'BSIT', '2G'),
('024-360', 'Raymart M. Patalod', 'BSIT', '2G'),
('024-379', 'Jovel Glace Cruz', 'BSIT', '2G'),
('024-361', 'Elma Lynn C. Delos Santos', 'BSIT', '2G'),
('024-1612', 'Bobby Cayabyab', 'BSIT', '2G'),
('024-378', 'Nicole Balocating', 'BSIT', '2G'),
('024-390', 'Angelique Rose Balocating', 'BSIT', '2G'),
('024-1047', 'Jazel Tamondong', 'BSIT', '2G'),
('024-391', 'Jonalyn D. Beltran', 'BSIT', '2G'),
('024-395', 'Mikaela D. Reyes', 'BSIT', '2G'),
('024-1055', 'Sandy R. Soriano', 'BSIT', '2G'),
('024-357', 'Gregoria Arenas', 'BSIT', '2G'),
('024-409', 'Ridley Riparip', 'BSIT', '2G'),
('024-407', 'John Romano Castro', 'BSIT', '2G'),
('024-384', 'Karylle Valencia', 'BSIT', '2G'),
('024-356', 'Cathlyn Vicente Germono', 'BSIT', '2G'),
('024-380', 'SOLIS, ROCHELL G.', 'BSIT', '2G'),
('024-363', 'CHUA, JOSHUA D.', 'BSIT', '2G'),
('024-364', 'ROSARIO, DIANA M.', 'BSIT', '2G'),
('024-1060', 'DORIA, MARJORIE F.', 'BSIT', '2G'),
('024-362', 'Salinas, Aslyn S.', 'BSIT', '2G')
on conflict (student_number) do update set
  full_name = excluded.full_name,
  course = excluded.course,
  section = excluded.section;

-- Student login accounts for every student in the students table.
-- email: 0241059@student.bcc.edu
-- password: 0241059
insert into public.users (email, password, full_name, role, student_number)
select
  regexp_replace(lower(student_number), '[^a-z0-9]', '', 'g') || '@student.bcc.edu' as email,
  regexp_replace(lower(student_number), '[^a-z0-9]', '', 'g') as password,
  full_name,
  'student' as role,
  student_number
from public.students
on conflict (email) do update set
  password = excluded.password,
  full_name = excluded.full_name,
  role = excluded.role,
  student_number = excluded.student_number;

-- Reload PostgREST schema cache so Supabase REST sees the tables/grants immediately.
notify pgrst, 'reload schema';

-- Verification query. You should see SETUP OK and the student count.
select 'SETUP OK' as result, count(*) as total_students from public.students;

-- Student credentials generated by this schema.
select
  full_name,
  student_number,
  regexp_replace(lower(student_number), '[^a-z0-9]', '', 'g') || '@student.bcc.edu' as email,
  regexp_replace(lower(student_number), '[^a-z0-9]', '', 'g') as password
from public.students
order by full_name;
