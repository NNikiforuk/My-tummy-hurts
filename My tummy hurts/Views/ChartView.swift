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
                ChooseAnalytics(analyticsType: $analyticsType)
                
                switch analyticsType {
                case .barChart:
                    VStack {
                        warning
                        VStack(spacing: 40) {
                            SelectChartType(chartType: $chartType)
                            switch chartType {
                            case .problematicIngredients:
                                firstTwoChartsContainer
                            case .potentiallySafeIngredients:
                                firstTwoChartsContainer
                            case .checkSpecificSymptom:
                                
                                VStack(alignment: .leading) {
                                    if vm.savedSymptomNotes.isEmpty {
                                        EmptyStateView(text: "Add minimum 1 meal and minimum 1 symptom")
                                            .grayOverlayModifier()
                                    } else {
                                        specificSymptom
                                    }
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
    
    var firstTwoChartsContainer: some View {
        VStack(alignment: .leading) {
            if chartType == ChartMode.problematicIngredients {
                if vm.top10Ingredients.isEmpty {
                    EmptyStateView(text: "Add minimum 1 meal and minimum 1 symptom")
                        .grayOverlayModifier()
                } else if vm.top10IngredientsTop10.isEmpty {
                    EmptyStateView(text: "No pattern found")
                        .grayOverlayModifier()
                    
                }  else {
                    ingredientsList
                }
            } else {
                if vm.safeIngredients.isEmpty {
                    EmptyStateView(text: "No pattern found")
                        .grayOverlayModifier()
                } else {
                    ingredientsList
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
            Image(systemName: "info.circle")
                .font(.title3)
                .foregroundColor(.customSecondary)
            Text("The patterns shown are based only on your own entries and do not constitute medical advice. Always talk to a doctor before making changes to your diet")
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
                Label("No pattern detected", systemImage: "checkmark.circle.fill")
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
                    HeaderCard(suspicionValue: ingredient.suspicionRate, circleTitle: "pattern score", symptomTime: nil, symptomName: nil)
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
            statisticsRow(title: "Symptom entries within 8 hours after the meal", number: ingredient.symptomsOccurrences, icon: "exclamationmark.triangle.fill")
            Divider()
            statisticsRow(title: "Meals without a symptom entry", number: ingredient.safeOccurrences, icon: "checkmark.circle.fill")
            
            
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.customSecondary)
                Text("Sufficient amount of data")
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
            SectionTitle(title: "How patterns are detected", textColor: .secondary)
                .textCase(.uppercase)
            
            VStack(alignment: .leading, spacing: 16) {
                explanationRow(
                    title: "Time window",
                    description: "The analysis includes symptom entries that you logged within 8 hours after a meal containing this ingredient. Entries closer to the meal have a slightly higher influence on the score"
                )
                
                explanationRow(
                    title: "Pattern detection",
                    description: "The pattern score (0–100%) describes how often this ingredient and the selected symptom appear together in your log within this 8-hour window"
                )
                
                explanationRow(
                    title: "Data reliability",
                    description: "At least 3 meals with this ingredient are needed to calculate the score. The more entries you log, the more stable the patterns become"
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
            recs.append("You haven't logged any symptom entries within 8 hours after meals with this ingredient so far")
            recs.append("Keep logging meals and notes to see if anything changes over time")
            
        case 0..<0.3:
            recs.append("This ingredient and your symptom only appeared together in a few of your entries")
            recs.append("This may be due to coincidence or other factors")
            recs.append("Keep logging meals and notes to get a clearer picture over time")
            
        case 0.3..<0.6:
            recs.append("This ingredient and your symptom appeared together in some of your entries")
            recs.append("This shows co-occurrence in your diary, not a proven cause")
            recs.append("Keep logging meals and notes to see whether this pattern becomes stronger or weaker")
            recs.append("If you're concerned about how you feel, you can share these notes with a doctor")
            
        case 0.6..<0.8:
            recs.append("This ingredient and your symptom often appear together in your entries")
            recs.append("This suggests a possible pattern in your diary, but not a definite cause")
            recs.append("Keep logging meals and notes to check whether this pattern stays consistent")
            recs.append("If you're concerned about how you feel, you can share these notes with a doctor")
            
        default:
            recs.append("This ingredient and your symptom frequently appear together in your entries")
            recs.append("Your data shows a clear co-occurrence in your diary, not a medical diagnosis")
            recs.append("Keep logging meals and notes to confirm whether this pattern continues over time")
            recs.append("If you're concerned about how you feel, you can share these notes with a doctor")
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
                EmptyStateView(text: "No pattern detected")
                    .grayOverlayModifier()
            }
            
            if !potentialTriggers.isEmpty {
                VStack(alignment: .leading) {
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
                    SectionView(
                        iconColor: .green,
                        ingredients: safeIngredients,
                        symptomTime: symptomTime, symptomName: symptomName
                    )
                }
            }
            
            if !uncertainIngredients.isEmpty {
                VStack(alignment: .leading) {
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
            VStack(alignment: .leading, spacing: 20) {
                ForEach(recommendations.indices, id: \.self) { idx in
                    let recommendation = recommendations[idx]
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                        
                        Text(recommendation)
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
                        .font(.caption2)
                        .foregroundColor(.accent)
                }
            }
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
                    HeaderCard(suspicionValue: ingredient.suspicionScore, circleTitle: "pattern score", symptomTime: symptomTime, symptomName: symptomName)
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
            SectionTitle(title: "How this is calculated", textColor: .secondary)
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
                    title: "Historical pattern",
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
            recs.append("Patterns are based on your past entries. Keep logging meals and notes to enable this view")
            recs.append("Note how the ingredient was prepared and how much you ate")
            recs.append("You can also track other factors like stress, sleep or activity")
            return recs
        }
        
        switch ingredient.suspicionScore {
        case 0..<0.3:
            recs.append("This ingredient and the selected symptom only appeared together in a few of your entries")
            recs.append("This may be due to coincidence or other factors")
            recs.append("Keep logging meals and notes to get a clearer picture over time")
            
        case 0.3..<0.5:
            recs.append("This ingredient and the selected symptom appeared together in some of your entries")
            recs.append("This shows co-occurrence in your diary, not a proven cause")
            recs.append("Keep logging meals and notes to see whether this pattern becomes clearer")
            recs.append("You may want to note timing and portion sizes in your entries")
            
        case 0.5..<0.7:
            recs.append("This ingredient and the selected symptom often appear together in your entries")
            recs.append("This suggests a possible pattern in your diary, but not a medical diagnosis")
            recs.append("Keep logging meals and notes to check whether this pattern stays consistent or changes over time")
            recs.append("If you're concerned about how you feel, you can share these notes with a doctor")
            
        default:
            recs.append("This ingredient and the selected symptom frequently appear together in your entries")
            recs.append("Your data shows a clear co-occurrence in your diary, not a medical diagnosis")
            recs.append("Keep logging meals and notes to confirm whether this pattern continues over time")
            recs.append("If you're concerned about your health, consider discussing these notes with a doctor")
        }
        
        if !ingredient.hasEnoughData {
            recs.append("There may not be enough entries yet to rely on this pattern. Keep logging meals and notes to make it more stable")
        }
        
        return recs
    }

    
    var disclaimerCard: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "About this data", textColor: .secondaryText)
                .textCase(.uppercase)
            VStack {
                Text("This percentage is based on timing and historical patterns in your logged data. Many factors can influence symptoms and co-occurrence does not mean causation. Always discuss dietary changes with a healthcare provider")
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
                        .font(.subheadline)
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
