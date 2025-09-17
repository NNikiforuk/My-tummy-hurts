//
//  HomeView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var model: CoreDataViewModel
//    @StateObject var mv = CoreDataViewModel()
//    @StateObject var model: ViewModel = ViewModel()
    @AppStorage("appearance") private var selectedAppearance: Appearance = .system
    
    @State private var selectedDate: Date = Date()
    @State private var selection: NoteTab = .meals
    
    @State private var showAddingMealView: Bool = false
    @State private var showAddingSymptomView: Bool = false
    @State private var showDeleteAllAlert: Bool = false
    
    var emptyDB: Bool {
        model.savedMealNotes.isEmpty && model.savedSymptomNotes.isEmpty
//        model.mealNotes.isEmpty && model.symptomNotes.isEmpty
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
            AddBtns(selection: $selection, showAddingMealView: $showAddingMealView, showAddingSymptomView: $showAddingSymptomView)
//                .environmentObject(model)
            NotesPicker(selection: $selection)
            ScrollView {
                LazyVStack(spacing: 20) {
                    NotesView(selection: $selection, selectedDate: $selectedDate, onlyShow: false)
//                        .environmentObject(model)
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
                    DeleteBtnTextIcon(title: "Delete all", icon: "trash", action: { showDeleteAllAlert = true })
                } label: {
                    Label(LocalizedStringKey("Options"), systemImage: "ellipsis.circle")
                        .font(.callout)
                }
                .foregroundStyle(.primary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
//                    ChartView()
//                        .environmentObject(model)
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
        .sheet(isPresented: $showAddingMealView) {
//        .sheet(isPresented: $model.showAddingMeal) {
            NavigationStack {
                AddMealView()
//                    .environmentObject(model)
            }
        }
        .foregroundStyle(.accent)
        .sheet(isPresented: $showAddingSymptomView) {
//        .sheet(isPresented: $model.showAddingSymptom) {
            NavigationStack {
                AddSymptomView()
//                    .environmentObject(model)
            }
        }
        .alert(LocalizedStringKey(alertTitle), isPresented: $showDeleteAllAlert) {
//        .alert(LocalizedStringKey(alertTitle), isPresented: $model.showDeleteAllAlert) {
            VStack {
                if emptyDB {
                    CancelBtn(action: {})
                } else {
                    DeleteBtn(action: {
//                        model.resetDB()
                        model.deleteAll()
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
                        .foregroundStyle(Color("PrimaryText"))
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
                .environmentObject(CoreDataViewModel())
        }
    }
}
