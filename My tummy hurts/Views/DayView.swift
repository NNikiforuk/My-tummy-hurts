//
//  DayView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 29/10/2024.
//

import SwiftUI

struct DayView: View {
    
    var body: some View {
        VStack {
            Text("30 October 2024")
                .font(.title.bold())
        }
        .navigationTitle("Daily symptopms")
    }
}

#Preview {
    DayView()
}
