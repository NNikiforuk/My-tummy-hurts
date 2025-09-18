//
//  Header.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI
import Foundation

struct HomeViewHeader: View {
    @State private var currentPage: Int = 0
    @State private var weekRange: ClosedRange<Int> = -50...50
    
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
            Text(formatMonth(for: currentPage))
                .font(.title2.bold())
                .foregroundStyle(Color("PrimaryText"))
            
            TabView(selection: $currentPage) {
                ForEach(weekRange, id: \.self) { weekNumber in
                    WeekView(
                        selectedDate: $selectedDate,
                        weekNumber: weekNumber
                    )
                    .tag(weekNumber)
                }
            }
            .onChange(of: currentPage) { newValue in
                if newValue == weekRange.upperBound {
                    weekRange = weekRange.lowerBound ... (weekRange.upperBound + 50)
                }
                else if newValue == weekRange.lowerBound {
                    weekRange = (weekRange.lowerBound - 50) ... weekRange.upperBound
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 100)
    }
}

func formatMonth(for weekNumber: Int) -> String {
    let calendar = Calendar.current
    let today = Date()
    
    guard let targetDate = calendar.date(byAdding: .weekOfYear, value: weekNumber, to: today) else {
        return ""
    }
    
    guard let weekStart = calendar.date(
        from: calendar
            .dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: targetDate
            )
    ),
          let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
        return ""
    }
    
    let monthFormatter = DateFormatter()
    monthFormatter.dateFormat = "LLLL"
    monthFormatter.locale = Locale.current
    
    let startMonth = monthFormatter.string(from: weekStart)
    let endMonth = monthFormatter.string(from: weekEnd)
    
    let yearFormatter = DateFormatter()
    yearFormatter.dateFormat = "yyyy"
    yearFormatter.locale = Locale.current
    let year = yearFormatter.string(from: targetDate)
    
    if startMonth != endMonth {
        return "\(startMonth) / \(endMonth) \(year)"
    }
    
    return "\(startMonth) \(year)"
}

struct WeekView: View {
    @Binding var selectedDate: Date
    let weekNumber: Int
    
    var body: some View {
        HStack {
            ForEach(getDaysOfWeek(for: weekNumber), id: \.self) { date in
                VStack {
                    Text(formatDayName(date))
                        .font(.caption)
                        .foregroundStyle(
                            isSameDay(date1: date, date2: selectedDate)
                            ? Color("NeutralColor")
                            : Color("PrimaryText"))
                    Text(formatDayNumber(date))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            isSameDay(date1: date, date2: selectedDate)
                            ? Color("NeutralColor")
                            : Color("PrimaryText")
                        )
                }
                .frame(width: 35, height: 60)
                .background(
                    isSameDay(date1: date, date2: selectedDate)
                    ? Color("CustomSecondary")
                    : Color.clear
                )
                .background(
                    isToday(date: date)
                    ? .secondaryText.opacity(0.2)
                    : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture {
                    withAnimation {
                        selectedDate = date
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func getDaysOfWeek(for weekNumber: Int) -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        guard let firstDayOfWeek = calendar.date(from: components) else { return [] }
        
        guard let targetDate = calendar.date(byAdding: .weekOfYear, value: weekNumber, to: firstDayOfWeek) else { return [] }
        
        return (0...6).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: targetDate)
        }
    }
    
    private func isToday(date: Date) -> Bool {
        return isSameDay(date1: date, date2: Date())
    }
    
    private func formatDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    private func formatDayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale.current
        return formatter.string(from: date)
    }
    
    private func isSameDay(date1: Date, date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}

struct AddBtns: View {
    @Binding var selection: NoteTab
    @Binding var showAddingMealView: Bool
    @Binding var showAddingSymptomView: Bool
    
    var body: some View {
        VStack {
            switch selection {
            case .meals:
                addBtn(title: "Add meal")
            case .symptoms:
                addBtn(title: "Add symptom")
            }
        }
        .padding(.vertical, 40)
    }
    
    func addBtn(title: String) -> some View {
        Button {
            switch selection {
            case .meals:
                showAddingMealView = true
            case .symptoms:
                showAddingSymptomView = true
            }
        } label: {
            Label(title, systemImage: "plus")
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 15)
        .background(.accent)
        .foregroundStyle(Color("NeutralColor"))
        .bold()
        .clipShape(Capsule())
    }
}
