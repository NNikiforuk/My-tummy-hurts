//
//  HomeView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject var model: ViewModel = ViewModel()
    @AppStorage("appearance") private var selectedAppearance: Appearance = .system
    
    @State private var selectedDate: Date = Date()
    @State private var selection: NoteTab = .meals
    
    var emptyDB: Bool {
        model.mealNotes.isEmpty && model.symptomNotes.isEmpty
    }
    
    var alertTitle: String {
        if emptyDB {
            "There is no data to delete"
        } else {
            "Do you want to delete everything?"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case .system:
            return nil
        case .dark:
            return .dark
        case .light:
            return .light
        }
    }
    
    var body: some View {
        VStack {
            HomeViewHeader(selectedDate: $selectedDate)
            AddBtns(selection: $selection)
                .environmentObject(model)
            NotesPicker(selection: $selection)
            ScrollView {
                LazyVStack(spacing: 20) {
                    NotesView(selection: $selection)
                        .environmentObject(model)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    NavigationLink {
                        ThemeView()
                    } label: {
                        Label(LocalizedStringKey("Change theme"), systemImage: "sun.lefthalf.filled")
                    }
                    DeleteBtnTextIcon(title: "Delete all", icon: "trash", action: { model.showDeleteAllAlert = true })
                } label: {
                    Label(LocalizedStringKey("Options"), systemImage: "ellipsis.circle")
                        .font(.callout)
                }
                .foregroundStyle(.primary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
//                    ChartView(meals: meals, symptoms: symptoms)
                } label: {
                    HStack {
                        Image(systemName: "chart.bar")
                            .font(.callout)
                        Text(LocalizedStringKey("Analytics"))
                            .font(.callout)
                    }
                }
            }
        }
        .preferredColorScheme(colorScheme)
        .customBgModifier()
        .sheet(isPresented: $model.showAddingMeal) {
            NavigationStack {
                AddMealView(selectedDate: $selectedDate)
                    .environmentObject(model)
            }
        }
        .sheet(isPresented: $model.showAddingSymptom) {
            NavigationStack {
                AddSymptomView(selectedDate: $selectedDate)
                    .environmentObject(model)
            }
        }
        .alert(LocalizedStringKey(alertTitle), isPresented: $model.showDeleteAllAlert) {
            VStack {
                if emptyDB {
                    CancelBtn(action: {})
                } else {
                    DeleteBtn(action: {
                        model.resetDB()
                    })
                    CancelBtn(action: {})
                }
            }
        }
    }
}

struct NotesPicker: View {
    @Binding var selection: NoteTab
    
    var body: some View {
        HStack {
            Picker("", selection: $selection) {
                ForEach(NoteTab.allCases) { tab in
                    Text(LocalizedStringKey(tab.rawValue)).tag(tab)
                }
            }
            .bold()
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.bottom, 20)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
        }
    }
}
