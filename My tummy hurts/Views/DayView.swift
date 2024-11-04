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
    
    @State private var showingAddView: Bool = true
    @State private var mealTime: Date = Date()
    @State private var ingredients: String = ""
    @State private var symptomTime: Date = Date()
    @State private var symptoms: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Form {
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
            .toolbar {
                Button {
                    showingAddView.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddView) {
                VStack {
                    HStack {
                        Button("Cancel",
                               action: { showingAddView.toggle() })
                        Spacer()
                        Text("New entry")
                            .bold()
                        Spacer()
                        Button("Save",
                               action: { })
                    }
                    VStack {
                        Form {
                            Section("MEAL") {
                                DatePicker(
                                "Meal time",
                                selection: $mealTime,
                                displayedComponents: [.date, .hourAndMinute]
                                )
                                TextField(
                                        "Ingredients: rye bread, cow milk",
                                        text: $ingredients
                                    )
                            }
                            Section("SYMPTOMS") {
                                DatePicker(
                                "Symptom time",
                                selection: $symptomTime,
                                displayedComponents: [.date, .hourAndMinute]
                                )
                                TextField(
                                        "Symptoms: diarhhea, nusea",
                                        text: $symptoms
                                    )
                            }
                        }
                    }
                    Spacer()
                }
                .presentationDetents([.medium, .large])
                .padding(.top, 20)
                .padding()
            }
        }
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
