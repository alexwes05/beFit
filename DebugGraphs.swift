//
//  DebugGraphs.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/9/26.
//

import SwiftUI
import SwiftData
import Charts


struct DebugGraphs: View {
    @Query var splits: [WorkoutSplit]
    var body: some View {
        // TEST: Split Volume Over Time
        Button("Test Split Volume Over Time") {
            print("--------------")
            
            let data = getSplitVolumeOverTime(from: splits)
            
            for point in data {
                print("""
                Date: \(point.date.formatted())
                Total Volume: \(point.volume)
                """)
            }
        }
        // TEST: Exercise Volume Over Time
        Button("Test Exercise Volume Over Time (Bench Press)") {
            print("--------------")
            
            let data = getExerciseVolumeOverTime(
                exercise: "Bench Press",
                from: splits
            )
            
            for point in data {
                print("""
                Date: \(point.date.formatted())
                Bench Volume: \(point.volume)
                """)
            }
        }
        // TEST: Max Weight Over Time
        Button("Test Max Weight Over Time (Bench Press)") {
            print("--------------")
            
            let data = getMaxWeightOverTime(
                exerciseName: "Bench Press",
                from: splits
            )
            
            for point in data {
                print("""
                Date: \(point.date.formatted())
                Max Weight: \(point.weight)
                """)
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
    let cal = Calendar.current

    func day(_ offset: Int) -> Date {
        cal.date(byAdding: .day, value: offset, to: now)!
    }

    // MARK: - Split 1
    let split1 = WorkoutSplit(name: "Push", date: day(-3))

    let bench1 = Exercise(name: "Bench Press")
    bench1.sets.append(WorkoutSet(reps: 10, weight: 135, order: 0))
    bench1.sets.append(WorkoutSet(reps: 8, weight: 155, order: 1))
    split1.exercises.append(bench1)

    context.insert(split1)

    // MARK: - Split 2
    let split2 = WorkoutSplit(name: "Push", date: day(-2))

    let bench2 = Exercise(name: "Bench Press")
    bench2.sets.append(WorkoutSet(reps: 10, weight: 145, order: 0))
    bench2.sets.append(WorkoutSet(reps: 8, weight: 165, order: 1))
    split2.exercises.append(bench2)

    context.insert(split2)

    // MARK: - Split 3
    let split3 = WorkoutSplit(name: "Push", date: day(-1))

    let bench3 = Exercise(name: "Bench Press")
    bench3.sets.append(WorkoutSet(reps: 10, weight: 155, order: 0))
    bench3.sets.append(WorkoutSet(reps: 8, weight: 175, order: 1))

    let squat = Exercise(name: "Squat")
    squat.sets.append(WorkoutSet(reps: 5, weight: 225, order: 0))

    split3.exercises.append(bench3)
    split3.exercises.append(squat)

    context.insert(split3)

    return DebugGraphs()
        .modelContainer(container)
}
