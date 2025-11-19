//
//  ChartView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 17/10/2025.
//

import SwiftUI
import Charts

struct ChartView: View {
    @EnvironmentObject private var vm: CoreDataViewModel
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @State private var analyticsType: AnalyticsMode = .barChart
    @State private var chartType: ChartMode = .problematicIngredients
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
    
    var pickerSymptoms: [SymptomNote] {
        vm.savedSymptomNotes.sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SiteTitle(title: "Analytics")
                    .frame(maxWidth: .infinity, alignment: .center)
                ChooseAnalytics(analyticsType: $analyticsType)
                warning
                switch analyticsType {
                case .barChart:
                    VStack(spacing: 40) {
                        SelectChartType(chartType: $chartType)
                        switch chartType {
                        case .problematicIngredients:
                            firstTwoChartsContainer(title: "Top 10 problematic ingredients")
                        case .potentiallySafeIngredients:
                            firstTwoChartsContainer(title: "Potentially safe ingredients")
                        case .checkSpecificSymptom:
                            
                            VStack(alignment: .leading) {
                                if vm.savedSymptomNotes.isEmpty {
                                    SectionTitle(title: "Check specific symptom", textColor: Color("SecondaryText"))
                                        .textCase(.uppercase)
                                    EmptyStateView(text: "Add minimum 1 meal and minimum 1 symptom")
                                        .grayOverlayModifier()
                                } else {
                                    specificSymptom
                                }
                            }
                        }
                    }
                    
                case .calendarView:
                    CalendarChart(selectedFirstIngredient: $selectedFirstIngredient, selectedSecondIngredient: $selectedSecondIngredient, selectedDate: $selectedDate)
                }
            }
            .animation(.easeInOut, value: chartType)
        }
        .customBgModifier()
    }
    
    func firstTwoChartsContainer(title: LocalizedStringKey) -> some View {
        VStack(alignment: .leading) {
            SectionTitle(title: title, textColor: Color("SecondaryText"))
                .textCase(.uppercase)
            VStack {
                if chartType == ChartMode.problematicIngredients {
                    if vm.top10Ingredients.isEmpty {
                        EmptyStateView(text: "Add minimum 1 meal and minimum 1 symptom")
                            .grayOverlayModifier()
                    } else if vm.top10IngredientsTop10.isEmpty {
                        EmptyStateView(text: "No problematic ingredients at this time")
                            .grayOverlayModifier()
                        
                    }  else {
                        ingredientsList
                    }
                } else {
                    if vm.safeIngredients.isEmpty {
                        EmptyStateView(text: "No potentially safe ingredients")
                            .grayOverlayModifier()
                    } else {
                        ingredientsList
                    }
                }
            }
        }
    }
    
    var ingredientsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(chartType == ChartMode.problematicIngredients ? vm.top10IngredientsTop10 : vm.safeIngredients) { ingredient in
                    if chartType == ChartMode.problematicIngredients {
                        HistoricalIngredient(ingredient: ingredient)
                            .frame(maxWidth: .infinity)
                    } else {
                        SafeIngredient(ingredient: ingredient)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
    
    var specificSymptom: some View {
        VStack(alignment: .leading, spacing: 40) {
            howManyHoursBack
            selectSymptom
            VStack(alignment: .leading) {
                SymptomAnalysisView(selectedHourQty: $hoursBack, selectedSymptomId: $selectedSymptomId)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    var howManyHoursBack: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "Time window", textColor: Color("SecondaryText"))
                .textCase(.uppercase)
            Stepper(value: $hoursBack, in: 1...12) {
                Text("\(hoursBack) h")
                    .font(.subheadline)
                    .foregroundStyle(Color("PrimaryText"))
            }
            .grayOverlayModifier()
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
        Picker("Select symptom", selection: $selectedSymptomId) {
            Text("Select symptom").tag(nil as UUID?)
            
            ForEach(pickerSymptoms) { symptom in
                if let time = symptom.createdAt {
                    Text("\(time.formatted(date: .abbreviated, time: .shortened)) – \(symptom.symptom ?? "Unknown")")
                        .tag(symptom.id as UUID?)
                        .tag(symptom.id as UUID?)
                } else {
                    Text(symptom.symptom ?? "Unknown")
                        .tag(symptom.id as UUID?)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .pickerStyle(.menu)
        .grayOverlayModifier()
    }
    
    var warning: some View {
        HStack(alignment: .top) {
            Image(systemName: "cross.case.fill")
                .font(.title3)
                .foregroundColor(.customSecondary)
            Text("The analysis is for informational purposes only. It is not a medical diagnostic tool. Always consult a healthcare professional for medical advice")
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .foregroundColor(.secondary)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("CustomSecondary").opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("SecondaryText").opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct EmptyStateView: View {
    let text: LocalizedStringKey
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct SafeIngredient: View {
    let ingredient: IngredientAnalysis
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                IngredientHistoryHeader(ingredient: ingredient)
                Label("Safe", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
                    .font(.caption)
                    .foregroundColor(.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accent.opacity(0.1))
                    .cornerRadius(8)
            }
            .onTapGesture {
                showDetail = true
            }
            .sheet(isPresented: $showDetail) {
                SheetContent(ingredient: ingredient)
            }
            .grayOverlayModifier()
        }
    }
}

struct IngredientHistoryHeader: View {
    let ingredient: IngredientAnalysis
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(ingredient.name)
                    .bold()
                Spacer()
                
                Text(ingredient.legend)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.accent)
            }
            
            Text("\(ingredient.symptomsOccurrences) / \(ingredient.totalOccurrences)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct HistoricalIngredient: View {
    let ingredient: IngredientAnalysis
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !ingredient.hasEnoughData {
                InsufficientIngredientData(ingredientName: ingredient.name, globalTotalOccurrences: ingredient.totalOccurrences)
                    .grayOverlayModifier()
                
            } else {
                VStack(alignment: .leading) {
                    IngredientHistoryHeader(ingredient: ingredient)
                    bar()
                }
                .onTapGesture {
                    showDetail = true
                }
                .sheet(isPresented: $showDetail) {
                    SheetContent(ingredient: ingredient)
                }
                .grayOverlayModifier()
            }
        }
    }
    
    func bar() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 32)
                    
                    if ingredient.suspicionRate > 0 {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .accent,
                                        .accent.opacity(0.7)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * min(ingredient.suspicionRate, 1.0),
                                height: 32
                            )
                    }
                }
            }
            .frame(height: 32)
        }
    }
}

