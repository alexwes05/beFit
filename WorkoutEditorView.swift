//
//  WorkoutEditorView.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/2/26.
//

import SwiftUI
import SwiftData

struct WorkoutEditorView: View {
    
    @Bindable var split: WorkoutSplit
    @Environment(\.modelContext) private var context
    
    @State private var exerciseToDelete: Exercise?
    
    @Query(sort: \WorkoutSplit.date, order: .reverse)
    var allSplits: [WorkoutSplit]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 240/255, green: 240/255, blue: 255/255)
                    .ignoresSafeArea()
                
                Image("AppBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.1)
                
                VStack{
                    DatePicker(
                        "Date",
                        selection: $split.date,
                        displayedComponents: .date
                    ).labelsHidden()
                        .padding(.horizontal)
                        .padding(.top, 60)
                    
                    List {
                        ForEach(split.exercises) { exercise in
                            //per-set progression data
                            let progression = compareProgression(
                                exerciseName: exercise.name,
                                currentSplit: split,
                                allSplits: allSplits
                            )

                            let sets = exercise.sets
                                .sorted { $0.order < $1.order }

                            Section {
                                ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                                    //assigns a progression value for the current set index if it exists
                                    let prog = index < progression.count ? progression[index] : nil
                                    SetRow(set: set, progression: prog)
                                }
                                //DELETE
                                .onDelete { indexSet in
                                    let sorted = exercise.sets.sorted { $0.order < $1.order }

                                    for index in indexSet {
                                        let setToDelete = sorted[index]
                                        exercise.sets.removeAll { $0.id == setToDelete.id }
                                    }

                                    // re-normalize order
                                    for (i, set) in exercise.sets.sorted(by: { $0.order < $1.order }).enumerated() {
                                        set.order = i
                                    }
                                }
                                
                                AddSetRow(exercise: exercise)

                            } header: {
                                HStack {
                                    Text(exercise.name)
                                        .font(Font.custom("Pixelify Sans", size: 20))
                                        .bold()

                                    Spacer()
                                    Text("Volume: \(exercise.volume.formatted())").font(Font.custom("", size: 14))
                                    // Exercise Progression
                                    if let progression = compareExerciseProgression(
                                        exerciseName: exercise.name,
                                        currentSplit: split,
                                        allSplits: allSplits
                                    ) {

                                        Text(
                                            progression.change >= 0
                                            ? "↑+\(Int(progression.change)) (\(Int(progression.percent))%)"
                                            : "↓\(Int(abs(progression.change))) (\(Int(progression.percent))%)"
                                        ).font(Font.custom("", size: 14))
                                            .foregroundStyle(progression.change >= 0 ? .green : .red)
                                    }
                                    Button {
                                        exerciseToDelete = exercise
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.black)
                                    }
                                    .padding(.trailing, -8)
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        AddExerciseRow(split: split)
                        
                    }
                    .listStyle(.sidebar)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(split.name)
                        .font(Font.custom("Pixelify Sans", size: 40))
                        .bold()
                }

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
        .alert(
            "Delete Exercise?",
            isPresented: Binding(
                get: { exerciseToDelete != nil },
                set: { if !$0 { exerciseToDelete = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                if let exercise = exerciseToDelete {
                    split.exercises.removeAll { $0.id == exercise.id }
                    context.delete(exercise)
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

    func duplicateSplit() {
        let newSplit = WorkoutSplit(
            name: split.name,
            date: Date()
        )

        for exercise in split.exercises {
            let newExercise = Exercise(name: exercise.name)

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

struct SetRow: View {

    @Bindable var set: WorkoutSet
    var progression: SetProgression?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            HStack {
                //Text("\(set.order)")

                TextField("Weight", value: $set.weight, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 70)
                    .textFieldStyle(.roundedBorder)

                Text("x")

                TextField("Reps", value: $set.reps, format: .number)
                    .keyboardType(.numberPad)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)

                Spacer()

                Button {
                    set.isCompleted.toggle()
                } label: {
                    Image(systemName: set.isCompleted ? "checkmark.square.fill" : "square")
                        .foregroundStyle(set.isCompleted ? .blue : .gray)
                }
                .buttonStyle(.plain)
            }

            if let progression {

                if progression.isNewSet {
                    Text("NEW SET")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                } else {
                    Text(
                        progression.change >= 0
                        ? "↑ +\(Int(progression.change)) (\(Int(progression.percent))%)"
                        : "↓ \(Int(abs(progression.change))) (\(Int(progression.percent))%)"
                    )
                    .font(.caption2)
                    .foregroundStyle(
                        progression.change >= 0 ? .green : .red
                    )
                }
            }
        }
    }
}

struct AddSetRow: View {

    @Bindable var exercise: Exercise

    @State private var repsText = ""
    @State private var weightText = ""

    var body: some View {
        HStack {

            TextField("Weight", text: $weightText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)

            Text("x")

            TextField("Reps", text: $repsText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 90)

            Spacer()

            Button("Add") {

                let reps = Int(repsText) ?? 0
                let weight = Double(weightText) ?? 0

                let nextOrder = (exercise.sets.map { $0.order }.max() ?? 0) + 1

                let set = WorkoutSet(
                    reps: reps,
                    weight: weight,
                    order: nextOrder
                )

                exercise.sets.append(set)

                repsText = ""
                weightText = ""
            }
        }
    }
}

struct AddExerciseRow: View {

    @Bindable var split: WorkoutSplit
    @State private var name = ""

    var body: some View {
        HStack {

            TextField("New exercise", text: $name)
                .textFieldStyle(.roundedBorder)

            Button("Add") {
                guard !name.isEmpty else { return }

                let exercise = Exercise(name: name)
                split.exercises.append(exercise)

                name = ""
            }
        }
    }
}


//updated to have order
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

    // CURRENT SPLIT (today)
    let push = WorkoutSplit(name: "Push Day", date: today)

    let chest = Exercise(name: "Bench Press")
    chest.sets.append(WorkoutSet(reps: 10, weight: 135, order: 0))
    chest.sets.append(WorkoutSet(reps: 8, weight: 155, order: 1))

    push.exercises.append(chest)
    context.insert(push)
 
    //PREVIOUS SPLIT (yesterday)
    let oldPush = WorkoutSplit(name: "Push Day", date: yesterday)

    let chestOld = Exercise(name: "Bench Press")
    chestOld.sets.append(WorkoutSet(reps: 10, weight: 125, order: 0))
    chestOld.sets.append(WorkoutSet(reps: 8, weight: 145, order: 1))

    oldPush.exercises.append(chestOld)
    context.insert(oldPush)

    return WorkoutEditorView(split: push)
        .modelContainer(container)
}
