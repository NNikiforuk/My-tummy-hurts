//
//  SelectDayView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 30/10/2024.
//

import SwiftUI

struct SelectDayView: View {
    @State private var selectedMonth: Int = 0
    
    var body: some View {
        VStack {
            VStack {
                MonthlyCalendar(selectedMonth: $selectedMonth)
            }
            .padding(.vertical, 30)
        }
        .padding()
        .navigationTitle("Select a day")
    }
}

#Preview {
    SelectDayView()
}
