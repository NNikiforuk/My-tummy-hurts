//
//  DayView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 29/10/2024.
//

import SwiftUI

struct DayView: View {
    let selectedDate: Date
    let selectedDay: Int
    
    var body: some View {
        VStack {
            Text("30 October 2024")
                .font(.title.bold())
        }
        .navigationTitle("\(formatDate())")
    }
    
    func formatDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            return dateFormatter.string(from: selectedDate)
        }
}

#Preview {
    DayView(selectedDate: Date(), selectedDay: 0)
}
