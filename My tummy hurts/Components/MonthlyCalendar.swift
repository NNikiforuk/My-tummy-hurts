//
//  CalendarView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 29/10/2024.
//

import SwiftUI
import Foundation

struct MonthlyCalendar: View {
    @Binding var selectedMonth: Int
    let days = ["Mon", "Tue", "We", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                CustomButtonIcon(iconName: "arrowtriangle.backward.circle.fill") {
                    selectedMonth -= 1
                }
                Spacer()
                Text(getMonthYearString())
                    .font(.title2)
                Spacer()
                CustomButtonIcon(iconName: "arrowtriangle.forward.circle.fill") {
                    selectedMonth += 1
                }
                Spacer()
            }
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .medium))
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(fetchDates()) { calendarDate in
                    if calendarDate.day == 0 {
                        Color.clear
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    } else {
                        NavigationLink {
                            DayView(selectedDate: calendarDate.date, selectedDay: calendarDate.day)
                        } label: {
                            Text("\(calendarDate.day)")
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    isToday(date: calendarDate.date) ?
                                    Circle().fill(Color.yellow.opacity(0.3)) :
                                        nil
                                )
                        }
                    }
                }
            }
        }
        Spacer()
    }
    
    func getMonthYearString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: fetchSelectedMonth())
    }
    
    func fetchDates() -> [CalendarDate] {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let currentMonth = fetchSelectedMonth()
        
        var components = calendar.dateComponents([.year, .month], from: currentMonth)
        components.day = 1
        let firstDayOfMonth = calendar.date(from: components)!
        
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        let numDays = range.count
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offsetDays = (firstWeekday + 5) % 7
        
        var calendarDates: [CalendarDate] = []
        
        for _ in 0..<offsetDays {
            calendarDates.append(CalendarDate(day: 0, date: Date()))
        }
        
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                calendarDates.append(CalendarDate(day: day, date: date))
            }
        }
        
        return calendarDates
    }
    
    func fetchSelectedMonth() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = selectedMonth
        return calendar.date(byAdding: .month, value: selectedMonth, to: Date()) ?? Date()
    }
    
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date, inSameDayAs: Date())
    }
}

#Preview {
    MonthlyCalendar(selectedMonth: .constant(0))
}

