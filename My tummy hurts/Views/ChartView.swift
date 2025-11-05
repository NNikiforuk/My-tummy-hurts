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
    @State private var chartType: ChartMode = .defaultChart
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
                    CalendarChart(selectedFirstIngredient: $selectedFirstIngredient, selectedSecondIngredient: $selectedSecondIngredient, selectedDate: $selectedDate)
                }
            }
            .animation(.easeInOut, value: chartType)
        }
        .customBgModifier()
    }
    
    var top10Ingredients: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "Top ten problematic ingredients", textColor: Color("SecondaryText"))
                .textCase(.uppercase)
            VStack {
                if vm.firstChartData.isEmpty {
                    EmptyStateView(text: "Add meals and symptoms")
                } else {
                    HistoricalRiskChart()
                }
            }
            .grayOverlayModifier()
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
}

struct EmptyStateView: View {
    let text: LocalizedStringKey
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No data available for analysis")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct HistoricalRiskChart: View {
    @EnvironmentObject var vm: CoreDataViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(spacing: 30) {
                ForEach(vm.firstChartDataTop10) { ingredient in
                    HistoricalIngredient(ingredient: ingredient)
                }
            }
            .padding()
        }
    }
}

struct HistoricalIngredient: View {
    let ingredient: IngredientAnalysis
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ingredient.name.capitalized)
                    .bold()
                Spacer()
                
                Text(ingredient.legend)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.accent)
            }
            
            Text("\(ingredient.symptomsOccurrences) of \(ingredient.totalOccurrences) meals")
                .font(.caption)
                .foregroundColor(.secondary)
            
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
                
                HStack {
                    if ingredient.suspicionRate == 0 {
                        Label("Safe", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.accent.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    if !ingredient.hasEnoughData {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                            Text("Need \(3 - ingredient.totalOccurrences) more meal(s)")
                                .font(.caption2)
                        }
                        .foregroundColor(.red.opacity(0.8))
                    }
                }
            }
        }
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            SheetContent(ingredient: ingredient)
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
                    HeaderCard(suspicionValue: ingredient.suspicionRate, riskLevel: ingredient.riskLevel, circleTitle: "Risk", symptomTime: nil, symptomName: nil)
                    RiskExplanationCard(riskExplanation: riskExplanation)
                    statisticsCard
                    howItWorksCard
                    RecommendationsCard(recommendations: recommendations)
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
        .grayOverlayModifier()
    }
    
    var riskExplanation: String {
        switch ingredient.suspicionRate {
        case 0:
            return "\(ingredient.name.capitalized) has not been associated with any symptoms in your \(ingredient.totalOccurrences) recorded meal(s). Based on your current data, this ingredient appears to be well tolerated by you"
            
        case 0..<0.3:
            return "\(ingredient.name.capitalized) shows a weak association with symptoms. Out of \(ingredient.totalOccurrences) meals, symptoms occurred within 8 hours after \(ingredient.symptomsOccurrences). This could be coincidental or influenced by other factors. Continue tracking to gather more insights"
            
        case 0.3..<0.6:
            return "\(ingredient.name.capitalized) shows a moderate pattern worth exploring. Symptoms appeared after \(ingredient.symptomsOccurrences) of \(ingredient.totalOccurrences) meals containing this ingredient. Consider trying it in different combinations or amounts to see if the pattern holds"
            
        case 0.6..<0.8:
            return "\(ingredient.name.capitalized) shows a notable pattern that's worth investigating further. Symptoms followed \(ingredient.symptomsOccurrences) of \(ingredient.totalOccurrences) meals with this ingredient. You might try temporarily reducing intake or noting portion sizes to better understand your tolerance"
            
        default:
            return "\(ingredient.name.capitalized) shows a strong association with symptoms across \(ingredient.symptomsOccurrences) of \(ingredient.totalOccurrences) meals. This pattern suggests you may be sensitive to this ingredient. Consider experimenting with smaller portions, different preparations or temporary elimination to see if symptoms improve. If symptoms are significant, consulting a healthcare provider could provide additional guidance"
        }
    }
    
    var statisticsCard: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "Statistics", textColor: .secondary)
                .textCase(.uppercase)
            
            VStack(spacing: 20) {
                statisticsRow(title: "Total meals with: \(ingredient.name)", number: ingredient.totalOccurrences, icon: "fork.knife")
                Divider()
                statisticsRow(title: "How many times symptoms occurred within 8 hours after this ingredient", number: ingredient.symptomsOccurrences, icon: "exclamationmark.triangle.fill")
                Divider()
                statisticsRow(title: "Symptom-free meals", number: ingredient.safeOccurrences, icon: "checkmark.circle.fill")
                
                if ingredient.hasEnoughData {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.accent)
                        Text("Enough data for reliable analysis")
                            .font(.caption)
                            .foregroundColor(.accent)
                    }
                    .padding(.top, 8)
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red.opacity(0.8))
                        Text("Track \(3 - ingredient.totalOccurrences) more meal(s) for better accuracy")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
            .grayOverlayModifier()
        }
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
            SectionTitle(title: "How we calculate risk", textColor: .secondary)
                .textCase(.uppercase)
            
            VStack(alignment: .leading, spacing: 16) {
                explanationRow(
                    title: "Time-weighted analysis",
                    description: "We track symptoms within 8 hours after meals. Symptoms that occur closer to meal time receive higher weight in the calculation"
                )
                
                explanationRow(
                    title: "Pattern detection",
                    description: "The risk percentage shows how often this ingredient was followed by symptoms across all your tracked meals"
                )
                
                explanationRow(
                    title: "Reliability",
                    description: "We need at least 3 meals with this ingredient to provide reliable analysis. More data means more accurate results"
                )
            }
            .grayOverlayModifier()
        }
    }
    
    func explanationRow(title: String, description: String) -> some View {
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
    
    var recommendations: [String] {
        var recs: [String] = []
        
        switch ingredient.suspicionRate {
        case 0:
            recs.append("Continue enjoying this ingredient - it appears safe for you")
            recs.append("Keep tracking to maintain accurate data")
        case 0..<0.3:
            recs.append("This ingredient seems mostly safe")
            recs.append("Monitor for any changes in your reaction over time")
            recs.append("Track a few more meals to improve accuracy")
        case 0.3..<0.6:
            recs.append("Consider reducing intake to see if symptoms improve")
            recs.append("Pay attention to portion sizes - smaller amounts might be tolerable")
            recs.append("Try eating this ingredient separately to isolate its effect")
        case 0.6..<0.8:
            recs.append("Strongly consider avoiding this ingredient")
            recs.append("If you do eat it, track carefully to confirm the pattern")
            recs.append("Discuss with your healthcare provider")
        default:
            recs.append("Avoid this ingredient")
            recs.append("Consult with a healthcare provider or dietitian")
            recs.append("If symptoms are severe, seek medical attention")
        }
        
        if !ingredient.hasEnoughData {
            recs.append("Track \(3 - ingredient.totalOccurrences) more meal(s) for more reliable analysis")
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

struct IngredientAnalysis2Row: View {
    let ingredient: IngredientAnalysis2
    let symptomTime: Date?
    let symptomName: String?
    
    @State private var showDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ingredient.name.capitalized)
                    .bold()
                
                Spacer()
                
                Text(ingredient.legend)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.accent)
            }
            
            if let historical = ingredient.historicalData {
                Text("\(historical.symptomsOccurrences) of \(historical.totalOccurrences) meals in history")
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
                    
                    if ingredient.suspicionScore > 0.3 && ingredient.usedHistoricalData {
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
            
            if ingredient.historicalData == nil {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("New ingredient")
                            .font(.caption)
                            .bold()
                        Text("Track in more meals to see historical patterns")
                            .font(.caption2)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.accent)
                .padding(12)
                .background(Color.accent.opacity(0.1))
                .cornerRadius(8)
            } else if !ingredient.usedHistoricalData {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Limited data")
                            .font(.caption)
                            .bold()
                        Text("Only \(ingredient.globalTotalOccurrences) meal(s) in history. Need 2+ for accuracy")
                            .font(.caption2)
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.accent)
                .padding(12)
                .background(Color.accent.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            SheetContentSpecificSymptom(ingredient: ingredient, symptomTime: symptomTime, symptomName: symptomName)
        }
    }
}

