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
    
    @State private var entries: [UserData] = []
    @State private var mealTime: String = ""
    @State private var ingredients: String = ""
    @State private var symptomTime: String = ""
    @State private var symptom: String = ""
    
    @State var date = Calendar.current.nextDate(after: Date(), matching: .init(hour: 8), matchingPolicy: .strict)!
    @State var timeString = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section
                {
                    Section {
                        DatePicker("Meal/drink time", selection: $date, displayedComponents: .hourAndMinute)
                            .onChange(of: date) {
                                formatTime()
                            }
                        TextField("Meal/drink ingredients", text: $ingredients)
                    }
                    Section {
                        TextField("Symptoms :(", text: $ingredients)
                    }
                }
                Section {
                    Text("Added today:")
                    VStack {
                        VStack {
                            Grid {
                                GridRow {
                                    HStack {
                                        Image(systemName: "fork.knife")
                                        Text("07:30")
                                    }
                                    Spacer()
                                    HStack {
                                        HStack {
                                            CustomButtonIcon(iconName: "square.and.pencil.circle.fill", clicked: {})
                                            CustomButtonIcon(iconName: "trash.circle.fill", clicked: {})
                                        }
                                    }
                                }
                            }
                            Grid {
                                GridRow {
                                    HStack {
                                        Image(systemName: "fork.knife")
                                        Text("17:30")
                                    }
                                    Spacer()
                                    HStack {
                                        HStack {
                                            CustomButtonIcon(iconName: "square.and.pencil.circle.fill", clicked: {})
                                            CustomButtonIcon(iconName: "trash.circle.fill", clicked: {})
                                        }
                                    }
                                }
                                GridRow {
                                    HStack {
                                        Image(systemName: "fork.knife")
                                        Text("22:30")
                                    }
                                    Spacer()
                                    HStack {
                                        HStack {
                                            CustomButtonIcon(iconName: "square.and.pencil.circle.fill", clicked: {})
                                            CustomButtonIcon(iconName: "trash.circle.fill", clicked: {})
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("\(formatDate())")
    }
    
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: selectedDate)
    }
    
    private func formatTime() {
        var timeFormatter : DateFormatter {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "tr_TR") // your locale here
            return formatter
        }
        
        timeString = timeFormatter.string(from: date)
    }
}

#Preview {
    DayView(selectedDate: Date(), selectedDay: 0)
}
