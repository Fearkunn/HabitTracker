# HabitTracker

A simple iOS app for tracking daily habits, built with SwiftUI and SwiftData.

## About This Project

This is a learning project. Every line of code, every commit, and this
README were written entirely by an AI coding agent (Claude Code), based on
prompts and direction from the project owner. The goal is to explore what
it's like to build and evolve a small iOS app through agent-driven
development, using the conventions and guardrails defined in `CLAUDE.md`.

## Features

- **Home** — list of habits with a "done today" toggle
- **Add/Edit Habit** — form to create a new habit or edit an existing one
- **Habit Detail** — streak and completion history for a single habit,
  with the ability to delete the habit

## Architecture

MVVM, with one ViewModel per model/entity type (not per screen):

- `HabitViewModel` owns all CRUD and business logic for `Habit` — add,
  update, delete, and toggle-done — and is injected into whichever views
  need it.
- ViewModels are `@Observable` classes; there's no `ObservableObject` or
  `@Published`.
- Views read data directly via SwiftData's `@Query`. ViewModels are the
  write/action layer only — they don't hold or expose read state.
- Models are `@Model` (SwiftData) classes: data and relationships only, no
  business logic beyond what SwiftData requires.

## Project Structure

```
HabitTracker/
├── HabitTrackerApp.swift
├── Models/
│   ├── Habit.swift
│   └── HabitError.swift
├── ViewModels/
│   └── HabitViewModel.swift
└── Views/
    ├── HomeView.swift
    ├── AddEditHabitView.swift
    └── HabitDetailView.swift
```

## Requirements

- Xcode with iOS SDK support
- Swift 5.0

## Building

```
xcodebuild -project HabitTracker.xcodeproj -scheme HabitTracker \
  -destination 'generic/platform=iOS Simulator' -configuration Debug \
  CODE_SIGNING_ALLOWED=NO build
```

## Development Guidelines

See `CLAUDE.md` for the full set of architecture rules, naming
conventions, and "do not" constraints this project follows.