struct RecommendationsCard: View {
    let recommendations: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "Recommendations", textColor: .secondary)
                .textCase(.uppercase)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(recommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accent)
                        
                        Text(recommendation)
                            .foregroundColor(.accent)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .grayOverlayModifier()
        }
    }
}

struct RiskExplanationCard: View {
    let riskExplanation: String
    
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
    let riskLevel: String
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
                    HeaderCard(suspicionValue: ingredient.suspicionScore, riskLevel: ingredient.riskLevel, circleTitle: "Suspicion", symptomTime: symptomTime, symptomName: symptomName)
                    RiskExplanationCard(riskExplanation: explanation)
                    timingCard
                    historicalPatternCard
                    howScoreWorksCard
                    RecommendationsCard(recommendations: recommendations)
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
    
    var explanation: String {
        let timeText = formattedTimeAgo
        
        if !ingredient.usedHistoricalData {
            return "\(ingredient.name.capitalized) was consumed \(timeText) before this symptom. However, we don't have enough historical data about this ingredient yet (less than 2 meals tracked). The score shown is a baseline estimate. Track more meals containing this ingredient to get more reliable analysis."
        }
        
        let historicalRate = ingredient.historicalData?.suspicionRate ?? 0
        let historicalPercent = Int(historicalRate * 100)
        let historicalMeals = "\(ingredient.globalSymptomsOccurrences) of \(ingredient.globalTotalOccurrences)"
        
        switch ingredient.suspicionScore {
        case 0..<0.2:
            return "\(ingredient.name.capitalized) was consumed \(timeText) before this symptom. Based on your history (\(historicalMeals) meals), this ingredient shows a \(historicalPercent)% association with symptoms. Combined with the timing, there's a low likelihood it contributed to this specific symptom."
            
        case 0.2..<0.4:
            return "\(ingredient.name.capitalized) was consumed \(timeText) before this symptom. Your historical data shows a \(historicalPercent)% association (\(historicalMeals) meals). The timing and pattern suggest a moderate possibility it played a role, though other factors may be involved."
            
        case 0.4..<0.6:
            return "\(ingredient.name.capitalized) was consumed \(timeText) before this symptom. Your history shows \(historicalPercent)% of meals with this ingredient (\(historicalMeals)) were followed by symptoms. The proximity and pattern make it a notable candidate for this reaction."
            
        case 0.6..<0.8:
            return "\(ingredient.name.capitalized) was consumed \(timeText) before this symptom. With a \(historicalPercent)% historical association (\(historicalMeals) meals) and this timing, there's a strong possibility this ingredient contributed to your symptom."
            
        default:
            return "\(ingredient.name.capitalized) was consumed \(timeText) before this symptom. Your data shows a very strong pattern: \(historicalPercent)% of meals (\(historicalMeals)) were followed by symptoms. Combined with the close timing, this ingredient is highly likely to have triggered this reaction."
        }
    }
    
