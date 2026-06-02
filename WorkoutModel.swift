//
//  WorkoutModel.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/2/26.
//

import Foundation
struct WorkoutSplit: Identifiable {
    var id = UUID()
    var name: String
    var days: [WorkoutDay] = []
}

struct WorkoutDay: Identifiable {
    var id = UUID()
    var name: String
    var date: Date = Date()
    var exercises: [Exercise] = []
}
struct Exercise: Identifiable {
    var id = UUID()
    var name: String
    var sets: [WorkoutSet] = []
}

struct WorkoutSet: Identifiable {
    var id = UUID()
    var reps: Int
    var weight: Double?
}