struct SheetContent: View {
    @Environment(\.dismiss) var dismiss
    let ingredient: IngredientAnalysis
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HeaderCard(suspicionValue: ingredient.suspicionRate, riskLevel: ingredient.riskLevel, circleTitle: "correlation", symptomTime: nil, symptomName: nil)
                    statisticsCard
                    RecommendationsCard(recommendations: recommendations)
                    howItWorksCard
                    
                }
                .padding()
            }
            .navigationTitle(ingredient.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .grayOverlayModifier()
    }
    
    var statisticsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            statisticsRow(title: "Total meals with ingredient", number: ingredient.totalOccurrences, icon: "fork.knife")
            Divider()
            statisticsRow(title: "Total symptoms within 8 hours after ingredient", number: ingredient.symptomsOccurrences, icon: "exclamationmark.triangle.fill")
            Divider()
            statisticsRow(title: "Symptom-free meals", number: ingredient.safeOccurrences, icon: "checkmark.circle.fill")
            
            
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.customSecondary)
                Text("Enough data for reliable analysis")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("CustomSecondary").opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color("SecondaryText").opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding()
        .grayOverlayModifier()
    }
    
    func statisticsRow(title: LocalizedStringKey, number: Int, icon: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(number)")
                .font(.title2)
                .bold()
                .foregroundStyle(.accent)
        }
    }
    
    var howItWorksCard: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "How we calculate correlation", textColor: .secondary)
                .textCase(.uppercase)
            
            VStack(alignment: .leading, spacing: 16) {
                explanationRow(
                    title: "Time-weighted analysis",
                    description: "We track symptoms within 8 hours after meals. Symptoms that occur closer to meal time receive higher weight in the calculation"
                )
                
                explanationRow(
                    title: "Pattern detection",
                    description: "The correlation percentage shows how often this ingredient was followed by symptoms across all your tracked meals"
                )
                
                explanationRow(
                    title: "Reliability",
                    description: "We need at least 3 meals with this ingredient to provide reliable analysis. More data means more accurate results"
                )
            }
            .grayOverlayModifier()
        }
    }
    
    func explanationRow(title: LocalizedStringKey, description: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    var recommendations: [LocalizedStringKey] {
        var recs: [LocalizedStringKey] = []
        
        switch ingredient.suspicionRate {
        case 0:
            recs.append("This ingredient has not shown any association with symptoms based on existing records")
            recs.append("Continue enjoying this ingredient. It appears safe for you")
            recs.append("Keep tracking to maintain accurate data")
        case 0..<0.3:
            recs.append("According to existing records, symptoms occurred within 8 hours in a few cases")
            recs.append("This may be coincidental or affected by other factors")
            recs.append("Monitor for any changes in your reaction over time")
            recs.append("Track a few more meals to improve accuracy")
        case 0.3..<0.6:
            recs.append("Symptoms appeared in several cases recorded with this ingredient")
            recs.append("Testing different combinations or amounts may help confirm the pattern")
            recs.append("Pay attention to portion sizes - smaller amounts might be tolerable")
            recs.append("Try eating this ingredient separately to isolate its effect")
            recs.append("Track a few more meals to improve accuracy")
        case 0.6..<0.8:
            recs.append("A notable share of meals involving this ingredient were followed by symptoms")
            recs.append("Consider temporarily reducing intake or adjusting portion sizes")
            recs.append("If you do eat it, track carefully to confirm the pattern")
            recs.append("Track a few more meals to improve accuracy")
            recs.append("Discuss with your healthcare provider")
        default:
            recs.append("The data suggests potential sensitivity to this ingredient")
            recs.append("Trying smaller portions, alternative preparations or temporary elimination may help evaluate its impact")
            recs.append("Track a few more meals to improve accuracy")
            recs.append("If symptoms are severe, seek medical attention")
        }
        
        return recs
    }
}


