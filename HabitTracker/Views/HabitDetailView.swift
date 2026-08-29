//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Richie Daryl Kwenandar on 29/08/26.
//

import SwiftData
import SwiftUI

/// Shows one habit's details and the history of when it was marked done.
struct HabitDetailView: View {

    // MARK: - Properties

    let habit: Habit

    @State private var isEditingHabit = false

    var body: some View {
        List {
            Section {
                LabeledContent("Frequency", value: habit.frequency)
                LabeledContent("Started", value: habit.createdAt.formatted(date: .abbreviated, time: .omitted))
            }

            Section {
                if completions.isEmpty {
                    Text("Not marked done yet.")
                        .foregroundStyle(.secondary)
                } else {
                    // Indexed because two completions could share a `Date`,
                    // which would make the dates themselves unstable as ids.
                    ForEach(Array(completions.enumerated()), id: \.offset) { _, completion in
                        completionRow(for: completion)
                    }
                }
            } header: {
                Text("History")
            } footer: {
                if !completions.isEmpty {
                    Text(completionCountDescription)
                }
            }
        }
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isEditingHabit = true }
            }
        }
        .sheet(isPresented: $isEditingHabit) {
            AddEditHabitView(habit: habit)
        }
    }

    // MARK: - Subviews

    private func completionRow(for completion: Date) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(completion.formatted(date: .complete, time: .omitted))

                Text(completion.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Private Properties

    /// Completions with the most recent first, which is the order the list reads best in.
    private var completions: [Date] {
        habit.completedDates.sorted(by: >)
    }

    /// Spelled out as two strings rather than with `(inflect:)` grammar
    /// agreement, which needs a strings catalog this project doesn't have and
    /// would otherwise render its own markup to the user.
    private var completionCountDescription: String {
        if completions.count == 1 {
            String(
                localized: "1 completion recorded.",
                comment: "Footer shown when a habit has been marked done exactly once"
            )
        } else {
            String(
                localized: "\(completions.count) completions recorded.",
                comment: "Footer summarising how many times a habit has been marked done"
            )
        }
    }
}

// MARK: - Previews

#Preview {
    // Force-try is safe here: this builds an in-memory store for a fixed schema
    // and only ever runs inside Xcode previews.
    let container = try! ModelContainer(
        for: Habit.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let calendar = Calendar.current
    let habit = Habit(
        name: "Drink water",
        completedDates: (0..<5).compactMap { daysAgo in
            calendar.date(byAdding: .day, value: -daysAgo, to: .now)
        }
    )
    container.mainContext.insert(habit)

    return NavigationStack {
        HabitDetailView(habit: habit)
    }
    .modelContainer(container)
    .environment(HabitViewModel(modelContext: container.mainContext))
}

#Preview("No History") {
    // Force-try is safe here: this builds an in-memory store for a fixed schema
    // and only ever runs inside Xcode previews.
    let container = try! ModelContainer(
        for: Habit.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let habit = Habit(name: "Read 10 pages", frequency: "Weekly")
    container.mainContext.insert(habit)

    return NavigationStack {
        HabitDetailView(habit: habit)
    }
    .modelContainer(container)
    .environment(HabitViewModel(modelContext: container.mainContext))
}
