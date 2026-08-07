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

## Current Mobile Flows
1. Firebase initialize
2. Auth state gate
3. Email/password sign-in and registration
4. New user profile setup (`users` doc)
5. Role-based home screen
6. Student note read flow for selected day

## Next Milestones
1. Parent-to-student linking screen and invite flow
2. Weekly program read model (`weekly_programs` collection)
3. Teacher role and write permissions for notes/tasks
4. Push notifications (FCM)
5. Offline cache strategy

## Important
- Generate real Firebase options with `flutterfire configure`.
- Deploy security rules before production.
- Keep role checks both in UI and Firestore rules.
