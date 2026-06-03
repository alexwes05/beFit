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
            Button("Test Bench Press") {

                let grouped = getAllSetsGroupedByDate(
                    for: "Bench Press",
                    from: splits
                )

                let sortedDates = grouped.keys.sorted(by: >)

                var totalAcrossAllDays = 0.0

                for date in sortedDates {

                    print("\n📅 DATE:", date)

                    var dayVolume = 0.0

                    if let sets = grouped[date] {

                        for set in sets {
                            print("   Reps:", set.reps,
                                  "Weight:", set.weight ?? 0,
                                  "Set Volume:", set.volume)

                            dayVolume += set.volume
                        }

                        print("🏋️ Day Volume:", dayVolume)
                    }

                    totalAcrossAllDays += dayVolume
                }

                print("\n📊 TOTAL BENCH PRESS VOLUME:", totalAcrossAllDays)
            }
            Button("Test Full Volume Breakdown") {

                var totalAllSplits = 0.0

                for split in splits {

                    print("\n==============================")
                    print("SPLIT:", split.name)
                    print("==============================")

                    var splitTotal = 0.0

                    for exercise in split.exercises {

                        let exerciseVolume = exercise.sets.reduce(0) { $0 + $1.volume }

                        print("\n     Exercise:", exercise.name)
                        print("     Volume:", exerciseVolume)

                        splitTotal += exerciseVolume
                    }

                    print("\nSPLIT TOTAL VOLUME:", splitTotal)

                    totalAllSplits += splitTotal
                }

                print("\n==============================")
                print("TOTAL ALL SPLITS VOLUME:", totalAllSplits)
                print("==============================")
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
