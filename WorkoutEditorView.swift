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
    
    var body: some View {
        ZStack {
            Color(red: 240/255, green: 240/255, blue: 255/255)
                .ignoresSafeArea()
            
            Image("AppBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.1)
            
            VStack{
                HStack{
                    Spacer()
                    Text(split.name)
                        .font(Font.custom("Pixelify Sans", size: 40)).bold()
                        .padding(.top, 40)
                    Spacer()
                    DatePicker(
                        "Date",
                        selection: $split.date,
                        displayedComponents: .date
                    ).labelsHidden()
                        .padding(.horizontal)
                        .padding(.top, 40)
                    Spacer()
                }
                List {
                    ForEach(split.exercises) { exercise in

                        Section {

                            ForEach(exercise.sets) { set in
                                SetRow(set: set)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    //let set = exercise.sets[index]
                                    exercise.sets.remove(at: index)
                                }
                            }

                            AddSetRow(exercise: exercise)

                        } header: {

                            Text(exercise.name)
                                .font(Font.custom("Pixelify Sans", size: 20))
                                .bold()
                        }
                    }

                    AddExerciseRow(split: split)
                    
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
    }
}

struct SetRow: View {

    @Bindable var set: WorkoutSet

    var body: some View {
        HStack {

            TextField(
                "Weight",
                value: $set.weight,
                format: .number
            )
            .keyboardType(.decimalPad)
            .frame(width: 70)
            .textFieldStyle(.roundedBorder)

            Text("x")

            TextField(
                "Reps",
                value: $set.reps,
                format: .number
            )
            .keyboardType(.numberPad)
            .frame(width: 60)
            .textFieldStyle(.roundedBorder)

            Spacer()

            //Checkmark
            Button {
                set.isCompleted.toggle()
            } label: {
                Image(systemName: set.isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundStyle(set.isCompleted ? .blue : .gray)
            }
            .buttonStyle(.plain)
        }
    }
}

struct AddSetRow: View {

    @Bindable var exercise: Exercise

    @State private var repsText = ""
    @State private var weightText = ""

    var body: some View {
        HStack {

            // REPS INPUT
            TextField("Reps", text: $repsText)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)
            Text("x")
            // WEIGHT INPUT
            TextField("Weight", text: $weightText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 90)
            Spacer()
            Button("Add") {

                let reps = Int(repsText) ?? 0
                let weight = Double(weightText)

                let set = WorkoutSet(
                    reps: reps,
                    weight: weight
                )

                exercise.sets.append(set)

                // reset fields
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

#Preview {
    let split = WorkoutSplit(name: "Push Day")

    let chest = Exercise(name: "Bench Press")
    chest.sets.append(WorkoutSet(reps: 10, weight: 135))
    chest.sets.append(WorkoutSet(reps: 8, weight: 155))

    split.exercises.append(chest)

    return WorkoutEditorView(split: split)
}
