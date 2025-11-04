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
            //                        howManyHoursBack
            //                        selectSymptom
            VStack(alignment: .leading) {
                SymptomAnalysisView(selectedHourQty: $hoursBack)
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
                    .foregroundColor(textColor)
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
                                            barColor,
                                            barColor.opacity(0.7)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * ingredient.suspicionRate,
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
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    if !ingredient.hasEnoughData {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption2)
                            Text("Need \(3 - ingredient.totalOccurrences) more meals")
                                .font(.caption2)
                        }
                        .foregroundColor(.orange)
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
    
    var textColor: Color {
        switch ingredient.suspicionRate {
        case 0:
            return .green
        case 0..<0.3:
            return .secondary
        case 0.3..<0.6:
            return .orange
        default:
            return .red
        }
    }
    
    var barColor: Color {
        switch ingredient.suspicionRate {
        case 0..<0.3:
            return .accent.opacity(0.3)
        case 0.3..<0.6:
            return .orange
        case 0.6..<0.8:
            return .red.opacity(0.7)
        default:
            return .red
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
                statisticsRow(title: "Total meals with \(ingredient.name)", number: ingredient.totalOccurrences, icon: "fork.knife")
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
                            .foregroundColor(.orange)
                        Text("Track \(3 - ingredient.totalOccurrences) more meal(s) for better accuracy")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
    
    var riskColor: Color {
        switch ingredient.suspicionRate {
        case 0:
            return .green
        case 0..<0.3:
            return .blue
        case 0.3..<0.6:
            return .orange
        case 0.6..<0.8:
            return .red.opacity(0.8)
        default:
            return .red
        }
    }
}


struct SymptomAnalysisView: View {
    @EnvironmentObject var vm: CoreDataViewModel
    @State private var selectedSymptomId: UUID?
    @Binding var selectedHourQty: Int
    
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
    
    @State private var showDetail = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ingredient.name.capitalized)
                    .bold()
                
                Spacer()
                
                Text(ingredient.legend)
                    .font(.title3)
                    .bold()
                    .foregroundColor(textColor)
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
                                    colors: [barColor, barColor.opacity(0.7)],
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
    
    var textColor: Color {
        if ingredient.isSafe { return .green }
        if !ingredient.usedHistoricalData { return .secondary }
        
        switch ingredient.suspicionScore {
        case 0..<0.3: return .secondary
        case 0.3..<0.6: return .orange
        default: return .red
        }
    }
    
    var barColor: Color {
        if ingredient.isSafe { return .green }
        if !ingredient.usedHistoricalData { return .gray }
        
        switch ingredient.suspicionScore {
        case 0..<0.3: return .accent.opacity(0.3)
        case 0.3..<0.6: return .orange
        case 0.6..<0.8: return .red.opacity(0.7)
        default: return .red
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
                    Text("\(Int(suspicionValue * 100))%")
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
                        Text("For symptom \(selectedSymptomName.lowercased()) on")
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
                .foregroundColor(.white)
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


struct IngredientRow<T: ScoredIngredient>: View {
    let ingredient: T
    
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
        VStack(spacing: 8) {
            if let analysis2 = ingredient as? IngredientAnalysis2, analysis2.isSafe {
                safeBadge
            } else if ingredient.scoreValue > 0 {
                normalBar
            } else {
                emptyBar
            }
            
            if let analysis2 = ingredient as? IngredientAnalysis2 {
                if !analysis2.usedHistoricalData {
                    insufficientDataWarning
                }
            }
        }
    }
    
    var safeBadge: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(.green)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Historically safe")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                if let analysis2 = ingredient as? IngredientAnalysis2 {
                    Text("Never caused symptoms (0 of \(analysis2.globalTotalOccurrences))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
    
    var normalBar: some View {
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
                        width: geometry.size.width * ingredient.scoreValue,
                        height: 32
                    )
                
                if ingredient.scoreValue > 0.3 {
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
    }
    
    var emptyBar: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.1))
            .frame(height: 32)
    }
    
    var insufficientDataWarning: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Limited data")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                if let analysis2 = ingredient as? IngredientAnalysis2 {
                    Text("Only \(analysis2.globalTotalOccurrences) meal(s) in history. Need 2+ for accuracy.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(10)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
    
    var ingredientName: some View {
        HStack {
            if let analysis2 = ingredient as? IngredientAnalysis2, analysis2.isSafe {
                Circle()
                    .fill(Color.green)
                    .frame(width: 15, height: 15)
            } else {
                Circle()
                    .fill(ingredient.colorIntensity)
                    .frame(width: 15, height: 15)
            }
            
            Text(ingredient.name)
                .bold()
            
            if let analysis2 = ingredient as? IngredientAnalysis2 {
                if !analysis2.usedHistoricalData {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.orange)
                }
            }
        }
    }
    
    var ingredientPercentage: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if let analysis2 = ingredient as? IngredientAnalysis2 {
                Text("\(Int(analysis2.suspicionScore * 100))%")
                    .font(.headline)
                    .foregroundColor(analysis2.isSafe ? .green : .primary)
                
                if analysis2.usedHistoricalData {
                    if analysis2.isSafe {
                        Text("Safe")
                            .font(.caption2)
                            .foregroundColor(.green)
                    } else {
                        Text("\(analysis2.globalSymptomsOccurrences) of \(analysis2.globalTotalOccurrences)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            } else  {
                Text(ingredient.legend)
                    .font(.headline)
                
                if let symptomsOccurrences = ingredient.symptomsOccurrences {
                    Text("\(symptomsOccurrences) of \(ingredient.totalOccurrences)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview() {
    NavigationStack {
        TestView()
            .environmentObject(CoreDataViewModel.previewWithData)
        //            .environmentObject(CoreDataViewModel.preview)
    }
}