struct SymptomAnalysisView: View {
    @EnvironmentObject var vm: CoreDataViewModel
    @Binding var selectedHourQty: Int
    @Binding var selectedSymptomId: UUID?
    
    var data: [IngredientAnalysis2] {
        vm.getSecondChartData(symptomId: selectedSymptomId, hours: selectedHourQty)
    }
    
    var potentialTriggers: [IngredientAnalysis2] {
        data.filter { ingredient in
            guard ingredient.historicalData != nil else { return false }
            guard ingredient.usedHistoricalData else { return false }
            guard ingredient.suspicionScore > 0 else { return false }
            return !ingredient.isSafe
        }
    }
    
    var safeIngredients: [IngredientAnalysis2] {
        data.filter { ingredient in
            guard ingredient.historicalData != nil else { return false }
            return ingredient.isSafe
        }
    }
    
    var uncertainIngredients: [IngredientAnalysis2] {
        data.filter { ingredient in
            guard ingredient.historicalData != nil else { return false }
            return !ingredient.usedHistoricalData && !ingredient.isSafe
        }
    }
    
    var newIngredients: [IngredientAnalysis2] {
        data.filter { ingredient in
            ingredient.historicalData == nil
        }
    }
    
    var symptomTime: Date? {
        vm.savedSymptomNotes.first { $0.id == selectedSymptomId }?.createdAt
    }
    
