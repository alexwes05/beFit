//
//  ViewWorkouts.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/2/26.
//

import SwiftUI
import SwiftData

struct ViewWorkouts: View {

    @Query var splits: [WorkoutSplit]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 240/255, green: 240/255, blue: 255/255)
                    .ignoresSafeArea()

                Image("AppBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.1)

                List {
                    ForEach(splits) { split in
                        HStack{
                            VStack(alignment: .leading, spacing: 5) {
                                Text(split.name)
                                    .font(.headline)
                                
                                Text(split.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                            Button("Edit"){}
                            Button("Use"){}
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .padding(.top, 40)
            }
            .navigationTitle("") // optional: remove default title
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("View Workouts")
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

    let split = WorkoutSplit(name: "Push Day")
    container.mainContext.insert(split)

    return ViewWorkouts()
        .modelContainer(container)
}
