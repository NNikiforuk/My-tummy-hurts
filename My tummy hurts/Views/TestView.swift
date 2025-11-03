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
            //            HowManyHoursBack(value: $hoursBack)
            //            selectSymptom
            VStack {
                sectionTitle
                //                TimelineChart(selectedSymptomId: $selectedSymptomId, hoursBack: $hoursBack)
                SymptomAnalysisView()
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
                    headerCard
                    riskExplanationCard
                    statisticsCard
                    howItWorksCard
                    recommendationsCard
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
    
    var headerCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: ingredient.suspicionRate)
                    .stroke(riskColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: ingredient.suspicionRate)
                
                VStack(spacing: 4) {
                    Text("\(Int(ingredient.suspicionRate * 100))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(riskColor)
                    
                    Text("Risk")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(ingredient.riskLevel)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(riskColor)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    var riskExplanationCard: some View {
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
    
    var recommendationsCard: some View {
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
            .noteModifier()
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
    @State private var selectedHourQty = 5
    
    var pickerSymptoms: [SymptomNote] {
        vm.savedSymptomNotes.sorted { $0.createdAt ?? Date() > $1.createdAt ?? Date() }
    }
    
    var data: [IngredientAnalysis2] {
        vm.getSecondChartData(symptomId: selectedSymptomId, hours: selectedHourQty)
    }
    
    var potentialTriggers: [IngredientAnalysis2] {
        data.filter { ingredient in
            // ⭐ Tylko składniki z historią
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
            // ⭐ Ma historię ALE insufficient data
            guard ingredient.historicalData != nil else { return false }
            return !ingredient.usedHistoricalData && !ingredient.isSafe
        }
    }
    
    // ⭐ NOWA SEKCJA - składniki BEZ historii
    var newIngredients: [IngredientAnalysis2] {
        data.filter { ingredient in
            ingredient.historicalData == nil
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with controls
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Symptom Analysis")
                        .font(.headline)
                        .bold()
                }
                
                Picker("Select symptom", selection: $selectedSymptomId) {
                    Text("Select symptom").tag(nil as UUID?)
                    
                    ForEach(pickerSymptoms) { symptom in
                        if let time = symptom.createdAt {
                            // ⭐ Format z datą i czasem
                            HStack {
                                Text(time, style: .date)
                                Text(time, style: .time)
                                Text("–")
                                Text(symptom.symptom ?? "Unknown")
                            }
                            .tag(symptom.id as UUID?)
                        } else {
                            Text(symptom.symptom ?? "Unknown")
                                .tag(symptom.id as UUID?)
                        }
                    }
                }
                .pickerStyle(.menu)
                
                // Hour slider
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time window: \(selectedHourQty) hours before")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: Binding(
                        get: { Double(selectedHourQty) },
                        set: { selectedHourQty = Int($0) }
                    ), in: 1...12, step: 1)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            VStack(spacing: 20) {
                if !potentialTriggers.isEmpty {
                    SectionView(
                        title: "Potential triggers",
                        subtitle: "Based on historical patterns",
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .red,
                        ingredients: potentialTriggers
                    )
                }
                
                if !safeIngredients.isEmpty {
                    SectionView(
                        title: "Safe ingredients",
                        subtitle: "Never caused symptoms",
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        ingredients: safeIngredients
                    )
                }
                
                if !uncertainIngredients.isEmpty {
                    SectionView(
                        title: "Insufficient data",
                        subtitle: "Need 2+ meals tracked",
                        icon: "questionmark.circle.fill",
                        iconColor: .orange,
                        ingredients: uncertainIngredients
                    )
                }
                
                // ⭐ NOWA SEKCJA
                if !newIngredients.isEmpty {
                    SectionView(
                        title: "New ingredients",
                        subtitle: "Not yet in historical data",
                        icon: "sparkles",
                        iconColor: .blue,
                        ingredients: newIngredients
                    )
                }
            }
        }
        .padding()
        .onAppear {
            // Auto-select last symptom
            if selectedSymptomId == nil {
                selectedSymptomId = vm.savedSymptomNotes.first?.id
            }
        }
    }
}

struct SymptomAnalysisResults: View {
    let data: [IngredientAnalysis2]
    
    // Group ingredients
    var potentialTriggers: [IngredientAnalysis2] {
        data.filter { $0.usedHistoricalData && $0.suspicionScore > 0 && !$0.isSafe }
    }
    
    var safeIngredients: [IngredientAnalysis2] {
        data.filter { $0.isSafe }
    }
    