    var symptomName: String? {
        vm.savedSymptomNotes.first { $0.id == selectedSymptomId }?.symptom
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            if potentialTriggers.isEmpty && safeIngredients.isEmpty && uncertainIngredients.isEmpty && newIngredients.isEmpty {
                EmptyStateView(text: "No correlation with this symptom")
                    .grayOverlayModifier()
            }
            
            if !potentialTriggers.isEmpty {
                VStack(alignment: .leading) {
                    SectionTitle(title: "Potential triggers", textColor: Color("SecondaryText"))
                        .textCase(.uppercase)
                    SectionView(
                        iconColor: .red,
                        ingredients: potentialTriggers,
                        symptomTime: symptomTime,
                        symptomName: symptomName
                    )
                }
            }
            
            if !safeIngredients.isEmpty {
                VStack(alignment: .leading) {
                    SectionTitle(title: "Safe ingredients", textColor: Color("SecondaryText"))
                        .textCase(.uppercase)
                    SectionView(
                        iconColor: .green,
                        ingredients: safeIngredients,
                        symptomTime: symptomTime, symptomName: symptomName
                    )
                }
            }
            
            if !uncertainIngredients.isEmpty {
                VStack(alignment: .leading) {
                    SectionTitle(title: "Insufficient data", textColor: Color("SecondaryText"))
                        .textCase(.uppercase)
                    SectionView(
                        iconColor: .orange,
                        ingredients: uncertainIngredients,
                        symptomTime: symptomTime,
                        symptomName: symptomName
                    )
                }
            }
            
            if !newIngredients.isEmpty {
                VStack(alignment: .leading) {
                    SectionTitle(title: "New ingredients", textColor: Color("SecondaryText"))
                        .textCase(.uppercase)
                    SectionView(
                        iconColor: .blue,
                        ingredients: newIngredients,
                        symptomTime: symptomTime,
                        symptomName: symptomName
                    )
                }
            }
        }
        .onAppear {
            if selectedSymptomId == nil {
                selectedSymptomId = vm.savedSymptomNotes.first?.id
            }
        }
    }
}

struct SectionView: View {
    let iconColor: Color
    let ingredients: [IngredientAnalysis2]
    let symptomTime: Date?
    let symptomName: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(ingredients) { ingredient in
                IngredientAnalysis2Row(ingredient: ingredient, symptomTime: symptomTime, symptomName: symptomName)
            }
        }
        .grayOverlayModifier()
    }
}

struct InsufficientIngredientData: View {
    let ingredientName: String
    let globalTotalOccurrences: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(ingredientName)
                .bold()
            HStack(alignment: .top) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Insufficient data")
                        .font(.caption)
                        .bold()
                    
                    Text("Meals with this ingredient: \(globalTotalOccurrences)")
                        .font(.caption2)
                    
                    Text("Need minimum 3 for accuracy")
                        .font(.caption2)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.accent)
            .padding(12)
            .background(Color.accent.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct IngredientAnalysis2Row: View {
    let ingredient: IngredientAnalysis2
    let symptomTime: Date?
    let symptomName: String?
    
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if ingredient.historicalData == nil || !ingredient.usedHistoricalData {
                InsufficientIngredientData(ingredientName: ingredient.name, globalTotalOccurrences: ingredient.globalTotalOccurrences)
            } else {
                VStack(alignment: .leading) {
                    HStack {
                        Text(ingredient.name)
                            .bold()
                        
                        Spacer()
                        
                        Text(ingredient.legend)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.accent)
                    }
                    
                    if let historical = ingredient.historicalData {
                        Text("\(historical.symptomsOccurrences) / \(historical.totalOccurrences)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 32)
                            
                            if ingredient.suspicionScore > 0 {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [.accent, .accent.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * ingredient.suspicionScore,
                                        height: 32
                                    )
                            }
                        }
                    }
                    .frame(height: 32)
                }
                .onTapGesture {
                    showDetail = true
                }
                .sheet(isPresented: $showDetail) {
                    SheetContentSpecificSymptom(ingredient: ingredient, symptomTime: symptomTime, symptomName: symptomName)
                }
            }
        }
    }
}

