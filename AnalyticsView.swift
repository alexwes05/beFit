//
//  AnalyticsView.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/10/26.
//

import SwiftUI

import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {

    @Query(sort: \WorkoutSplit.date, order: .reverse)
    private var splits: [WorkoutSplit]

    @State private var selectedExercise: String = ""

    var exercises: [String] {
        let all = splits.flatMap { $0.exercises.map { $0.name } }
        return Array(Set(all)).sorted()
    }

    var chartData: [(date: Date, volume: Double)] {
        guard !selectedExercise.isEmpty else { return [] }

        return getExerciseVolumeOverTime(
            exercise: selectedExercise,
            from: splits
        )
    }
    var maxWeightData: [(date: Date, weight: Double)] {
        guard !selectedExercise.isEmpty else { return [] }

        return getMaxWeightOverTime(
            exerciseName: selectedExercise,
            from: splits
        )
    }

    var body: some View {
        NavigationStack{
            ZStack {
                Color(red: 240/255, green: 240/255, blue: 255/255)
                    .ignoresSafeArea()
                
                Image("AppBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.1)
                
                VStack(spacing: 20) {
                    
                    // MARK: Picker
                    if !exercises.isEmpty {

                        Picker("Exercise", selection: $selectedExercise) {
                            ForEach(exercises, id: \.self) { name in
                                Text(name).tag(name)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.8))
                        )
                        .onAppear {
                            if selectedExercise.isEmpty {
                                selectedExercise = exercises.first ?? ""
                            }
                        }
                    }
    
                    
                    // MARK: Chart
                    if !chartData.isEmpty {
                        let minVolume = (chartData.map { $0.volume }.min() ?? 0) * 0.98
                        let maxVolume = (chartData.map { $0.volume }.max() ?? 1) * 1.02
                        VStack(alignment: .leading, spacing: 16) {
                            

                            Text("\(selectedExercise) Volume Over Time")
                                .font(Font.custom("Pixelify Sans", size: 20))

                            Chart(chartData, id: \.date) {
                                LineMark(
                                    x: .value("Date", $0.date),
                                    y: .value("Volume", $0.volume)
                                )
                                //.interpolationMethod(.catmullRom)

                                PointMark(
                                    x: .value("Date", $0.date),
                                    y: .value("Volume", $0.volume)
                                )
                            }
                            .frame(height: 220)
                            .chartYScale(domain: minVolume...maxVolume)

                            Divider()
                                .padding(.vertical, 6)

                            // 🔥 SECOND CHART (Max Weight)
                            if !maxWeightData.isEmpty {
                                let minWeight = (maxWeightData.map { $0.weight }.min() ?? 0) * 0.95
                                let maxWeight = (maxWeightData.map { $0.weight }.max() ?? 1) * 1.05

                                Text("\(selectedExercise) Max Weight Over Time")
                                    .font(Font.custom("Pixelify Sans", size: 18))

                                Chart(maxWeightData, id: \.date) {
                                    LineMark(
                                        x: .value("Date", $0.date),
                                        y: .value("Weight", $0.weight)
                                    )
                                    //.interpolationMethod(.catmullRom)

                                    PointMark(
                                        x: .value("Date", $0.date),
                                        y: .value("Weight", $0.weight)
                                    )
                                }
                                .frame(height: 180)
                                .chartYScale(domain: minWeight...maxWeight)
                            }
                        }
                        .padding()
                        .background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Spacer()
                }
                .padding(.top, 60)
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Workout Analytics")
                        .font(.custom("Pixelify Sans", size: 30))
                        .bold()
                }
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
    let calendar = Calendar.current
    let now = Date()

    // MARK: - Push Day
    let push = WorkoutSplit(name: "Push Day", date: now)

    let bench1 = Exercise(name: "Bench Press")
    bench1.sets.append(WorkoutSet(reps: 10, weight: 135))
    bench1.sets.append(WorkoutSet(reps: 8, weight: 155))
    push.exercises.append(bench1)

    context.insert(push)

    // MARK: - Push Day (older)
    let push2 = WorkoutSplit(
        name: "Push Day",
        date: calendar.date(byAdding: .day, value: -3, to: now)!
    )

    let bench2 = Exercise(name: "Bench Press")
    bench2.sets.append(WorkoutSet(reps: 10, weight: 130))
    bench2.sets.append(WorkoutSet(reps: 8, weight: 150))
    push2.exercises.append(bench2)

    context.insert(push2)

    // MARK: - Pull Day
    let pull = WorkoutSplit(
        name: "Pull Day",
        date: calendar.date(byAdding: .day, value: -1, to: now)!
    )

    let row = Exercise(name: "Barbell Row")
    row.sets.append(WorkoutSet(reps: 10, weight: 95))
    row.sets.append(WorkoutSet(reps: 8, weight: 115))
    pull.exercises.append(row)

    context.insert(pull)

    // MARK: - Legs
    let legs = WorkoutSplit(
        name: "Leg Day",
        date: calendar.date(byAdding: .day, value: -2, to: now)!
    )

    let squat = Exercise(name: "Squat")
    squat.sets.append(WorkoutSet(reps: 8, weight: 185))
    squat.sets.append(WorkoutSet(reps: 6, weight: 225))
    legs.exercises.append(squat)

    context.insert(legs)

    return AnalyticsView()
        .modelContainer(container)
}
