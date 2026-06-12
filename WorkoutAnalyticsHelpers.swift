//
//  WorkoutAnalyticsHelpers.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/3/26.
//

import Foundation
import SwiftData

func getAllSetsGroupedByDate( for exerciseName: String, from splits: [WorkoutSplit]) -> [Date: [WorkoutSet]] {

    var results: [Date: [WorkoutSet]] = [:]

    for split in splits {
        for exercise in split.exercises {
            if exercise.name == exerciseName {
                results[split.date, default: []]
                    .append(contentsOf: exercise.sets)
            }
        }
    }

    return results
}

func getAllSets(for exerciseName: String, from splits: [WorkoutSplit]) -> [WorkoutSet] {
    var results: [WorkoutSet] = []

    for split in splits {
        for exercise in split.exercises {
            if exercise.name == exerciseName {
                results.append(contentsOf: exercise.sets)
            }
        }
    }

    return results
}

func previousSplits(
    currentSplit: WorkoutSplit,
    allSplits: [WorkoutSplit]
) -> [WorkoutSplit] {

    allSplits
        .filter { $0.date < currentSplit.date }
        .sorted { $0.date < $1.date }
}


func getLastWorkout(
    for exerciseName: String,
    from splits: [WorkoutSplit]
) -> [WorkoutSet]? {

    let grouped = getAllSetsGroupedByDate(for: exerciseName, from: splits)

    guard let lastGroup = grouped.max(by: { $0.0 < $1.0 }) else {
        return nil
    }

    return lastGroup.1
}

//Three seperate PRs
func getTrainingVolumePR( for exerciseName: String, from splits: [WorkoutSplit]) -> WorkoutSet? {
    let sets = getAllSets(for: exerciseName, from: splits)
    return sets.max { a, b in
            a.volume < b.volume
        }
}

func getWeightPR( for exerciseName: String, from splits: [WorkoutSplit]) -> WorkoutSet? {
    let sets = getAllSets(for: exerciseName, from: splits)
    return sets.max { a, b in
            a.weight ?? 0 < b.weight ?? 0
        }
}

func getRepsPR( for exerciseName: String, from splits: [WorkoutSplit]) -> WorkoutSet? {
    let sets = getAllSets(for: exerciseName, from: splits)
    return sets.max { a, b in
            a.reps < b.reps
        }
}

struct SetProgression: Identifiable {
    let id = UUID()

    let index: Int

    let currentReps: Int
    let currentWeight: Double

    let previousReps: Int
    let previousWeight: Double

    let change: Double
    let percent: Double

    let isNewSet: Bool
}


func compareProgression(
    exerciseName: String,
    currentSplit: WorkoutSplit,
    allSplits: [WorkoutSplit]
) -> [SetProgression] {

    let pastSplits = previousSplits(
        currentSplit: currentSplit,
        allSplits: allSplits
    )

    // get last workout from ONLY real past splits
    guard var lastSets = getLastWorkout(
        for: exerciseName,
        from: pastSplits
    ) else {
        return []
    }

    guard let currentExercise = currentSplit.exercises.first(where: {
        $0.name == exerciseName
    }) else {
        return []
    }

    let currentSets = currentExercise.sets
        .sorted { $0.order < $1.order }

    lastSets = lastSets
        .sorted { $0.order < $1.order }

    let count = min(currentSets.count, lastSets.count)

    var results: [SetProgression] = []

    // matched sets
    for i in 0..<count {

        let current = currentSets[i]
        let previous = lastSets[i]

        let change = current.volume - previous.volume
        let percent = (change / max(previous.volume, 1)) * 100

        results.append(
            SetProgression(
                index: i,
                currentReps: current.reps,
                currentWeight: current.weight ?? 0,
                previousReps: previous.reps,
                previousWeight: previous.weight ?? 0,
                change: change,
                percent: percent,
                isNewSet: false
            )
        )
    }

    // extra current sets
    if currentSets.count > lastSets.count {
        for i in count..<currentSets.count {
            let set = currentSets[i]

            results.append(
                SetProgression(
                    index: i,
                    currentReps: set.reps,
                    currentWeight: set.weight ?? 0,
                    previousReps: 0,
                    previousWeight: 0,
                    change: set.volume,
                    percent: 100,
                    isNewSet: true
                )
            )
        }
    }

    return results
}

struct SplitProgression {

    let currentVolume: Double
    let previousVolume: Double

    let change: Double
    let percent: Double
}