    var timingCard: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "Timing analysis", textColor: .secondary)
                .textCase(.uppercase)
            
            VStack(spacing: 16) {
                timingAnalysisRow(icon: "clock.arrow.circlepath", value: formattedTimeAgo, firstText: "Time before symptom")
                timingAnalysisRow(icon: "target", value: "\(Int(ingredient.timeProximity * 100))%", firstText: "Time relevance", secondText: proximityExplanation)
                timingAnalysisRow(icon: "fork.knife", value: "\(ingredient.mealsList.count)", firstText: "Meals in analysis window", secondText: "Meals containing this ingredient before the symptom")
            }
            .grayOverlayModifier()
        }
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
    
    func timingAnalysisRow(icon: String, value: String, firstText: String, secondText: String? = nil) -> some View {
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
    
    var proximityExplanation: String {
        switch ingredient.timeProximity {
        case 0.8...:
            return "Very recent - high relevance"
        case 0.5..<0.8:
            return "Recent - moderate relevance"
        case 0.3..<0.5:
            return "Some time ago - lower relevance"
        default:
            return "Distant - low relevance"
        }
    }
    
    var historicalPatternCard: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "Historical pattern", textColor: .secondary)
                .textCase(.uppercase)
            
            VStack(spacing: 16) {
                if ingredient.usedHistoricalData {
                    timingAnalysisRow(icon: "chart.bar.fill", value: "\(Int((ingredient.historicalData?.suspicionRate ?? 0) * 100))%", firstText: "Historical risk rate", secondText: "\(ingredient.globalSymptomsOccurrences) of \(ingredient.globalTotalOccurrences) meals followed by symptoms")
                    
                    if ingredient.hasEnoughData {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.accent)
                            Text("Reliable data - \(ingredient.globalTotalOccurrences) meals tracked")
                                .padding(.vertical)
                                .font(.caption)
                                .bold()
                                .foregroundColor(.accent)
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.accent)
                            Text("Limited data - track more meals for better accuracy")
                                .padding(.vertical)
                                .font(.caption)
                                .foregroundColor(.accent)
                                .bold()
                        }
                    }
                } else {
                    Text("Not enough historical data yet. This ingredient has been tracked in less than 2 meals. The suspicion score is based on timing alone, using a baseline risk estimate")
                }
            }
            .grayOverlayModifier()
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
                    value: "\(Int(ingredient.timeProximity * 100))%",
                    description: "How recently this was consumed. More recent = higher weight"
                )
                
                Text("×")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                calculationRow(
                    icon: "chart.bar.fill",
                    title: "Historical risk",
                    value: ingredient.usedHistoricalData ? "\(Int((ingredient.historicalData?.suspicionRate ?? 0) * 100))%" : "50% (baseline)",
                    description: ingredient.usedHistoricalData ? "Based on your past meals with this ingredient." : "Baseline estimate - not enough data yet"
                )
                
                HStack(alignment: .center) {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "equal")
                            .foregroundColor(.accent)
                        VStack(alignment: .center, spacing: 4) {
                            Text("suspicion score")
                                .font(.subheadline)
                                .bold()
                                .foregroundStyle(.accent)
                            
                            Text("\(Int(ingredient.suspicionScore * 100))%")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.accent)
                        }
                    }
                    Spacer()
                }
                
                
                
                
                
                
                
            }
            .grayOverlayModifier()
        }
    }
    
    func calculationRow(icon: String, title: String, value: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.customSecondary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .bold()
                    
                    Spacer()
                    
                    Text(value)
                        .font(.headline)
                        .foregroundColor(.customSecondary)
                }
                
                Text(description)
                    .font(.caption)
            }
            
        }
        .grayOverlayModifier()
    }
    
    var recommendations: [String] {
        var recs: [String] = []
        
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
        
        if ingredient.timeProximity > 0.7 {
            recs.append("The close timing makes this ingredient particularly relevant to investigate")
        }
        
        if !ingredient.hasEnoughData {
            recs.append("Track \(3 - ingredient.globalTotalOccurrences) more meal(s) for more confident analysis")
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
    
    var scoreColor: Color {
        switch ingredient.suspicionScore {
        case 0..<0.3:
            return .blue
        case 0.3..<0.5:
            return .yellow
        case 0.5..<0.7:
            return .orange
        default:
            return .red
        }
    }
    
    var proximityColor: Color {
        switch ingredient.timeProximity {
        case 0.7...:
            return .red
        case 0.4..<0.7:
            return .orange
        default:
            return .blue
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
                        .foregroundStyle(Color("PrimaryText"))
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
                    title: ChartMode.defaultChart.localizedTitle,
                    isSelected: chartType == ChartMode.defaultChart,
                    onTap: { chartType = ChartMode.defaultChart })
                
                SelectableCard(
                    title: ChartMode.checkSpecificSymptom.localizedTitle,
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
