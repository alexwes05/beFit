//
//  ContentView.swift
//  BeFit
//
//  Created by Alex Wesolowski on 4/24/26.
//

import SwiftUI


struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 240/255, green: 240/255, blue: 255/255)
                    .ignoresSafeArea(edges: .all)
                Image("AppBackground")
                    .renderingMode(.template)
                    .foregroundStyle(.blue)
                    .opacity(0.1)
            VStack(spacing:20) {
                       Text("BeFit")
                           .font(Font.custom("Pixelify Sans", size: 80))
                       
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
                   }
            }
        }
        
    }
    
}


#Preview {
    ContentView()
}