    var uncertainIngredients: [IngredientAnalysis2] {
        data.filter { !$0.usedHistoricalData || ($0.usedHistoricalData && $0.suspicionScore == 0 && !$0.isSafe) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Potential triggers
                if !potentialTriggers.isEmpty {
                    SectionView(
                        title: "Potential triggers",
                        subtitle: "Based on historical patterns",
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .red,
                        ingredients: potentialTriggers
                    )
                }
                
                // Safe ingredients
                if !safeIngredients.isEmpty {
                    SectionView(
                        title: "Safe ingredients",
                        subtitle: "Never caused symptoms",
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        ingredients: safeIngredients
                    )
                }
                
                // Uncertain
                if !uncertainIngredients.isEmpty {
                    SectionView(
                        title: "Insufficient data",
                        subtitle: "Need 2+ meals tracked",
                        icon: "questionmark.circle.fill",
                        iconColor: .orange,
                        ingredients: uncertainIngredients
                    )
                }
            }
        }
    }
}

struct SectionView: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let ingredients: [IngredientAnalysis2]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                    Text(title)
                        .font(.headline)
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            Divider()
            
            // Ingredients
            ForEach(ingredients) { ingredient in
                IngredientAnalysis2Row(ingredient: ingredient)
            }
        }
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

struct IngredientAnalysis2Row: View {
    let ingredient: IngredientAnalysis2
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top: Name + Percentage
            HStack {
                Text(emoji)
                    .font(.title2)
                
                Text(ingredient.name.capitalized)
                    .font(.body)
                    .bold()
                
                Spacer()
                
                Text(ingredient.legend)
                    .font(.title3)
                    .bold()
                    .foregroundColor(textColor)
            }
            
            // Historical data
            //            if let historical = ingredient.historicalData {
            //                Text("\(ingredient.globalSymptomsOccurrences) of \(ingredient.globalTotalOccurrences) meals in history")
            //                    .font(.caption)
            //                    .foregroundColor(.secondary)
            //
            //
            //            } else {
            //                // ⭐ Dla składników bez historii
            //                Text("Not yet in historical data")
            //                    .font(.caption)
            //                    .foregroundColor(.secondary)
            //                    .italic()
            //            }
            if let historical = ingredient.historicalData {
                // ⭐ ZMIEŃ NA:
                Text("\(historical.symptomsOccurrences) of \(historical.totalOccurrences) meals in history")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("DEBUG: symptoms=\(historical.symptomsOccurrences), weighted=\(String(format: "%.1f", historical.weightedSymptoms))")
                    .font(.caption2)
                    .foregroundColor(.red)
            }
            
            // Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 32)
                    
                    // Foreground
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
                    
                    // Label
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
            
            // Timing info
            Text("Eaten \(formattedTime) ago")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Warnings
            if ingredient.historicalData == nil {
                // ⭐ NOWE - dla składników bez historii
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("New ingredient")
                            .font(.caption)
                            .bold()
                        Text("Track in more meals to see historical patterns.")
                            .font(.caption2)
                    }
                }
                .foregroundColor(.blue)
                .padding(12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            } else if !ingredient.usedHistoricalData {
                // ⭐ STARE - dla składników z insufficient data
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Limited data")
                            .font(.caption)
                            .bold()
                        Text("Only \(ingredient.globalTotalOccurrences) meal(s) in history. Need 2+ for accuracy.")
                            .font(.caption2)
                    }
                }
                .foregroundColor(.orange)
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    var formattedTime: String {
        let hours = Int(ingredient.howLongAgo)
        let minutes = Int((ingredient.howLongAgo - Double(hours)) * 60)
        
        if hours > 0 {
            return minutes > 0 ? "\(hours)h \(minutes)m" : "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    var emoji: String {
        if ingredient.isSafe { return "🟢" }
        if !ingredient.usedHistoricalData { return "⚪" }
        
        switch ingredient.suspicionScore {
        case 0..<0.3: return "⚪"
        case 0.3..<0.6: return "🟡"
        case 0.6..<0.8: return "🟠"
        default: return "🔴"
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
            // ⭐ Sprawdź czy składnik jest "safe"
            if let analysis2 = ingredient as? IngredientAnalysis2, analysis2.isSafe {
                // SAFE INGREDIENT - pokaż badge zamiast paska
                safeBadge
            } else if ingredient.scoreValue > 0 {
                // NORMAL - pokaż pasek
                normalBar
            } else {
                // SCORE = 0 ale nie "safe" - pokaż pusty pasek
                emptyBar
            }
            
            // Warnings (jeśli są)
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
            // ⭐ Ikona - zmień kolor dla safe
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
            
            // ⭐ Triangle TYLKO dla insufficient data (nie dla safe)
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
                // Pokaż procent
                Text("\(Int(analysis2.suspicionScore * 100))%")
                    .font(.headline)
                    .foregroundColor(analysis2.isSafe ? .green : .primary)
                
                // Pokaż status
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
