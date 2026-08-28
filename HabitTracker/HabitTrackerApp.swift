//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Richie Daryl Kwenandar on 28/08/26.
//

import SwiftData
import SwiftUI

@main
struct HabitTrackerApp: App {

    // MARK: - Properties

    private let modelContainer: ModelContainer
    private let habitViewModel: HabitViewModel

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(modelContainer)
        .environment(habitViewModel)
    }

    // MARK: - Initializers

    init() {
        let schema = Schema([Habit.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContainer = container
            habitViewModel = HabitViewModel(modelContext: container.mainContext)
        } catch {
            // Without a persistent store there is nothing the app can usefully do,
            // so fail loudly at launch rather than running in a broken state.
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
