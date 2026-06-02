//
//  CreateNewSplit.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/2/26.
//

import SwiftUI

struct CreateNewSplit: View {
    
    @State private var name: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 240/255, green: 240/255, blue: 255/255)
                    .ignoresSafeArea(edges: .all)
                Image("AppBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.1)
                VStack(){
                    TextField("Workout name", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .padding(50)
                    
                    Button("Save Workout") {
                        let newSplit = WorkoutSplit(
                            name: name,
                            days: []
                        )
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Create New Split")
                        .font(.custom("Pixelify Sans", size: 30))
                        .bold()
                }
            }
        }
    }
}

#Preview {
    CreateNewSplit()
}
