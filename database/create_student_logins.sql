-- ============================================================
-- Login format:
-- Example:
--   024-402 -> 024402@student.bcc.edu / 024402
-- ============================================================

-- Remove old generic demo student accounts.
delete from public.users
where email in ('student@test.com', 'student@bcc.edu');

-- Create or update one login account for every row in public.students.
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

notify pgrst, 'reload schema';

-- Check the generated student accounts.
select
  full_name,
  student_number,
  email,
  password
from public.users
where role = 'student'
  and email like '%@student.bcc.edu'
order by full_name;