struct RecommendationsCard: View {
    let recommendations: [LocalizedStringKey]
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "Recommendations", textColor: .secondary)
                .textCase(.uppercase)
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(recommendations.indices, id: \.self) { idx in
                    let recommendation = recommendations[idx]
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accent)
                        
                        Text(recommendation)
                            .foregroundColor(.accent)
                            .font(.subheadline)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .grayOverlayModifier()
        }
    }
}

struct RiskExplanationCard: View {
    let riskExplanation: LocalizedStringKey
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "What does this mean?", textColor: .secondary)
                .textCase(.uppercase)
            
            Text(riskExplanation)
                .foregroundColor(.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .grayOverlayModifier()
                .frame(maxWidth: .infinity)
        }
    }
    
    
}

struct HeaderCard: View {
    let suspicionValue: Double
    let riskLevel: LocalizedStringKey
    let circleTitle: LocalizedStringKey
    let symptomTime: Date?
    let symptomName: String?
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: suspicionValue)
                    .stroke(.accent, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: suspicionValue)
                
                VStack(spacing: 4) {
                    Text("\(Int(min(suspicionValue, 1.0) * 100))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.accent)
                    
                    Text(circleTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if circleTitle == "Suspicion" {
                if let selectedSymptomTime = symptomTime, let selectedSymptomName = symptomName {
                    VStack(spacing: 4) {
                        Text("Selected symptom: \(selectedSymptomName.lowercased())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(selectedSymptomTime, format: .dateTime.day().month().year())
                            .font(.subheadline)
                            .bold()
                        
                        Text("at \(selectedSymptomTime, format: .dateTime.hour().minute())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(riskLevel)
                .font(.headline)
                .foregroundColor(.background)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(.accent)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

struct SheetContentSpecificSymptom: View {
    @Environment(\.dismiss) var dismiss
    
    let ingredient: IngredientAnalysis2
    let symptomTime: Date?
    let symptomName: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HeaderCard(suspicionValue: ingredient.suspicionScore, riskLevel: ingredient.riskLevel, circleTitle: "correlation", symptomTime: symptomTime, symptomName: symptomName)
                    RecommendationsCard(recommendations: recommendations)
                    howScoreWorksCard
                    disclaimerCard
                }
                .padding()
            }
            .navigationTitle(ingredient.name.capitalized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .customBgModifier()
    }
    
    func createIcon(icon: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.customSecondary.opacity(0.1))
                .frame(width: 50, height: 50)
            
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.customSecondary)
        }
    }
    
    func timingAnalysisRow(icon: String, value: String, firstText: LocalizedStringKey, secondText: LocalizedStringKey? = nil) -> some View {
        HStack(spacing: 12) {
            createIcon(icon: icon)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .bold()
                
                Text(firstText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let additionalText = secondText {
                    Text(additionalText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
        }
    }
    
    var howScoreWorksCard: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "How the score is calculated", textColor: .secondary)
                .textCase(.uppercase)
            
            VStack(alignment: .leading, spacing: 16) {
                calculationRow(
                    icon: "clock.fill",
                    title: "Time proximity",
                    description: "How recently this was consumed. More recent = higher weight"
                )
                
                Text("×")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                calculationRow(
                    icon: "chart.bar.fill",
                    title: "Historical correlation",
                    description: ingredient.usedHistoricalData ? "Based on your past meals with this ingredient" : "Baseline estimate - not enough data yet"
                )
                
                HStack(alignment: .center) {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "equal")
                            .foregroundColor(.accent)
                        Text("\(Int(ingredient.suspicionScore * 100))%")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.accent)
                    }
                    Spacer()
                }
            }
            .grayOverlayModifier()
        }
    }
    
    func calculationRow(icon: String, title: LocalizedStringKey, description: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.customSecondary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                
                Text(description)
                    .font(.caption)
            }
            
        }
        .frame(maxWidth: .infinity)
        .grayOverlayModifier()
    }
    
    var recommendations: [LocalizedStringKey] {
        var recs: [LocalizedStringKey] = []
        
        if !ingredient.usedHistoricalData {
            recs.append("Track more meals with this ingredient to build reliable data")
            recs.append("Pay attention to portion sizes and preparation methods")
            recs.append("Note other factors like stress or sleep when symptoms occur")
            return recs
        }
        
        switch ingredient.suspicionScore {
        case 0..<0.3:
            recs.append("This ingredient is likely not the main cause of this symptom")
            recs.append("Continue tracking to monitor for any pattern changes")
            recs.append("Consider other ingredients or factors that might be involved")
            
        case 0.3..<0.5:
            recs.append("Worth monitoring this ingredient more closely")
            recs.append("Try eating it at different times of day to see if timing matters")
            recs.append("Notice if symptoms vary with portion size or preparation")
            
        case 0.5..<0.7:
            recs.append("Consider temporarily reducing intake to test the pattern")
            recs.append("If you do eat it, track carefully to confirm the association")
            recs.append("Try it in isolation (not with other potentially triggering foods)")
            
        default:
            recs.append("Strong evidence this ingredient may trigger symptoms")
            recs.append("Consider avoiding it before important events or activities")
            recs.append("If you try it again, start with very small amounts")
            recs.append("Track any reintroduction attempts carefully")
        }
        
        if !ingredient.hasEnoughData {
            recs.append("Track more meals with this ingredient to build reliable data")
        }
        
        return recs
    }
    
    var disclaimerCard: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "About this analysis", textColor: .secondaryText)
                .textCase(.uppercase)
            VStack {
                Text("This score identifies potential connections based on timing and your historical patterns. It's a helpful tool for investigation, not a definitive diagnosis. Many factors can influence symptoms, and correlation doesn't always mean causation")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .grayOverlayModifier()
        }
    }
    
    var formattedTimeAgo: String {
        let hours = Int(ingredient.howLongAgo)
        let minutes = Int((ingredient.howLongAgo - Double(hours)) * 60)
        
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
}

