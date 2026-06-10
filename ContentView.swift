//
//  ContentView.swift
//  BeFit
//
//  Created by Alex Wesolowski on 4/24/26.
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    
    
    @Query(
        sort: \WorkoutSplit.date,
        order: .reverse,
        animation: .default
    )
    private var recentSplits: [WorkoutSplit]
    
    var body: some View {
        let topThree = Array(recentSplits.prefix(3))
        NavigationStack {
            ZStack {
                Color(red: 240/255, green: 240/255, blue: 255/255)
                    .ignoresSafeArea(edges: .all)
                Image("AppBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.1)
                VStack(spacing:20) {
                    Text("BeFit")
                        .font(Font.custom("Pixelify Sans", size: 80))
                    
                    if !recentSplits.isEmpty {
                        
                        VStack(spacing: 12) {
                            
                            Text("Recent Workouts")
                                .font(Font.custom("Pixelify Sans", size: 25))
                            
                            HStack(spacing: 20) {
                                ForEach(topThree) { split in
                                    NavigationLink {
                                        WorkoutEditorView(split: split)
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(split.name)
                                                    .font(.headline)
                                                
                                                Text(split.date.formatted(date: .abbreviated, time: .omitted))
                                                    .font(.caption)
                                                    .foregroundStyle(.gray)
                                            }
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.gray)
                                        }
                                        .padding(.vertical, 6)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .foregroundColor(Color.blue)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.6))
                        )
                        .padding(.horizontal)
                        
                    }
                    NavigationLink {
                        CreateNewSplit()
                    } label: {
                        Text("Create New Split")
                    }.buttonStyle(BorderedButtonStyle())
                        .font(Font.custom("Pixelify Sans", size: 20))
                        .foregroundColor(.black)
                        .tint(.blue)
                    
                    NavigationLink {
                        ViewWorkouts()
                    } label: {
                        Text("View my workouts")
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .font(Font.custom("Pixelify Sans", size: 20))
                    .foregroundColor(.black)
                    .tint(.gray)
                    
                    if !recentSplits.isEmpty {

                        let metrics = getConsistencyMetrics(from: recentSplits)
                        let chartData = getSplitVolumeOverTime(from: recentSplits)

                        HStack(spacing: 20) {
                            VStack{
                                Text("Volume Over Time")
                                        .font(.headline)
        
                            // Chart on left
                            Chart(chartData, id: \.date) { point in
                                
                                LineMark(
                                    x: .value("Date", point.date),
                                    y: .value("Volume", point.volume)
                                )
                                
                                PointMark(
                                    x: .value("Date", point.date),
                                    y: .value("Volume", point.volume)
                                )
                            }
                            .frame(width: 220, height: 140)
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                                }
                            }
                        }
                            // Metrics on right
                            VStack(spacing: 20) {

                                VStack {
                                    Text("🔥")
                                        .font(.title2)

                                    Text("\(metrics.currentStreak)")
                                        .font(.title3.bold())

                                    Text("Day Streak")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Divider()

                                VStack {
                                    Text("📅")
                                        .font(.title2)

                                    Text("\(metrics.workoutsThisWeek)")
                                        .font(.title3.bold())

                                    Text("This Week")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(width: 100)
                        }
                        .padding()
                        .background(
                            .white.opacity(0.8),
                            in: RoundedRectangle(cornerRadius: 16)
                        )
                        .padding(.horizontal)
                    }
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
    
    // MARK: - Sample Workout 1
    let push = WorkoutSplit(name: "Push Day", date: Date())

    let bench = Exercise(name: "Bench Press")
    bench.sets.append(WorkoutSet(reps: 10, weight: 135))
    bench.sets.append(WorkoutSet(reps: 8, weight: 155))

    push.exercises.append(bench)

    let triceps = Exercise(name: "Tricep Pushdown")
    triceps.sets.append(WorkoutSet(reps: 12, weight: 60))

    push.exercises.append(triceps)

    context.insert(push)

    // MARK: - Sample Workout 2
    let pull = WorkoutSplit(name: "Pull Day", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)

    let row = Exercise(name: "Barbell Row")
    row.sets.append(WorkoutSet(reps: 10, weight: 95))
    row.sets.append(WorkoutSet(reps: 8, weight: 115))

    pull.exercises.append(row)

    context.insert(pull)

    // MARK: - Sample Workout 3
    let legs = WorkoutSplit(name: "Leg Day", date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!)

    let squat = Exercise(name: "Squat")
    squat.sets.append(WorkoutSet(reps: 8, weight: 185))
    squat.sets.append(WorkoutSet(reps: 6, weight: 225))

    legs.exercises.append(squat)

    context.insert(legs)
    
    let push2 = WorkoutSplit(
        name: "Push Day",
        date: calendar.date(byAdding: .day, value: -3, to: now)!
    )

    let bench4 = Exercise(name: "Bench Press")
    bench4.sets.append(WorkoutSet(reps: 10, weight: 140))
    bench4.sets.append(WorkoutSet(reps: 8, weight: 160))

    push2.exercises.append(bench4)

    let triceps4 = Exercise(name: "Tricep Pushdown")
    triceps4.sets.append(WorkoutSet(reps: 12, weight: 65))

    push2.exercises.append(triceps4)

    context.insert(push2)
    
    let pull2 = WorkoutSplit(
        name: "Pull Day",
        date: calendar.date(byAdding: .day, value: -4, to: now)!
    )

    let row2 = Exercise(name: "Barbell Row")
    row2.sets.append(WorkoutSet(reps: 10, weight: 105))
    row2.sets.append(WorkoutSet(reps: 8, weight: 125))

    pull2.exercises.append(row2)

    context.insert(pull2)
    
    let legs2 = WorkoutSplit(
        name: "Leg Day",
        date: calendar.date(byAdding: .day, value: -5, to: now)!
    )

    let squat2 = Exercise(name: "Squat")
    squat2.sets.append(WorkoutSet(reps: 8, weight: 195))
    squat2.sets.append(WorkoutSet(reps: 6, weight: 235))

    legs2.exercises.append(squat2)

    context.insert(legs2)
    
    let push3 = WorkoutSplit(
        name: "Push Day",
        date: calendar.date(byAdding: .day, value: -6, to: now)!
    )

    let bench5 = Exercise(name: "Bench Press")
    bench5.sets.append(WorkoutSet(reps: 10, weight: 130))
    bench5.sets.append(WorkoutSet(reps: 8, weight: 150))

    push3.exercises.append(bench5)

    context.insert(push3)
    let pull3 = WorkoutSplit(
        name: "Pull Day",
        date: calendar.date(byAdding: .day, value: -7, to: now)!
    )

    let row3 = Exercise(name: "Barbell Row")
    row3.sets.append(WorkoutSet(reps: 10, weight: 90))
    row3.sets.append(WorkoutSet(reps: 8, weight: 110))

    pull3.exercises.append(row3)

    context.insert(pull3)
    
    
    let legs3 = WorkoutSplit(
        name: "Leg Day",
        date: calendar.date(byAdding: .day, value: -8, to: now)!
    )

    let squat3 = Exercise(name: "Squat")
    squat3.sets.append(WorkoutSet(reps: 8, weight: 175))
    squat3.sets.append(WorkoutSet(reps: 6, weight: 215))

    legs3.exercises.append(squat3)

    context.insert(legs3)
    
    let push4 = WorkoutSplit(
        name: "Push Day",
        date: calendar.date(byAdding: .day, value: -9, to: now)!
    )

    let bench6 = Exercise(name: "Bench Press")
    bench6.sets.append(WorkoutSet(reps: 10, weight: 125))
    bench6.sets.append(WorkoutSet(reps: 8, weight: 145))

    push4.exercises.append(bench6)

    context.insert(push4)
    
    

    return ContentView()
        .modelContainer(container)
}
