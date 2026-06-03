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
}


// MARK: - Workout Set

@Model
class WorkoutSet {
    var reps: Int
    var weight: Double?

    init(reps: Int, weight: Double? = nil) {
        self.reps = reps
        self.weight = weight
    }
}
