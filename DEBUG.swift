//
//  DEBUG.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/3/26.
//

import SwiftUI
import SwiftData

struct TestAnalyticsView: View {
    @Query var splits: [WorkoutSplit]

    var body: some View {
        VStack {
            //TESTS IF CAN FIND BENCH PRESSES AND DOES IT BY ORDER OF DATE
            Button("Test Bench Press") {
                print("--------------")
                let grouped = getAllSetsGroupedByDate(for: "Bench Press", from: splits)
                let sortedDates = grouped.keys.sorted(by: >)
                
                for date in sortedDates {
                    print("DATE: \(date.formatted())")
                    
                    var dayVolume = 0.0
                    
                    if let sets = grouped[date] {
                        for set in sets {
                            print("Reps:", set.reps, "Weight:", set.weight ?? 0, "Set Volume:", set.volume)
                            dayVolume+=set.volume
                        }
                    }
                    print("Day Volume:", dayVolume)
                }
                
            }
            
            //Tests if computed volume vars work
            Button("Test Full Volume Breakdown") {
                print("--------------")
                for split in splits {
                    print("Split: \(split.name), Volume: \(split.volume)")
                    
                    for exercise in split.exercises {
                        print("Exercise: ", exercise.name, "Volume: \(exercise.volume)")
                    }
                }
            }
            
        
        //Tests to see if it will accurately get the last workout of a specific name
        Button("Test Last Workout (Bench Press)") {
            print("--------------")
            if let lastSets = getLastWorkout(for:"Bench Press", from: splits){
                print("Last Bench Press Workouts:")
                for set in lastSets {
                    print("Reps:", set.reps,
                          "Weight:", set.weight ?? 0,
                          "Set Volume:", set.volume)
                }
            }
        }
            
            //FIND PRs
            Button("Find the PR of Bench Press") {
                print("--------------")
                var pr = getTrainingVolumePR(for: "Bench Press", from: splits)
                print("The Volume PR for Bench Press is: \(pr?.volume.formatted() ?? "N/A")")
                print("With reps: \(pr?.reps ?? 0) and weight: \(pr?.weight ?? 0)")
                
                pr = getWeightPR(for: "Bench Press", from: splits)
                let weight = pr?.weight ?? 0
                print("The Weight PR for Bench Press is: \(weight)")
                print("With reps: \(pr?.reps ?? 0) and weight: \(pr?.weight ?? 0)")
                
                
                pr = getRepsPR(for: "Bench Press", from: splits)
                print("The Rep PR for Bench Press is: \(pr?.reps.formatted() ?? "N/A")")
                print("With reps: \(pr?.reps ?? 0) and weight: \(pr?.weight ?? 0)")
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

    let now = Date()

    // MARK: - Sample Split 1 (today)
    let push = WorkoutSplit(name: "Push Day", date: now)

    let bench = Exercise(name: "Bench Press")
    bench.sets.append(WorkoutSet(reps: 10, weight: 135))
    bench.sets.append(WorkoutSet(reps: 8, weight: 155))

    push.exercises.append(bench)
    context.insert(push)

    // MARK: - Sample Split 2 (yesterday)
    let pullDate = Calendar.current.date(byAdding: .day, value: -1, to: now)!

    let pull = WorkoutSplit(name: "Pull Day", date: pullDate)

    let row = Exercise(name: "Barbell Row")
    row.sets.append(WorkoutSet(reps: 10, weight: 95))

    pull.exercises.append(row)
    
    let bench2 = Exercise(name: "Bench Press")
    bench2.sets.append(WorkoutSet(reps: 10, weight: 145))
    bench2.sets.append(WorkoutSet(reps: 8, weight: 155))
    
    pull.exercises.append(bench2)

    context.insert(pull)

    // MARK: - Sample Split 3 (2 days ago)
    let legsDate = Calendar.current.date(byAdding: .day, value: -2, to: now)!

    let legs = WorkoutSplit(name: "Leg Day", date: legsDate)

    let squat = Exercise(name: "Squat")
    squat.sets.append(WorkoutSet(reps: 8, weight: 185))
    squat.sets.append(WorkoutSet(reps: 6, weight: 225))

    legs.exercises.append(squat)
    context.insert(legs)

    return TestAnalyticsView()
        .modelContainer(container)
}
