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

    /// Whether the habit has been marked done for the current day.
    var isDoneToday: Bool

    /// When the habit was first created.
    var createdAt: Date

    // MARK: - Initializers

    init(
        id: UUID = UUID(),
        name: String,
        frequency: String = Habit.defaultFrequency,
        isDoneToday: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.isDoneToday = isDoneToday
        self.createdAt = createdAt
    }
}