func compareSplitProgression(
    currentSplit: WorkoutSplit,
    allSplits: [WorkoutSplit]
) -> SplitProgression? {

    let pastSplits = previousSplits(
        currentSplit: currentSplit,
        allSplits: allSplits
    )

    guard let previousSplit = pastSplits.last else {
        return nil
    }

    let currentVolume = currentSplit.volume
    let previousVolume = previousSplit.volume

    let change = currentVolume - previousVolume
    let percent = (change / max(previousVolume, 1)) * 100

    return SplitProgression(
        currentVolume: currentVolume,
        previousVolume: previousVolume,
        change: change,
        percent: percent
    )
}

func compareExerciseProgression(
    exerciseName: String,
    currentSplit: WorkoutSplit,
    allSplits: [WorkoutSplit]
) -> SetProgression? {

    let pastSplits = previousSplits(
        currentSplit: currentSplit,
        allSplits: allSplits
    )

    guard let lastSplit = pastSplits.last else { return nil }

    guard let previousExercise = lastSplit.exercises.first(where: {
        $0.name == exerciseName
    }) else { return nil }

    let previousVolume = previousExercise.volume
    let currentVolume = currentSplit.exercises.first(where: {
        $0.name == exerciseName
    })?.volume ?? 0

    let change = currentVolume - previousVolume
    let percent = (change / max(previousVolume, 1)) * 100

    return SetProgression(
        index: 0,
        currentReps: 0,
        currentWeight: currentVolume,
        previousReps: 0,
        previousWeight: previousVolume,
        change: change,
        percent: percent,
        isNewSet: false
    )
}




//New helper functions for charts

func getSplitVolumeOverTime(from splits: [WorkoutSplit]) -> [(date: Date, volume: Double)] {
    return splits
        .sorted { $0.date < $1.date }
        .map { ($0.date, $0.volume) }
}


func getExerciseVolumeOverTime(
    exercise: String,
    from splits: [WorkoutSplit]
) -> [(date: Date, volume: Double)] {
    return splits
        .sorted { $0.date < $1.date }
        .compactMap { split in
                   guard let exercise = split.exercises.first(where: { $0.name == exercise }) else {
                       return nil
                   }
                   return (split.date, exercise.volume)
               }
}


func getMaxWeightOverTime(
    exerciseName: String,
    from splits: [WorkoutSplit]
) -> [(date: Date, weight: Double)] {

    return splits
        .sorted { $0.date < $1.date }
        .compactMap { split in
            let sets = split.exercises
                .first(where: { $0.name == exerciseName })?
                .sets ?? []

            let maxWeight = sets.map { $0.weight ?? 0 }.max() ?? 0

            return maxWeight > 0 ? (split.date, maxWeight) : nil
        }
}

struct ConsistencyMetrics {
    let workoutsThisWeek: Int
    let currentStreak: Int
    let longestStreak: Int
}

func getConsistencyMetrics(
    from splits: [WorkoutSplit]
) -> ConsistencyMetrics {
    let calendar = Calendar.current
    let now = Date()

    let workoutsThisWeek = splits.filter {
        calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear)
    }.count
    
    let uniqueDays = Set(
        splits.map {
            calendar.startOfDay(for: $0.date)
        }
    )
    let sortedDays = uniqueDays.sorted(by: >)
    var currentStreak = 0

    guard let firstDay = sortedDays.first else {
        return ConsistencyMetrics(
            workoutsThisWeek: 0,
            currentStreak: 0,
            longestStreak: 0
        )
    }

    var expectedDay = calendar.startOfDay(for: firstDay)

    for day in sortedDays {

        if day == expectedDay {
            currentStreak += 1

            expectedDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: expectedDay
            )!
        } else {
            break
        }
    }
    var longestStreak = 0
    var runningStreak = 0

    for i in 0..<sortedDays.count {

        if i == 0 {
            runningStreak = 1
            longestStreak = 1
            continue
        }

        let previous = sortedDays[i - 1]
        let current = sortedDays[i]

        let daysBetween = calendar.dateComponents(
            [.day],
            from: current,
            to: previous
        ).day ?? 0

        if daysBetween == 1 {
            runningStreak += 1
        } else {
            longestStreak = max(longestStreak, runningStreak)
            runningStreak = 1
        }
    }

    longestStreak = max(longestStreak, runningStreak)
    
    return ConsistencyMetrics(
           workoutsThisWeek: workoutsThisWeek,
           currentStreak: currentStreak,
           longestStreak: longestStreak
       )
}
