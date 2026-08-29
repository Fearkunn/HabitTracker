//
//  HabitTrackerTests.swift
//  HabitTrackerTests
//
//  Created by Richie Daryl Kwenandar on 28/08/26.
//

import Foundation
import SwiftData
import Testing
@testable import HabitTracker

@MainActor
struct HabitStreakTests {

    // MARK: - Properties

    private let viewModel: HabitViewModel
    private let calendar = Calendar.current

    // MARK: - Initializers

    init() throws {
        let container = try ModelContainer(
            for: Habit.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        viewModel = HabitViewModel(modelContext: container.mainContext)
    }

    // MARK: - Tests

    @Test("A habit with no completions has no streak")
    func streakWithoutCompletions() {
        let habit = Habit(name: "Read 10 pages")

        #expect(viewModel.currentStreak(for: habit) == 0)
    }

    @Test("Completing only today is a streak of one")
    func streakCompletedTodayOnly() {
        let habit = Habit(name: "Stretch", completedDates: [day(0)])

        #expect(viewModel.currentStreak(for: habit) == 1)
    }

    @Test("Completing only yesterday is still a live streak of one")
    func streakCompletedYesterdayOnly() {
        let habit = Habit(name: "Stretch", completedDates: [day(1)])

        #expect(viewModel.currentStreak(for: habit) == 1)
    }

    @Test("Consecutive days ending today count in full")
    func streakEndingToday() {
        let habit = Habit(name: "Drink water", completedDates: (0..<5).map(day))

        #expect(viewModel.currentStreak(for: habit) == 5)
    }

    @Test("A run that ended more than a day ago is broken")
    func streakBrokenByAGap() {
        let habit = Habit(name: "Call family", completedDates: (4..<9).map(day))

        #expect(viewModel.currentStreak(for: habit) == 0)
    }

    @Test("Only the days since the most recent gap count")
    func streakCountsMostRecentRunOnly() {
        // Today and yesterday, then a gap at two days ago, then an older run.
        let completedDates = [0, 1, 3, 4, 5].map(day)
        let habit = Habit(name: "Meditate", completedDates: completedDates)

        #expect(viewModel.currentStreak(for: habit) == 2)
    }

    @Test("Two completions on the same day count as one day")
    func streakIgnoresDuplicateDays() {
        let habit = Habit(
            name: "Walk",
            completedDates: [day(0), day(0).addingTimeInterval(60), day(1)]
        )

        #expect(viewModel.currentStreak(for: habit) == 2)
    }

    @Test("Habits with different histories each report their own streak")
    func streaksAreIndependentAcrossHabits() {
        let habits = [
            Habit(name: "Drink water", completedDates: (0..<5).map(day)),
            Habit(name: "Stretch", completedDates: [day(1)]),
            Habit(name: "Read 10 pages"),
            Habit(name: "Call family", completedDates: (4..<9).map(day))
        ]

        let streaks = habits.map(viewModel.currentStreak(for:))

        #expect(streaks == [5, 1, 0, 0])
    }

    // MARK: - Private Methods

    /// Start of the day `daysAgo` days before today.
    private func day(_ daysAgo: Int) -> Date {
        let startOfToday = calendar.startOfDay(for: .now)
        return calendar.date(byAdding: .day, value: -daysAgo, to: startOfToday) ?? startOfToday
    }
}
