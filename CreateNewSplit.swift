//
//  CreateNewSplit.swift
//  BeFit
//
//  Created by Alex Wesolowski on 6/2/26.
//

import SwiftUI

struct CreateNewSplit: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 240/255, green: 240/255, blue: 255/255)
                    .ignoresSafeArea(edges: .all)
                Image("AppBackground")
                    .renderingMode(.template)
                    .foregroundStyle(.blue)
                    .opacity(0.1)
                VStack(){
                    
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
