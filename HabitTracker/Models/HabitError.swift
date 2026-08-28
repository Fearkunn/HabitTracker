//
//  HabitError.swift
//  HabitTracker
//
//  Created by Richie Daryl Kwenandar on 28/08/26.
//

import Foundation

/// Errors surfaced by `HabitViewModel` when a habit operation can't be completed.
enum HabitError: LocalizedError {

    /// The habit name was empty or contained only whitespace.
    case emptyName

    /// Writing the habit to the persistent store failed.
    case saveFailed(underlying: any Error)

    /// Removing the habit from the persistent store failed.
    case deleteFailed(underlying: any Error)

    // MARK: - Properties

    var errorDescription: String? {
        switch self {
        case .emptyName:
            String(localized: "Please enter a name for this habit.")
        case .saveFailed:
            String(localized: "Your changes couldn't be saved. Please try again.")
        case .deleteFailed:
            String(localized: "This habit couldn't be deleted. Please try again.")
        }
    }

    var failureReason: String? {
        switch self {
        case .emptyName:
            nil
        case .saveFailed(let underlying), .deleteFailed(let underlying):
            underlying.localizedDescription
        }
    }
}
