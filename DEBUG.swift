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
            
            Button("Test Set Progression (Bench Press)") {
                print("--------------")

                let sortedSplits = splits.sorted { $0.date > $1.date }

                guard let currentSplit = sortedSplits.first else {
                    print("No splits found")
                    return
                }

                let progression = compareProgression(
                    exerciseName: "Bench Press",
                    currentSplit: currentSplit,
                    allSplits: sortedSplits
                )

                print("\n📊 SET PROGRESSION RESULT")
                print("------------------------")

                for item in progression {

                    print("""
                    Set \(item.index + 1):
                        Current: \(item.currentWeight)x\(item.currentReps)
                        Previous: \(item.previousWeight)x\(item.previousReps)
                        Change: \(item.change >= 0 ? "+" : "")\(item.change)
                        Percent: \(String(format: "%.1f", item.percent))%
                        New Set: \(item.isNewSet)
                    """)
                }
            }
            Button("Test Consistency Metrics") {
                print("--------------")

                let metrics = getConsistencyMetrics(from: splits)

                print("📅 CONSISTENCY METRICS")
                print("----------------------")
                print("Workouts This Week: \(metrics.workoutsThisWeek)")
                print("Current Streak: \(metrics.currentStreak)")
                print("Longest Streak: \(metrics.longestStreak)")
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
    bench.sets.append(WorkoutSet(reps: 10, weight: 135, order: 0))
    bench.sets.append(WorkoutSet(reps: 8, weight: 155, order: 1))
    bench.sets.append(WorkoutSet(reps: 8, weight: 155, order: 2))

    push.exercises.append(bench)
    context.insert(push)

    // MARK: - Sample Split 2 (yesterday)
    let pullDate = Calendar.current.date(byAdding: .day, value: -1, to: now)!

    let pull = WorkoutSplit(name: "Pull Day", date: pullDate)

    let row = Exercise(name: "Barbell Row")
    row.sets.append(WorkoutSet(reps: 10, weight: 95, order: 0))

    pull.exercises.append(row)

    let bench2 = Exercise(name: "Bench Press")
    bench2.sets.append(WorkoutSet(reps: 10, weight: 145, order: 0))
    bench2.sets.append(WorkoutSet(reps: 8, weight: 155, order: 1))

    pull.exercises.append(bench2)

    context.insert(pull)

    // MARK: - Sample Split 3 (2 days ago)
    let legsDate = Calendar.current.date(byAdding: .day, value: -2, to: now)!

    let legs = WorkoutSplit(name: "Leg Day", date: legsDate)

    let squat = Exercise(name: "Squat")
    squat.sets.append(WorkoutSet(reps: 8, weight: 185, order: 0))
    squat.sets.append(WorkoutSet(reps: 6, weight: 225, order: 1))

    legs.exercises.append(squat)
    context.insert(legs)

    return TestAnalyticsView()
        .modelContainer(container)
}
