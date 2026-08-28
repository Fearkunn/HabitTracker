//
//  HabitViewModel.swift
//  HabitTracker
//
//  Created by Richie Daryl Kwenandar on 28/08/26.
//

import Foundation
import OSLog
import SwiftData

/// Write/action layer for `Habit`. Views read habits through SwiftData's
/// `@Query`; every mutation goes through this type.
@MainActor
@Observable
final class HabitViewModel {

    // MARK: - Properties

    private let modelContext: ModelContext

    @ObservationIgnored
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "HabitTracker",
        category: "HabitViewModel"
    )

    // MARK: - Initializers

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Methods

    /// Creates a habit and persists it.
    /// - Returns: The newly inserted habit.
    @discardableResult
    func addHabit(
        name: String,
        frequency: String = Habit.defaultFrequency
    ) throws(HabitError) -> Habit {
        let habit = Habit(name: try validatedName(from: name), frequency: frequency)
        modelContext.insert(habit)
        try save { .saveFailed(underlying: $0) }
        return habit
    }

    /// Applies edits to an existing habit and persists them.
    func update(_ habit: Habit, name: String, frequency: String) throws(HabitError) {
        habit.name = try validatedName(from: name)
        habit.frequency = frequency
        try save { .saveFailed(underlying: $0) }
    }

    /// Flips whether the habit is marked done for the current day.
    func toggleDone(_ habit: Habit) throws(HabitError) {
        habit.isDoneToday.toggle()
        try save { .saveFailed(underlying: $0) }
    }

    /// Removes the habit from the store.
    func delete(_ habit: Habit) throws(HabitError) {
        modelContext.delete(habit)
        try save { .deleteFailed(underlying: $0) }
    }

    // MARK: - Private Methods

    /// Trims surrounding whitespace and rejects a name with nothing left in it.
    private func validatedName(from name: String) throws(HabitError) -> String {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { throw .emptyName }
        return trimmedName
    }

    /// Commits pending changes, logging and rethrowing anything the store reports.
    private func save(
        onFailure makeError: (any Error) -> HabitError
    ) throws(HabitError) {
        guard modelContext.hasChanges else { return }

        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save habit changes: \(error.localizedDescription, privacy: .public)")
            throw makeError(error)
        }
    }
}
