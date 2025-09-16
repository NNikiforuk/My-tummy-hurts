//
//  CalendarDay.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 15/09/2025.
//

import SwiftUI

struct CalendarDay: View {
    @EnvironmentObject var model: ViewModel
    @State private var selection: NoteTab = .meals
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack(spacing: 20) {
            Text(selectedDate, style: .date)
                .font(.title2.bold())
                .padding(.vertical, 10)
                .foregroundStyle(Color("PrimaryText"))
            
            
            NotesPicker(selection: $selection)
            
            ScrollView {
                LazyVStack(spacing: 20) {
                    NotesView(selection: $selection, selectedDate: $selectedDate, onlyShow: true)
                        .environmentObject(model)
                }
            }
            
            
            Spacer()
        }
        .customBgModifier()
    }
}

#Preview {
    CalendarDay(selectedDate: .constant(Date()))
}
