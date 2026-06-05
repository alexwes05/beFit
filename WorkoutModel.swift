//
//  WorkoutModel.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/2/26.
//

import Foundation
import SwiftData

// MARK: - Workout Split

@Model
class WorkoutSplit {
    var name: String
    var date: Date

    @Relationship(deleteRule: .cascade)
    var exercises: [Exercise] = []

    init(name: String, date: Date = Date()) {
        self.name = name
        self.date = date
    }
    var volume: Double {
        exercises.reduce(0) { $0 + $1.volume }
    }
}


// MARK: - Exercise

@Model
class Exercise {
    var name: String

    @Relationship(deleteRule: .cascade)
    var sets: [WorkoutSet] = []

    init(name: String) {
        self.name = name
    }
    var volume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }
}


// MARK: - Workout Set

@Model
class WorkoutSet {
    var reps: Int
    var weight: Double?

    var isCompleted: Bool = false

    var order: Int = 0

    init(reps: Int, weight: Double? = nil, order: Int = 0) {
        self.reps = reps
        self.weight = weight
        self.order = order
    }

    var volume: Double {
        guard let weight else { return 0 }
        return Double(reps) * weight
    }
}
