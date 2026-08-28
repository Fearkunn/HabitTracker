//
//  AddEditHabitView.swift
//  HabitTracker
//
//  Created by Richie Daryl Kwenandar on 28/08/26.
//

import SwiftData
import SwiftUI

/// Form for creating a habit or editing an existing one.
///
/// Edits live in local state until the user taps Save, so dismissing the
/// form leaves the stored habit untouched.
struct AddEditHabitView: View {

    // MARK: - Properties

    @Environment(HabitViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss

    /// The habit being edited, or `nil` when creating a new one.
    private let habit: Habit?

    @State private var name: String
    @State private var frequency: String
    @State private var activeError: HabitError?

    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .focused($isNameFocused)
                        .submitLabel(.next)

                    TextField("Frequency", text: $frequency)
                        .submitLabel(.done)
                } footer: {
                    Text("How often you want to do this, for example Daily or Weekly.")
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                }
            }
            .alert(isPresented: isShowingError, error: activeError) { _ in
                Button("OK", role: .cancel) { activeError = nil }
            } message: { error in
                if let failureReason = error.failureReason {
                    Text(failureReason)
                }
            }
            .onAppear {
                isNameFocused = habit == nil
            }
        }
    }

    // MARK: - Initializers

    /// - Parameter habit: The habit to edit, or `nil` to create a new one.
    init(habit: Habit? = nil) {
        self.habit = habit
        _name = State(initialValue: habit?.name ?? "")
        _frequency = State(initialValue: habit?.frequency ?? Habit.defaultFrequency)
    }

    // MARK: - Private Properties

    private var title: Text {
        habit == nil ? Text("New Habit") : Text("Edit Habit")
    }

    /// Falls back to the default rather than storing a blank frequency.
    /// Only the name is validated; an empty frequency is a reasonable
    /// omission rather than a mistake.
    private var normalizedFrequency: String {
        let trimmedFrequency = frequency.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedFrequency.isEmpty ? Habit.defaultFrequency : trimmedFrequency
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

    // MARK: - Private Methods

    /// Saves through the view model, dismissing only once it succeeds.
    ///
    /// Save stays enabled for an empty name on purpose, so the name check
    /// reported by `HabitViewModel` is what the user sees.
    private func save() {
        do {
            if let habit {
                try viewModel.update(habit, name: name, frequency: normalizedFrequency)
            } else {
                try viewModel.addHabit(name: name, frequency: normalizedFrequency)
            }
            dismiss()
        } catch {
            activeError = error
        }
    }
}

// MARK: - Previews

#Preview("New Habit") {
    // Force-try is safe here: this builds an in-memory store for a fixed schema
    // and only ever runs inside Xcode previews.
    let container = try! ModelContainer(
        for: Habit.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    return AddEditHabitView()
        .modelContainer(container)
        .environment(HabitViewModel(modelContext: container.mainContext))
}

#Preview("Edit Habit") {
    // Force-try is safe here: this builds an in-memory store for a fixed schema
    // and only ever runs inside Xcode previews.
    let container = try! ModelContainer(
        for: Habit.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let habit = Habit(name: "Drink water", frequency: "Daily")
    container.mainContext.insert(habit)

    return AddEditHabitView(habit: habit)
        .modelContainer(container)
        .environment(HabitViewModel(modelContext: container.mainContext))
}
