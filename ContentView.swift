//
//  ContentView.swift
//  BeFit
//
//  Created by Alex Wesolowski on 4/24/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    
    @Query(
        sort: \WorkoutSplit.date,
        order: .reverse,
        animation: .default
    )
    private var recentSplits: [WorkoutSplit]
    
    var body: some View {
        let topThree = Array(recentSplits.prefix(3))
        NavigationStack {
            ZStack {
                Color(red: 240/255, green: 240/255, blue: 255/255)
                    .ignoresSafeArea(edges: .all)
                Image("AppBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.1)
            VStack(spacing:20) {
                       Text("BeFit")
                           .font(Font.custom("Pixelify Sans", size: 80))
                       
                if !recentSplits.isEmpty {

                    VStack(spacing: 12) {

                        Text("Recent Workouts")
                            .font(Font.custom("Pixelify Sans", size: 25))

                        HStack(spacing: 20) {
                            ForEach(topThree) { split in
                                NavigationLink {
                                    WorkoutEditorView(split: split)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(split.name)
                                                .font(.headline)

                                            Text(split.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundStyle(.gray)
                                        }

                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                            }
                            .foregroundColor(Color.blue)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.6))
                    )
                    .padding(.horizontal)
                }
                        NavigationLink {
                               CreateNewSplit()
                           } label: {
                               Text("Create New Split")
                           }.buttonStyle(BorderedButtonStyle())
                            .font(Font.custom("Pixelify Sans", size: 20))
                            .foregroundColor(.black)
                            .tint(.blue)
                
                        NavigationLink {
                               ViewWorkouts()
                           } label: {
                               Text("View my workouts")
                           }
                           .buttonStyle(BorderedButtonStyle())
                           .font(Font.custom("Pixelify Sans", size: 20))
                           .foregroundColor(.black)
                           .tint(.gray)
                   }
            }
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

    let context = container.mainContext

    // MARK: - Sample Workout 1
    let push = WorkoutSplit(name: "Push Day", date: Date())

    let bench = Exercise(name: "Bench Press")
    bench.sets.append(WorkoutSet(reps: 10, weight: 135))
    bench.sets.append(WorkoutSet(reps: 8, weight: 155))

    push.exercises.append(bench)

    let triceps = Exercise(name: "Tricep Pushdown")
    triceps.sets.append(WorkoutSet(reps: 12, weight: 60))

    push.exercises.append(triceps)

    context.insert(push)

    // MARK: - Sample Workout 2
    let pull = WorkoutSplit(name: "Pull Day", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)

    let row = Exercise(name: "Barbell Row")
    row.sets.append(WorkoutSet(reps: 10, weight: 95))
    row.sets.append(WorkoutSet(reps: 8, weight: 115))

    pull.exercises.append(row)

    context.insert(pull)

    // MARK: - Sample Workout 3
    let legs = WorkoutSplit(name: "Leg Day", date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!)

    let squat = Exercise(name: "Squat")
    squat.sets.append(WorkoutSet(reps: 8, weight: 185))
    squat.sets.append(WorkoutSet(reps: 6, weight: 225))

    legs.exercises.append(squat)

    context.insert(legs)

    return ContentView()
        .modelContainer(container)
}