struct ChooseAnalytics: View {
    @Binding var analyticsType: AnalyticsMode
    
    var body: some View {
        VStack {
            Picker("Choose analytics", selection: $analyticsType) {
                ForEach(AnalyticsMode.allCases) { el in
                    Text(el.localized)
                }
            }
        }
        .pickerStyle(.segmented)
    }
}

struct HowManyHoursBack: View {
    @Binding var value: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "Time window", textColor: Color("SecondaryText"))
                .textCase(.uppercase)
            Stepper(value: $value, in: 1...12) {
                Text("\(value) h")
                    .font(.subheadline)
                    .foregroundStyle(Color("PrimaryText"))
            }
            .grayOverlayModifier()
        }
    }
}

struct SelectChartType: View {
    @Binding var chartType: ChartMode
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "Select chart type", textColor: Color("SecondaryText"))
                .textCase(.uppercase)
            VStack(spacing: 10) {
                SelectableCard(
                    title: ChartMode.problematicIngredients.localized,
                    isSelected: chartType == ChartMode.problematicIngredients,
                    onTap: { chartType = ChartMode.problematicIngredients })
                
                SelectableCard(
                    title: ChartMode.potentiallySafeIngredients.localized,
                    isSelected: chartType == ChartMode.potentiallySafeIngredients,
                    onTap: { chartType = ChartMode.potentiallySafeIngredients })
                
                SelectableCard(
                    title: ChartMode.checkSpecificSymptom.localized,
                    isSelected: chartType == ChartMode.checkSpecificSymptom,
                    onTap: { chartType = ChartMode.checkSpecificSymptom })
            }
            .grayOverlayModifier()
            .contentShape(Rectangle())
        }
        .padding(.top, 10)
    }
}

struct SelectableCard: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .imageScale(.large)
                    .foregroundStyle(isSelected ? .accent : Color("SecondaryText"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}

#Preview() {
    NavigationStack {
        ChartView()
            .environmentObject(CoreDataViewModel())
    }
}
