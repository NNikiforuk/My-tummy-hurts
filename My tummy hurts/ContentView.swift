//
//  ContentView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 29/10/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMonth: Int = 0
    
    var body: some View {
        VStack {
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
            Divider()
            CalendarView(selectedMonth: $selectedMonth)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
