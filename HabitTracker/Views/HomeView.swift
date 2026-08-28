//
//  HomeView.swift
//  HabitTracker
//
//  Created by Richie Daryl Kwenandar on 28/08/26.
//

import SwiftData
import SwiftUI

/// Lists every habit and lets the user mark each one done for today.
struct HomeView: View {

    // MARK: - Properties

    @Environment(HabitViewModel.self) private var viewModel

    @Query(sort: \Habit.createdAt, order: .forward) private var habits: [Habit]

    @State private var activeError: HabitError?

    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    emptyState
                } else {
                    habitList
                }
            }
            .navigationTitle("Habits")
            .alert(isPresented: isShowingError, error: activeError) { _ in
                Button("OK", role: .cancel) { activeError = nil }
            } message: { error in
                if let failureReason = error.failureReason {
                    Text(failureReason)
                }
            }
        }
    }

    // MARK: - Subviews

    private var habitList: some View {
        List(habits) { habit in
            habitRow(for: habit)
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Habits Yet", systemImage: "checklist")
        } description: {
            Text("Habits you add will show up here.")
        }
    }

    private func habitRow(for habit: Habit) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .strikethrough(habit.isDoneToday, color: .secondary)
                    .foregroundStyle(habit.isDoneToday ? .secondary : .primary)

                Text(habit.frequency)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Button {
                toggleDone(habit)
            } label: {
                Image(systemName: habit.isDoneToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.isDoneToday ? Color.accentColor : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(Text("Done today"))
            .accessibilityValue(habit.isDoneToday ? Text("Done") : Text("Not done"))
        }
        .padding(.vertical, 4)
        .animation(.default, value: habit.isDoneToday)
    }

    // MARK: - Private Properties

    /// Drives the error alert from `activeError`, clearing it on dismissal.
    private var isShowingError: Binding<Bool> {
        Binding(
            get: { activeError != nil },
            set: { isShowing in
                if !isShowing { activeError = nil }
            }
        )
    }

    // MARK: - Private Methods

    private func toggleDone(_ habit: Habit) {
        do {
            try viewModel.toggleDone(habit)
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

    let sampleHabits = [
        Habit(name: "Drink water", isDoneToday: true),
        Habit(name: "Read 10 pages"),
        Habit(name: "Call family", frequency: "Weekly")
    ]
    for habit in sampleHabits {
        container.mainContext.insert(habit)
    }

    return HomeView()
        .modelContainer(container)
        .environment(HabitViewModel(modelContext: container.mainContext))
}

#Preview("Empty") {
    // Force-try is safe here: this builds an in-memory store for a fixed schema
    // and only ever runs inside Xcode previews.
    let container = try! ModelContainer(
        for: Habit.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    return HomeView()
        .modelContainer(container)
        .environment(HabitViewModel(modelContext: container.mainContext))
}
