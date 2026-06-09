# BCC Attendance Monitor

Flutter attendance app backed by Supabase tables.

## Supabase setup

1. Open your Supabase project.
2. Go to SQL Editor > New query.
3. Run `database/schema.sql`.
4. Add your project values to `.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-public-key
```

The schema creates `users`, `students`, and `attendance`. Students added from
the app are saved in the Supabase `students` table.

Student credentials are generated in `database/schema.sql` and listed in
`database/student_credentials.md`.

If the tables already exist and you only need to fix student login accounts,
run `database/create_student_logins.sql` in Supabase SQL Editor.
