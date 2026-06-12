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
    
    init(name: String, date: Date = Date()) {
        self.name = name
        self.date = date
    }
    var volume: Double {
        exercises.reduce(0) { $0 + $1.volume }
    }

    @Relationship(deleteRule: .cascade)
    var exercises: [Exercise] = []
    
    // SOURCE OF TRUTH FOR SORTED EXERCISES
    @Transient // Tells SwiftData not to save this property to the database
    var sortedExercises: [Exercise] {
        exercises.sorted { $0.order < $1.order }
    }
}


// MARK: - Exercise

@Model
class Exercise {
    var name: String
    var order: Int
 
 
    init(name: String, order: Int = 0) {
        self.name = name
        self.order = order
    }
 
    var volume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }
    
    @Relationship(deleteRule: .cascade)
    var sets: [WorkoutSet] = []
    @Transient
    var sortedSets: [WorkoutSet] {
        sets.sorted { $0.order < $1.order }
    }
}


// MARK: - Workout Set

@Model
class WorkoutSet {
    var uid: UUID = UUID()   // permanent, never changes
    var reps: Int
    var weight: Double?

    var isCompleted: Bool = false
 
    var order: Int
 
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
