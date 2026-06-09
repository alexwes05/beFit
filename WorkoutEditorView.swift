//
//  WorkoutEditorView.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/2/26.
//

import SwiftUI
import SwiftData

// MARK: - WorkoutEditorView
/// Main editor screen for a single WorkoutSplit.
/// Shows all exercises + sets, supports add/delete, and displays
/// per-set and per-exercise progression vs. the previous matching split.
struct WorkoutEditorView: View {

    // The split being edited — @Bindable lets SwiftUI react to property mutations
    @Bindable var split: WorkoutSplit

    // Used to insert/delete SwiftData model objects (exercises, sets)
    @Environment(\.modelContext) private var context

    // Set when the user taps × on an exercise header; drives the confirmation alert
    @State private var exerciseToDelete: Exercise?

    // All splits from SwiftData, newest-first.
    // Passed into progression helpers so they can find the previous session.
    @Query(sort: \WorkoutSplit.date, order: .reverse)
    var allSplits: [WorkoutSplit]

    var body: some View {
        NavigationStack {
            ZStack {

                // ── Background ────────────────────────────────────────────
                Color(red: 240/255, green: 240/255, blue: 255/255)
                    .ignoresSafeArea()

                Image("AppBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.1)

                // ── Main content ──────────────────────────────────────────
                ScrollView {

                    // Date picker: controls which date this session is logged on
                    DatePicker(
                        "Date",
                        selection: $split.date,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .padding(.horizontal)
                    .padding(.top, 60)

                    //GOD BLESS
                    VStack {

                        // FIX: Each exercise is now its own view struct (ExerciseSectionView).
                        // Previously, nesting computed `let` values + two ForEach loops inside
                        // one ForEach body confused SwiftUI's diffing engine, causing set rows
                        // to lose identity and render incorrectly (sets disappearing, duplicates).
                        // Extracting to a named View gives SwiftUI a stable, well-typed boundary
                        // to reconcile on each render.
                        ForEach(split.sortedExercises) { exercise in
                            VStack{
                                ExerciseSectionView(
                                    exercise: exercise,
                                    split: split,
                                    allSplits: allSplits,
                                    onDelete: { exerciseToDelete = exercise }
                                )
                                .id(exercise.persistentModelID)
                            }
                            .padding(.bottom, 16)
                        }

                        // "Add exercise" row always sits at the very bottom of the list
                        Section {
                            AddExerciseRow(split: split)
                                .padding(.bottom, 80)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    //.listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .toolbar {
                // Centred split name in the navigation bar
                ToolbarItem(placement: .principal) {
                    Text(split.name)
                        .font(Font.custom("Pixelify Sans", size: 40))
                        .bold()
                }

                // Duplicate button: deep-copies this split into a new today-dated session
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        duplicateSplit()
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        // Confirmation alert shown when the user taps × on an exercise header.
        // Alert is visible whenever exerciseToDelete is non-nil.
        .alert(
            "Delete Exercise?",
            isPresented: Binding(
                get: { exerciseToDelete != nil },
                set: { if !$0 { exerciseToDelete = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                if let exercise = exerciseToDelete {
                    // Remove from the in-memory relationship array, then hard-delete from SwiftData
                    split.exercises.removeAll { $0.id == exercise.id }
                    context.delete(exercise)

                    // Re-normalise remaining exercise order values after deletion
                    for (i, ex) in split.exercises.sorted(by: { $0.order < $1.order }).enumerated() {
                        ex.order = i + 1
                    }

                    exerciseToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                exerciseToDelete = nil
            }
        } message: {
            if let exercise = exerciseToDelete {
                Text("Delete \(exercise.name)? This will remove all sets.")
            }
        }
    }

    // MARK: - Actions

    /// Deep-copies the current split (same name, today's date) with all exercises
    /// and sets duplicated, then inserts the new split into SwiftData.
    private func duplicateSplit() {
        let newSplit = WorkoutSplit(name: split.name, date: Date())

        // Sort exercises so the duplicated split preserves the original sequence
        for exercise in split.exercises.sorted(by: { $0.order < $1.order }) {
            let newExercise = Exercise(name: exercise.name, order: exercise.order)

            for (index, set) in exercise.sets.enumerated() {
                let newSet = WorkoutSet(
                    reps: set.reps,
                    weight: set.weight,
                    order: index
                )
                newExercise.sets.append(newSet)
            }

            newSplit.exercises.append(newExercise)
        }

        context.insert(newSplit)
    }
}

// MARK: - ExerciseSectionView
/// One List Section for a single exercise.
/// Extracted into its own View so SwiftUI can track its identity independently —
/// this is what fixes the "set disappears / duplicate row" bug that occurred when
/// all section logic lived inside the parent ForEach body.
struct ExerciseSectionView: View {

    // @Bindable so SwiftUI observes changes on this specific exercise
    @Bindable var exercise: Exercise
    let split: WorkoutSplit
    let allSplits: [WorkoutSplit]

    // Called when the user taps the × button; parent handles the alert + deletion
    let onDelete: () -> Void

    var body: some View {
        // Per-set progression vs. the same exercise in the last session
        let setProgressions = compareProgression(
            exerciseName: exercise.name,
            currentSplit: split,
            allSplits: allSplits
        )

        // Sets displayed in user-defined order
        let orderedSets = exercise.sets.sorted { $0.order < $1.order }

        Section {
            VStack{
                ForEach(orderedSets, id: \.uid) { set in
                    let index = orderedSets.firstIndex(where: { $0.persistentModelID == set.persistentModelID }) ?? 0
                    let prog = index < setProgressions.count ? setProgressions[index] : nil
                    SetRow(set: set, progression: prog)
                    Divider()
                }
                .onDelete { indexSet in
                    let sorted = exercise.sets.sorted { $0.order < $1.order }
                    for index in indexSet {
                        let setToDelete = sorted[index]
                        exercise.sets.removeAll { $0.id == setToDelete.id }
                    }
                    for (i, set) in exercise.sets.sorted(by: { $0.order < $1.order }).enumerated() {
                        set.order = i + 1
                    }
                }
            }.background(Color.white, in: RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 0)
            .padding(.vertical, 0)
        }header: {

            // ── Exercise section header ────────────────────────────────
            HStack {
                Text(exercise.name)
                    .font(Font.custom("Pixelify Sans", size: 20))
                    .bold()

                Spacer()

                // Total volume for this exercise (sum of weight × reps)
                Text("Volume: \(exercise.volume.formatted())")
                    .font(.system(size: 14))

                // Exercise-level progression badge (total volume delta vs. last session)
                if let exerciseProg = compareExerciseProgression(
                    exerciseName: exercise.name,
                    currentSplit: split,
                    allSplits: allSplits
                ) {
                    Text(
                        exerciseProg.change >= 0
                        ? "↑+\(Int(exerciseProg.change)) (\(Int(exerciseProg.percent))%)"
                        : "↓\(Int(abs(exerciseProg.change))) (\(Int(exerciseProg.percent))%)"
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(exerciseProg.change >= 0 ? .green : .red)
                }

                // Tapping × triggers the delete-exercise alert in the parent view
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.black)
                }
                .padding(.trailing, 0)
                .buttonStyle(.plain)
            }
            //Divider()
        } footer: {
            VStack {
                //Text("Sets count: \(exercise.sets.count)")
                AddSetRow(exercise: exercise)
            }
        }
        .id(exercise.persistentModelID)   // <--- add this

    }
}

// MARK: - SetRow
/// Displays one set: order number, weight + reps text fields, completion checkbox,
/// and an optional progression indicator vs. the same set index in the previous session.
struct SetRow: View {

    // @Bindable so weight, reps, and isCompleted edits write back to SwiftData
    @Bindable var set: WorkoutSet

    // Progression for this specific set index; nil when there's no prior session to compare
    var progression: SetProgression?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            HStack {
                // 1-based set number
                //Text("\(set.order)")

                // Weight field — decimalPad allows values like 135.5
                TextField("Weight", value: $set.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 70)
                    .textFieldStyle(.roundedBorder)

                Text("x")

                // Reps field — numberPad since reps are always whole numbers
                TextField("Reps", value: $set.reps, format: .number)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)

                Spacer()

                // Completion toggle — fills when tapped, hollow when untapped
                Button {
                    set.isCompleted.toggle()
                } label: {
                    Image(systemName: set.isCompleted ? "checkmark.square.fill" : "square")
                        .foregroundStyle(set.isCompleted ? .blue : .gray)
                }
                .buttonStyle(.plain)
            }

            // ── Per-set progression indicator ─────────────────────────────
            if let progression {
                if progression.isNewSet {
                    // This set index didn't exist in the previous session
                    Text("NEW SET")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                } else {
                    // Volume delta (weight × reps) vs. the same set last session
                    Text(
                        progression.change >= 0
                        ? "↑ +\(Int(progression.change)) (\(Int(progression.percent))%)"
                        : "↓ \(Int(abs(progression.change))) (\(Int(progression.percent))%)"
                    )
                    .font(.caption2)
                    .foregroundStyle(progression.change >= 0 ? .green : .red)
                }
            }
        } .padding(5)
        
    }
}

// MARK: - AddSetRow
/// Inline form at the bottom of an exercise section.
/// Validates that weight and reps are positive before appending a new WorkoutSet.
struct AddSetRow: View {

    @Bindable var exercise: Exercise

    @State private var repsText = ""
    @State private var weightText = ""

    var body: some View {
        HStack {
            // Weight input — decimalPad so users can enter values like 135.5
            TextField("Weight", text: $weightText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)

            Text("x")

            // Reps input — numberPad since reps are whole numbers only
            TextField("Reps", text: $repsText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 90)

            Spacer()

            Button("Add") {
                // Validate: both fields must parse and be positive
                guard
                    let reps = Int(repsText),
                    let weight = Double(weightText),
                    reps > 0,
                    weight > 0
                else { return }

                // Place the new set after the highest existing order value
                let nextOrder = (exercise.sets.map { $0.order }.max() ?? 0) + 1

                let set = WorkoutSet(reps: reps, weight: weight, order: nextOrder)
                exercise.sets.append(set)

                // Reset fields for the next entry
                repsText = ""
                weightText = ""
            }
        }
        .padding(5)
        .background(Color.blue.opacity(0.05), in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - AddExerciseRow
/// Inline form at the bottom of the full list for adding a new exercise to the split.
struct AddExerciseRow: View {

    @Bindable var split: WorkoutSplit
    @State private var name = ""

    var body: some View {
        HStack {
            TextField("New exercise", text: $name)
                .textFieldStyle(.roundedBorder)

            Button("Add") {
                guard !name.isEmpty else { return }

                // Place the new exercise after the highest existing order value
                let nextOrder = (split.exercises.map { $0.order }.max() ?? 0) + 1
                let exercise = Exercise(name: name, order: nextOrder)
                split.exercises.append(exercise)

                name = ""
            }
        }.padding(10)
        .background(Color.white.opacity(1), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Preview
#Preview {
    let container = try! ModelContainer(
        for: WorkoutSplit.self,
        Exercise.self,
        WorkoutSet.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext
    let calendar = Calendar.current

    let today = calendar.startOfDay(for: Date())
    let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

    // Current session (today) — the split the editor opens on
    let push = WorkoutSplit(name: "Push Day", date: today)
    let chest = Exercise(name: "Bench Press", order: 1)
    chest.sets.append(WorkoutSet(reps: 10, weight: 135, order: 1))
    chest.sets.append(WorkoutSet(reps: 8, weight: 155, order: 2))
    let shoulders = Exercise(name: "Shoulder Press", order: 2)
    shoulders.sets.append(WorkoutSet(reps: 10, weight: 95, order: 1))
    shoulders.sets.append(WorkoutSet(reps: 8, weight: 105, order: 2))
    push.exercises.append(chest)
    push.exercises.append(shoulders)
    context.insert(push)

    // Previous session (yesterday) — used by progression helpers for comparison
    let oldPush = WorkoutSplit(name: "Push Day", date: yesterday)
    let chestOld = Exercise(name: "Bench Press", order: 1)
    chestOld.sets.append(WorkoutSet(reps: 10, weight: 125, order: 1))
    chestOld.sets.append(WorkoutSet(reps: 8, weight: 145, order: 2))
    oldPush.exercises.append(chestOld)
    context.insert(oldPush)

    return WorkoutEditorView(split: push)
        .modelContainer(container)
}
