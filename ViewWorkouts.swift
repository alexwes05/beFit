//
//  ViewWorkouts.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/2/26.
//

import SwiftUI
import SwiftData

struct ViewWorkouts: View {

    @Query var splits: [WorkoutSplit]
    @Environment(\.modelContext) private var context
    @State private var showDeleteAlert = false
    @State private var splitToDelete: WorkoutSplit?

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

                List {
                    ForEach(splits) { split in
                        HStack{
                            VStack(alignment: .leading, spacing: 5) {
                                Text(split.name)
                                    .font(.headline)
                                
                                Text(split.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            
                            //DUPLICATE LOGIC
                            Button("Duplicate") {

                                let newSplit = WorkoutSplit(
                                    name: split.name,
                                    date: Date()
                                )

                                for exercise in split.exercises {

                                    let newExercise = Exercise(
                                        name: exercise.name
                                    )

                                    for set in exercise.sets {

                                        let newSet = WorkoutSet(
                                            reps: set.reps,
                                            weight: set.weight
                                        )

                                        newExercise.sets.append(newSet)
                                    }

                                    newSplit.exercises.append(newExercise)
                                }

                                context.insert(newSplit)
                            }.buttonStyle(.plain)
                                .foregroundStyle(Color.blue)
                            
                            NavigationLink {
                                WorkoutEditorView(split: split)
                            } label: {
                                Text("Edit")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.2))
                                    .foregroundStyle(.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            Spacer()
                            
                        } .swipeActions {
                            Button(role: .destructive) {
                                splitToDelete = split
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }

                    }
                    
                }
                .scrollContentBackground(.hidden)
                .padding(.top, 40)
            }
            .navigationTitle("") // optional: remove default title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("View Workouts")
                        .font(.custom("Pixelify Sans", size: 30))
                        .bold()
                }
            }
            .alert("Delete Workout?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }

                Button("Delete", role: .destructive) {
                    if let split = splitToDelete {
                        context.delete(split)
                    }
                }
            } message: {
                Text("This cannot be undone.")
            }
        }
    }
    
    func deleteSplit(at offsets: IndexSet) {
        for index in offsets {
            let split = splits[index]
            context.delete(split)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: WorkoutSplit.self,
        Exercise.self,
        WorkoutSet.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let split = WorkoutSplit(name: "Push Day")
    container.mainContext.insert(split)

    return ViewWorkouts()
        .modelContainer(container)
}
