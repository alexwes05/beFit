//
//  BeFitApp.swift
//  BeFit
//
//  Created by Alex Wesolowski on 4/24/26.
//

import SwiftUI
import SwiftData

@main
struct BeFitApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: WorkoutSplit.self)
    }
}
