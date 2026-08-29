# Habit Tracker — Project Instructions

Simple iOS app for tracking daily habits, built with SwiftData persistence.
Three screens: Home (list of habits with a "done today" toggle), Add/Edit
Habit (form), Habit Detail (streak/history for one habit).

## Architecture: MVVM, one ViewModel per Model/entity

- One ViewModel per Model/entity type — not per screen. `HabitViewModel`
  owns all CRUD and business logic for `Habit` (add, update, delete,
  toggle-done), and is injected into whichever Views need it (list, add
  form, edit form, detail).
- ViewModels are `@Observable` classes. No `ObservableObject`, no
  `@Published` — plain `var` properties are tracked automatically.
- Views read data via SwiftData's `@Query` directly. ViewModels are the
  write/action layer; they don't hold or expose read state.
- Models are `@Model` classes (SwiftData) — data + relationships only,
  no business logic beyond what SwiftData requires.

## File Structure & Naming

- `Models/Habit.swift`
- `ViewModels/HabitViewModel.swift`
- `Views/HomeView.swift`, `Views/AddEditHabitView.swift`, `Views/HabitDetailView.swift`

Naming: `<Entity>.swift`, `<Entity>ViewModel.swift`, `<Screen>View.swift`

## Do Not

- Do not put networking, persistence, or business logic inside a View
- Do not swallow errors silently — no bare `try?` on save/delete without
  at least logging
- Do not modify `.xcodeproj`/`.pbxproj` structure directly

## Build

Verify changes build cleanly before considering a task done. Run:
xcodebuild -project HabitTracker.xcodeproj -scheme HabitTracker \
  -destination 'generic/platform=iOS Simulator' -configuration Debug \
  CODE_SIGNING_ALLOWED=NO build
Report any errors and fix them before finishing.

## Verification

A clean build is not enough — it does not catch runtime issues like broken 
string formatting or incorrect UI state. After building successfully, also 
describe what you changed from a user's perspective (what should visually 
appear/behave differently) so it can be checked against the running app.
