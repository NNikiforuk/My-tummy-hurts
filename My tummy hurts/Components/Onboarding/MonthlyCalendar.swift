//
//  MonthlyCalendar.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI
import Charts

struct MonthlyCalendar: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    @State private var selectedFirstIngredient: LocalizedStringKey? = nil
    @State private var selectedSecondIngredient: LocalizedStringKey? = nil
    @State private var highlightedDays: [Int] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header(icon: "calendar",
                       title: "Track patterns in monthly calendar",
                       subtitle: "Blue = minor symptoms, red = major. Select one ingredient to highlight days you ate it. Select two to see overlaps in the same meal")
                
                if sizeCategory >= .xxLarge {
                    largeScreenPickers
                } else {
                    defaultScreenPickers
                }
                reverseBtn
                calendar
                Spacer()
            }
            .padding()
            .task {
                runAnimation()
            }
        }
    }
    
    func runAnimation() {
        selectedFirstIngredient = nil
        selectedSecondIngredient = nil
        highlightedDays = []
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            withAnimation {
                selectedFirstIngredient = "cow milk"
                highlightedDays = [3, 9, 12, 20]
            }
            
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation {
                selectedSecondIngredient = "rye bread"
                highlightedDays = [12, 20]
            }
        }
    }
    
    var defaultScreenPickers: some View {
        HStack {
            IngredientDisplay(selectedIngredient: selectedFirstIngredient)
            IngredientDisplay(selectedIngredient: selectedSecondIngredient)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    var largeScreenPickers: some View {
        VStack {
            IngredientDisplay(selectedIngredient: selectedFirstIngredient)
            IngredientDisplay(selectedIngredient: selectedSecondIngredient)
        }
        .padding(.vertical, 20)
    }
    
    var reverseBtn: some View {
        Button {
            runAnimation()
        } label: {
            HStack {
                Spacer()
                Image(systemName: "arrow.counterclockwise")
                    .font(.myFont)
                    .foregroundStyle(.primary)
            }
            .padding(10)
        }
    }
    
    var calendar: some View {
        VStack(spacing: 20) {
            Text("JANUARY 2025").bold().padding(.bottom, 10)
            HStack(spacing: 20) {
                dayView(1, color: .clear)
                dayView(2, color: .clear)
                dayView(3, color: .blue)
                dayView(4, color: .clear)
                dayView(5, color: .clear)
            }
            HStack(spacing: 20) {
                dayView(6, color: .clear)
                dayView(7, color: .red)
                dayView(8, color: .clear)
                dayView(9, color: .blue)
                dayView(10, color: .clear)
            }
            HStack(spacing: 20) {
                dayView(11, color: .clear)
                dayView(12, color: .clear)
                dayView(13, color: .clear)
                dayView(14, color: .blue)
                dayView(15, color: .clear)
            }
            HStack(spacing: 20) {
                dayView(16, color: .clear)
                dayView(17, color: .clear)
                dayView(18, color: .blue)
                dayView(19, color: .clear)
                dayView(20, color: .clear)
            }
        }
        .minimumScaleFactor(sizeCategory.customMinScaleFactor)
        .frame(maxWidth: .infinity)
    }
    
    func dayView(_ day: Int, color: Color) -> some View {
        VStack {
            Text("\(day)")
                .minimumScaleFactor(sizeCategory.customMinScaleFactor)
                .foregroundStyle(highlightedDays.contains(day) ? .white : .primary)
                .frame(
                    width: dayCircleSize(for: sizeCategory),
                    height: dayCircleSize(for: sizeCategory)
                )
                .background(
                    Circle()
                        .fill(highlightedDays.contains(day) ? .accent : .clear)
                )
            Circle().fill(color)
                .frame(
                    width: sizeCategory >= .xxLarge ? 15 : 8,
                    height: sizeCategory >= .xxLarge ? 15 : 8
                )
        }
        .frame(maxWidth: .infinity)
    }
    
    func dayCircleSize(for sizeCategory: DynamicTypeSize) -> CGFloat {
        switch sizeCategory {
        case .xSmall, .small, .medium, .large:
            return 30
        case .xLarge, .xxLarge, .xxxLarge:
            return 45
        case .accessibility1, .accessibility2:
            return 55
        case .accessibility3:
            return 60
        case .accessibility4:
            return 62
        default:
            return 65
        }
    }
}

struct IngredientDisplay: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var selectedIngredient: LocalizedStringKey?
    
    var body: some View {
        HStack {
            if let ingredient = selectedIngredient {
                Text(ingredient)
                    .foregroundStyle(.accent)
            } else {
                HStack {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color("OnboardingBcg"))
                    Text("Select")
                        .foregroundStyle(Color("OnboardingBcg"))
                }
            }
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundStyle(.accent)
        }
        .minimumScaleFactor(sizeCategory.customMinScaleFactor)
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray.opacity(0.5))
        )
    }
}

