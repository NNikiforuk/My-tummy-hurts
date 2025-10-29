//
//  TestView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 17/10/2025.
//

import SwiftUI
import Charts

struct TestView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @State private var analyticsType: AnalyticsMode = .barChart
    @State private var chartType: ChartMode = .checkSpecificSymptom
    @State private var hoursBack = 5
    @State private var selectedSymptomId: UUID? = nil
    @State private var selectedFirstIngredient: String? = nil
    @State private var selectedSecondIngredient: String? = nil
    @State private var selectedDate: Date = Date()
    @State private var showInfo: Bool = false
    
    let ingredientsToShow = 5
    
    var noMealNotes: Bool {
        vm.savedMealNotes.isEmpty
    }
    var noSymptomNotes: Bool {
        vm.savedSymptomNotes.isEmpty
    }
    
    var listItems1: [String] = [
        "Risk percentage (%) - how often symptoms occur", "Number of times eaten. More data - more reliable"]
    var listItems2: [String] = [
        "100% from one meal - might be coincidence", "80% from ten meals - strong pattern"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SiteTitle(title: "Analytics")
                    .frame(maxWidth: .infinity, alignment: .center)
                ChooseAnalytics(analyticsType: $analyticsType)
                
                switch analyticsType {
                case .barChart:
                    VStack(spacing: 40) {
                        SelectChartType(chartType: $chartType)
                        switch chartType {
                        case .defaultChart:
                            top10Ingredients
                        case .checkSpecificSymptom:
                            specificSymptom
                        }
                    }
                    
                case .calendarView:
                    Text("bla")
                    //                    if firstChartData.isEmpty && secondChartData.isEmpty {
                    //                        NoDataAlert(text: "Add more meals and symptoms")
                    //                    } else {
                    //                        CalendarChart(selectedFirstIngredient: $selectedFirstIngredient, selectedSecondIngredient: $selectedSecondIngredient, selectedDate: $selectedDate)
                    //                    }
                }
            }
            .animation(.easeInOut, value: chartType)
        }
        .customBgModifier()
    }
    
    var showInfoBtn: some View {
        Button {
            showInfo.toggle()
        } label: {
            HStack {
                SectionTitle(title: "Top 10 ingredients by risk", textColor: Color("SecondaryText"))
                    .textCase(.uppercase)
                Spacer()
                Image(systemName: "info.circle")
            }
            .foregroundStyle(.secondary)
        }
    }
    
    var legend: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ingredients are ranked by risk score which considers:")
                .bold()
            list(items: listItems1)
            Text("Why isn't 100% always first?")
                .bold()
                .padding(.top, 20)
            list(items: listItems2)
        }
        .padding()
        .foregroundStyle(.secondary)
        .grayOverlayModifier()
    }
    
    func list(items: [String]) -> some View {
        VStack(alignment: .leading,
               spacing: 10) {
            ForEach(items, id: \.self) { data in
                HStack(alignment: .top) {
                    Text("•")
                    Text(data)
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                }
            }
        }
    }
    
    var top10Ingredients: some View {
        VStack {
            showInfoBtn
            if showInfo {
                legend
            }
            if vm.firstChartData.isEmpty {
                EmptyStateView(subheadline: "Add more meals and symptoms")
            } else {
                ColumnChart(data: vm.firstChartData)
            }
        }
    }
    
    var specificSymptom: some View {
        VStack(alignment: .leading, spacing: 40) {
            HowManyHoursBack(value: $hoursBack)
            selectSymptom
            VStack {
                sectionTitle
                TimelineChart(selectedSymptomId: $selectedSymptomId, hoursBack: $hoursBack)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    var sectionTitle: some View {
        HStack {
            SectionTitle(title: "Events timeline", textColor: Color("SecondaryText"))
                .textCase(.uppercase)
            Spacer()
        }
    }
    
    var selectSymptom: some View {
        VStack {
            HStack {
                SectionTitle(title: "Select symptom", textColor: Color("SecondaryText"))
                    .textCase(.uppercase)
                Spacer()
            }
            symptomPicker
        }
    }
    
    var symptomPicker: some View {
        VStack(alignment: .leading) {
            Picker("", selection: $selectedSymptomId) {
                ForEach(vm.savedSymptomNotes) { symptom in
                    if let date = symptom.createdAt,
                       let symptomText = symptom.symptom {
                        Text("\(date.formatted(.dateTime.day().month(.abbreviated).year().hour().minute())) – \(symptomText)")
                            .tag(symptom.id)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .pickerStyle(.menu)
            .padding(5)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("BackgroundColor"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("SecondaryText").opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

struct ColumnChart: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @State private var selectedIngredient: IngredientAnalysis?
    
    let data: [IngredientAnalysis]
    
    var body: some View {
        VStack(spacing: 20) {
                VStack(spacing: 25) {
                    ForEach(data) { ingredient in
                        IngredientRow(ingredient: ingredient)
                            .onTapGesture {
                                selectedIngredient = ingredient
                            }
                    }
                }
        }
        .grayOverlayModifier()
        .sheet(item: $selectedIngredient) { ingredient in
            IngredientDetailView(ingredient: ingredient)
        }
    }
}

struct TimelineChart: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Environment(\.dynamicTypeSize) var sizeCategory
    @Binding var selectedSymptomId: UUID?
    @Binding var hoursBack: Int
    @State private var selectedIngredient: IngredientAnalysis?
    @State private var showPop: Bool = false
    
    var data: [Event] {
        vm.horizontalData(selectedSymptomId: selectedSymptomId, selectedHourQty: hoursBack)
    }
    
    var chartStart: Date? {
        vm.startTime(selectedSymptomId: selectedSymptomId, selectedHourQty: hoursBack)
    }
    
    var chartEnd: Date? {
        guard let symptom = vm.findSpecificSymptom(selectedSymptomId: selectedSymptomId) else { return nil }
        guard let symptomTime = symptom.createdAt else { return nil }
        return symptomTime
    }
    
    var selectedSymptomName: String? {
        guard let symptom = vm.findSpecificSymptom(selectedSymptomId: selectedSymptomId) else { return nil }
        guard let symptomDesc = symptom.symptom else { return nil }
        return symptomDesc
    }
    
    var body: some View {
        VStack {
            if let start = chartStart, let end = chartEnd {
                ScrollView(.horizontal) {
                    Chart(data) { event in
                        PointMark(x: .value("Time", event.date)
                        )
                        .symbol {
                                Image(systemName: event.icon)
                                    .foregroundColor(event.icon == "toilet" ? .accent : Color("PrimaryText"))
                                    .font(sizeCategory.isAccessibilitySize ? .body :  .system(size: 17))
                            }
                    }
                    .chartXScale(domain: start...(end.addingTimeInterval(60 * 60)))
                    .chartXAxis {
                        AxisMarks(position: .bottom, values: .automatic(desiredCount: 10)) { value in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel(format: .dateTime.hour().minute(.twoDigits))
                        }
                    }

                    .frame(width: UIScreen.main.bounds.width * 2, height: 100)
                    .padding()
                    legend
                }
                .grayOverlayModifier()
                
//                ColumnChart()
//                    .padding(.top, 30)
                
            } else {
                EmptyStateView(subheadline: "Select symptom")
                    .grayOverlayModifier()
            }
        }
    }
    
    var legend: some View {
        HStack(alignment: .center, spacing: 30) {
            legendItem(icon: "fork.knife", text: "meal", color: Color("PrimaryText"))
            legendItem(icon: "toilet", text: selectedSymptomName ?? "", color: .accent)
            Spacer()
        }
        .font(.caption2)
        .padding(.vertical, 20)
    }
    
    func legendItem(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.body)
            Text(text)
                .foregroundStyle(Color("PrimaryText"))
        }
    }
}

struct EmptyStateView: View {
    let subheadline: LocalizedStringKey
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No data available for analysis")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(subheadline)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct IngredientRow: View {
    let ingredient: IngredientAnalysis
    
    var body: some View {
        VStack(spacing: 8) {
            ingredientTop
            ingredientBottom
        }
    }
    
    var ingredientSmallData: some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: "info.circle")
            Text("Insufficient data - results may be inaccurate")
        }
        .frame(maxWidth: .infinity)
        .font(.caption)
        .foregroundColor(.red)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.red).opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    var ingredientTop: some View {
        HStack(alignment: .center) {
            ingredientName
            Spacer()
            ingredientPercentage
        }
    }
    
    var ingredientBottom: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 32)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    ingredient.colorIntensity,
                                    ingredient.colorIntensity.opacity(0.7)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * ingredient.suspicionRate,
                            height: 32
                        )
                    
                    if ingredient.suspicionRate > 0.3 {
                        HStack {
                            Text(ingredient.riskLevel)
                                .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.leading, 8)
                            Spacer()
                        }
                    }
                }
            }
            .frame(height: 32)
            
            if !ingredient.hasEnoughData {
                ingredientSmallData
            }
        }
    }
    
    var ingredientName: some View {
        HStack {
            Circle()
                .fill(ingredient.colorIntensity)
                .frame(width: 15, height: 15)
            
            Text(ingredient.name)
                .bold()
            
            if !ingredient.hasEnoughData {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            }
        }
    }
    
    var ingredientPercentage: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(ingredient.legend)
                .font(.headline)
            
            Text("\(ingredient.symptomsOccurrences) z \(ingredient.totalOccurrences)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct IngredientDetailView: View {
    let ingredient: IngredientAnalysis
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    symptomsFrequency
                    details
                    
                    if !ingredient.hasEnoughData {
                        moreDataNeeded
                    }
                    
                    if ingredient.suspicionRate > 0.6 {
                        additionalInfo(title: "Recommendation", titleColor: .red.opacity(0.7), icon: "lightbulb.fill", text: "This ingredient is often associated with symptoms. Consider eliminating it for 2-4 weeks to see if the symptoms subside")
                    }
                    
                    additionalInfo(title: "How does it works", titleColor: .primaryText, icon: "questionmark", text: "We analyze the percentage of meals containing the ingredient after which the symptom occurred. The higher the percentage, the greater the likelihood that the ingredient is the cause of the symptoms")
                }
            }
            .navigationTitle(ingredient.name)
            .navigationBarTitleDisplayMode(.large)
            .customBgModifier()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zamknij") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    var symptomsFrequency: some View {
        VStack(spacing: 8) {
            Text(ingredient.legend)
                .font(.system(size: 64, weight: .bold))
            
            Text("frequency of symptoms")
        }
        .foregroundStyle(.accent)
        .frame(maxWidth: .infinity)
        .grayOverlayModifier()
    }
    
    var details: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Risk level",
                value: ingredient.riskLevel,
            )
            
            Divider()
            
            DetailRow(
                icon: "fork.knife",
                title: "Meals in total",
                value: "\(ingredient.totalOccurrences)",
            )
            
            Divider()
            
            DetailRow(
                icon: "exclamationmark.triangle.fill",
                title: "Meals with symptoms",
                value: "\(ingredient.symptomsOccurrences)",
            )
            
            Divider()
            
            DetailRow(
                icon: "checkmark.circle.fill",
                title: "Meals without symptoms",
                value: "\(ingredient.safeOccurrences)",
            )
        }
        .grayOverlayModifier()
    }
    
    func additionalInfo(title: LocalizedStringKey, titleColor: Color, icon: String, text: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(titleColor)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .grayOverlayModifier()
    }
    
    var moreDataNeeded: some View {
        VStack(alignment: .center, spacing: 8) {
            Label("More data needed", systemImage: "info.circle.fill")
                .font(.headline)
            
            Text("Collect more observations (minimum 3-5) to obtain more reliable analysis results")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CustomSecondary").opacity(0.5))
        )
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
            Spacer()
            Text(value)
                .bold()
                .foregroundStyle(.secondary)
        }
    }
}

#Preview() {
    NavigationStack {
        TestView()
            .environmentObject(CoreDataViewModel.preview)
    }
}
