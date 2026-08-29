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

    @State private var isAddingHabit = false

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
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingHabit = true
                    } label: {
                        Label("Add Habit", systemImage: "plus")
                    }
                }
            }
            .alert(isPresented: isShowingError, error: activeError) { _ in
                Button("OK", role: .cancel) { activeError = nil }
            } message: { error in
                if let failureReason = error.failureReason {
                    Text(failureReason)
                }
            }
            .sheet(isPresented: $isAddingHabit) {
                AddEditHabitView()
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
        } actions: {
            Button("Add Habit") { isAddingHabit = true }
        }
    }

    private func habitRow(for habit: Habit) -> some View {
        HStack(spacing: 12) {
            NavigationLink {
                HabitDetailView(habit: habit)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .strikethrough(habit.isDoneToday, color: .secondary)
                        .foregroundStyle(habit.isDoneToday ? .secondary : .primary)

                    HStack(spacing: 6) {
                        Text(habit.frequency)

                        Text(verbatim: "·")

                        streakLabel(for: habit)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(.rect)
            }
            .accessibilityHint(Text("Opens this habit's details"))

            Button {
                toggleDone(habit)
            } label: {
                Image(systemName: habit.isDoneToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.isDoneToday ? Color.accentColor : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
            }
            // Borderless keeps the toggle's hit area independent of the row's
            // navigation link.
            .buttonStyle(.borderless)
            .accessibilityLabel(Text("Done today"))
            .accessibilityValue(habit.isDoneToday ? Text("Done") : Text("Not done"))
        }
        .padding(.vertical, 4)
        .animation(.default, value: habit.isDoneToday)
    }

    /// Shows the habit's run of consecutive days, or that it doesn't have one.
    ///
    /// A streak carried over from yesterday still counts — it isn't broken
    /// until a whole day is missed — but it's shown unfilled and muted rather
    /// than as the banked orange badge, since today hasn't been secured yet.
    @ViewBuilder
    private func streakLabel(for habit: Habit) -> some View {
        let streak = viewModel.currentStreak(for: habit)

        if streak == 0 {
            Text("No streak")
        } else {
            Label(
                streakDescription(days: streak),
                systemImage: habit.isDoneToday ? "flame.fill" : "flame"
            )
            .foregroundStyle(habit.isDoneToday ? Color.orange : Color.secondary)
            .accessibilityLabel(
                streakAccessibilityDescription(days: streak, isDoneToday: habit.isDoneToday)
            )
        }
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

    /// Spelled out as two strings rather than with `(inflect:)` grammar
    /// agreement, which needs a strings catalog this project doesn't have and
    /// would otherwise render its own markup to the user.
    private func streakDescription(days: Int) -> String {
        if days == 1 {
            String(
                localized: "1 day streak",
                comment: "Streak shown on a habit completed on exactly one day so far"
            )
        } else {
            String(
                localized: "\(days) day streak",
                comment: "Streak shown on a habit completed several days in a row"
            )
        }
    }

    /// Spells out what the unfilled flame conveys visually, which colour and
    /// symbol fill alone don't carry to VoiceOver.
    private func streakAccessibilityDescription(days: Int, isDoneToday: Bool) -> String {
        let streak = streakDescription(days: days)

        return if isDoneToday {
            streak
        } else {
            String(
                localized: "\(streak), not done today",
                comment: "Streak carried over from yesterday that today hasn't extended yet"
            )
        }
    }

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

    let calendar = Calendar.current
    /// Start of the day `daysAgo` days before today.
    func day(_ daysAgo: Int) -> Date {
        let startOfToday = calendar.startOfDay(for: .now)
        return calendar.date(byAdding: .day, value: -daysAgo, to: startOfToday) ?? startOfToday
    }

    // One habit per streak case, so the list shows them side by side.
    let sampleHabits = [
        // Five days running, today included.
        Habit(name: "Drink water", completedDates: (0..<5).map(day)),
        // Yesterday only: still live, and exactly one day long.
        Habit(name: "Stretch", completedDates: [day(1)]),
        // Never completed.
        Habit(name: "Read 10 pages"),
        // A long run that ended four days ago, so the streak is broken.
        Habit(name: "Call family", frequency: "Weekly", completedDates: (4..<9).map(day))
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
