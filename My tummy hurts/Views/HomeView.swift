//
//  HomeView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
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
    
    var alertTitle: LocalizedStringKey {
        emptyDB ? "Nothing to delete" : "Do you want to delete everything?"
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
            ScrollView {
                HomeViewHeader(selectedDate: $selectedDate)
                AddBtns(selection: $selection, showAddingMealView: $showAddingMealView, showAddingSymptomView: $showAddingSymptomView)
                NotesPicker(selection: $selection)
                ScrollView {
                    LazyVStack(spacing: 20) {
                        NotesView(selection: $selection, selectedDate: $selectedDate, onlyShow: false)
                    }
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
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundColorSegmentedControl: Color {
        return colorScheme == .dark ? .gray.opacity(0.4) : .gray.opacity(0.14)
    }
    
    var selectedButtonBackgroundColor: Color {
        return colorScheme == .dark ? .white.opacity(0.4) : .white
    }
    
    var body: some View {
        HStack {
            Picker("", selection: $selection) {
                ForEach(NoteTab.allCases) { tab in
                    Text(tab.localized)
                        .tag(tab)
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

#Preview("HomeView") {
    NavigationStack {
        HomeView(isOnboarding: .constant(false))
            .environmentObject(CoreDataViewModel())
    }
}
