//
//  ContentView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 29/10/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                HStack {
                    Image("logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                    VStack(alignment: .leading) {
                        Text("My tummy")
                            .font(.title.bold())
                            .foregroundStyle(.brown)
                        Text("hurts")
                            .font(.title.bold())
                            .foregroundStyle(.brown)
                    }
                }
                NavigationLink("Let's try to check why") {
                    SelectDayView()
                }
                .padding()
                .background(.brown)
                .clipShape(.capsule)
                .foregroundStyle(.white)
                .bold()
                
                NavigationLink {
                    FAQ()
                } label: {
                    Text("FAQ")
                        .foregroundColor(.yellow)
                        .bold()
            }
            }
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
