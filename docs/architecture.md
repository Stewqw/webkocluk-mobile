# Mobile Foundation Architecture

## Target Roles
- `student`
- `parent`

## Core Collections
- `users/{uid}`
  - `uid: string`
  - `email: string`
  - `displayName: string`
  - `role: "student" | "parent"`
  - `linkedStudentIds: string[]`
  - `createdAt: timestamp`
  - `updatedAt: timestamp`

- `student_program_notes/{studentId}/days/{dayKey}`
  - `dayKey: string` (`pzt`, `sal`, `car`, `per`, `cum`, `cmt`, `paz`)
  - `note: string`
  - `updatedAt: timestamp`

- `student_link_codes/{code}`
  - `studentId: string`
  - `active: bool`
  - `createdAt: timestamp`
  - `expiresAt: timestamp`

## Current Mobile Flows
1. Firebase initialize
2. Auth state gate
3. Email/password sign-in and registration
4. New user profile setup (`users` doc)
5. Role-based home screen
6. Student note read flow for selected day
7. Student link-code generation (7-day validity)
8. Parent code claim and linked-student note view

## Next Milestones
1. Weekly program read model (`weekly_programs` collection)
2. Teacher role and write permissions for notes/tasks
3. Push notifications (FCM)
4. Offline cache strategy

## Important
- Generate real Firebase options with `flutterfire configure`.
- Deploy security rules before production.
- Keep role checks both in UI and Firestore rules.
