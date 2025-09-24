//
//  MonthlyCalendar.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI
import Charts

struct MonthlyCalendar: View {
    @Binding var isOnboarding: Bool
    @State private var selectedFirstIngredient: String? = nil
    @State private var selectedSecondIngredient: String? = nil
    @State private var highlightedDays: [Int] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header(icon: "calendar",
                   title: "Track patterns in monthly calendar",
                   subtitle: "Blue = minor symptoms, red = major. Add ingredients to highlight days you ate them. Select two ingredients to see overlaps in the same meal")
            
            HStack {
                IngredientDisplay(selectedIngredient: selectedFirstIngredient)
                IngredientDisplay(selectedIngredient: selectedSecondIngredient)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            
            VStack(spacing: 20) {
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
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .padding()
        .task {
            runAnimation()
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
    
    func dayView(_ day: Int, color: Color) -> some View {
        VStack {
            Text("\(day)")
                .foregroundStyle(highlightedDays.contains(day) ? .white : .primary)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(highlightedDays.contains(day) ? .accent : .clear)
                )
            Circle().fill(color)
                .frame(width: 8, height: 8)
        }
        .frame(maxWidth: .infinity)
    }
}

struct IngredientDisplay: View {
    var selectedIngredient: String?
    
    var body: some View {
        HStack {
            if let ingredient = selectedIngredient {
                Text(ingredient)
                    .foregroundStyle(.accent)
            } else {
                HStack {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color("OnboardingBgc"))
                    Text("Select")
                        .foregroundStyle(Color("OnboardingBgc"))
                }
            }
            Spacer()
            Image(systemName: "chevron.down")
                .foregroundStyle(.accent)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray.opacity(0.5))
        )
    }
}

