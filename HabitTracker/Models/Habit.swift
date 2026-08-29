//
//  Habit.swift
//  HabitTracker
//
//  Created by Richie Daryl Kwenandar on 28/08/26.
//

import Foundation
import SwiftData

/// A single habit the user is tracking.
@Model
final class Habit {

    // MARK: - Constants

    /// Frequency applied to a habit when the user hasn't picked one.
    static let defaultFrequency = "Daily"

    // MARK: - Properties

    /// Stable identity for the habit, independent of SwiftData's persistent identifier.
    @Attribute(.unique) var id: UUID

    /// Display name of the habit, e.g. "Drink water".
    var name: String

    /// How often the habit should be performed, e.g. "Daily".
    var frequency: String

    /// When the habit was first created.
    var createdAt: Date

    /// Every moment the habit has been marked done, oldest first.
    ///
    /// At most one entry is recorded per calendar day. This is the single
    /// source of truth for whether the habit is done; see `isDoneToday`.
    var completedDates: [Date]

    /// Whether the habit has been marked done for the current day.
    ///
    /// Derived rather than stored so it rolls over at midnight on its own —
    /// a stored flag would keep reading `true` the day after a completion.
    var isDoneToday: Bool {
        completedDates.contains(where: Calendar.current.isDateInToday)
    }

    // MARK: - Initializers

    init(
        id: UUID = UUID(),
        name: String,
        frequency: String = Habit.defaultFrequency,
        createdAt: Date = .now,
        completedDates: [Date] = []
    ) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.createdAt = createdAt
        self.completedDates = completedDates
    }
}
