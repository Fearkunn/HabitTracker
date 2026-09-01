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

    @Environment(HabitViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    let habit: Habit

    @State private var isEditingHabit = false
    @State private var isConfirmingDelete = false
    @State private var activeError: HabitError?

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

            ToolbarItem(placement: .primaryAction) {
                Button(role: .destructive) {
                    isConfirmingDelete = true
                } label: {
                    Label("Delete Habit", systemImage: "trash")
                }
            }
        }
        .confirmationDialog(
            Text("Delete “\(habit.name)”?"),
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Delete Habit", role: .destructive) { delete() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This habit and its history will be removed. This can't be undone.")
        }
        .alert(isPresented: isShowingError, error: activeError) { _ in
            Button("OK", role: .cancel) { activeError = nil }
        } message: { error in
            if let failureReason = error.failureReason {
                Text(failureReason)
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

    /// Drives the error alert from `activeError`, clearing it on dismissal.
    private var isShowingError: Binding<Bool> {
        Binding(
            get: { activeError != nil },
            set: { isShowing in
                if !isShowing { activeError = nil }
            }
        )
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

    // MARK: - Private Methods

    /// Deletes the habit through the view model and leaves the screen, since
    /// there's no longer a habit for it to show.
    ///
    /// Dismissal happens in the same call as the delete so this view is popped
    /// before SwiftUI can re-render it against a habit that's gone. A failure
    /// leaves the habit in place and surfaces the reason instead.
    private func delete() {
        do {
            try viewModel.delete(habit)
            dismiss()
        } catch {
            activeError = error
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
