//
//  HomeView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var model: CoreDataViewModel
    @Binding var isOnboarding: Bool
    @AppStorage("appearance") private var selectedAppearance: Appearance = .system
    
    @State private var selectedDate: Date = Date()
    @State private var selection: NoteTab = .meals
    
    @State private var showAddingMealView: Bool = false
    @State private var showAddingSymptomView: Bool = false
    @State private var showDeleteAllAlert: Bool = false
    
    var emptyDB: Bool {
        model.savedMealNotes.isEmpty && model.savedSymptomNotes.isEmpty
    }
    
    var alertTitle: String {
        if emptyDB {
            "Nothing to delete"
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
            NotesPicker(selection: $selection)
            ScrollView {
                LazyVStack(spacing: 20) {
                    NotesView(selection: $selection, selectedDate: $selectedDate, onlyShow: false)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    NavigationLink {
                        WelcomeView(isOnboarding: $isOnboarding)
                    } label: {
                        Label("Onboarding", systemImage: "book")
                    }
                    NavigationLink {
                        ThemeView()
                    } label: {
                        Label("Change theme", systemImage: "sun.lefthalf.filled")
                    }
                    DeleteBtnTextIcon(title: "Delete all", icon: "trash", action: { showDeleteAllAlert = true })
                } label: {
                    Label("Options", systemImage: "ellipsis")
                        .font(.callout)
                }
                .foregroundStyle(.primary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ChartView()
                } label: {
                    HStack {
                        Image(systemName: "chart.bar")
                            .font(.callout)
                        Text("Analytics")
                            .font(.callout)
                    }
                }
            }
        }
        .preferredColorScheme(colorScheme)
        .customBgModifier()
        .sheet(isPresented: $showAddingMealView) {
            NavigationStack {
                AddMealView()
            }
        }
        .foregroundStyle(.accent)
        .sheet(isPresented: $showAddingSymptomView) {
            NavigationStack {
                AddSymptomView()
            }
        }
        .alert(alertTitle, isPresented: $showDeleteAllAlert) {
            VStack {
                if emptyDB {
                    CancelBtn(action: {})
                } else {
                    DeleteBtn(action: {
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
                    Text(tab.rawValue).tag(tab)
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
            HomeView(isOnboarding: .constant(false))
                .environmentObject(CoreDataViewModel())
        }
    }
}
