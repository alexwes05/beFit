//
//  CreateNewSplit.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/2/26.
//

import SwiftUI
import SwiftData

struct CreateNewSplit: View {

    @Environment(\.modelContext) private var context
    @State private var name: String = ""

    @State private var showAlert = false   // 👈 add this

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

                VStack {
                    TextField("Workout name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .padding(50)

                    Button("Save Workout") {
                        addItem(name: name)
                    }
                    .disabled(name.isEmpty)
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
            .alert("Created", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }

    func addItem(name: String) {
        let newSplit = WorkoutSplit(name: name)
        context.insert(newSplit)

        self.name = ""
        self.showAlert = true   // 👈 trigger alert
    }
}
