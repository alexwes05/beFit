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
