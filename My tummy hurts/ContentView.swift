//
//  ContentView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 29/10/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMonth = 0
    let days = ["Mon", "Tue", "We", "Thu", "Fri", "Sat", "Sun"]
    
    var body: some View {
        VStack {
            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                VStack(alignment: .leading) {
                    Text("My tummy")
                        .font(.title.bold())
                        .foregroundStyle(.brown)
                    Text("hurts")
                        .font(.title.bold())
                        .foregroundStyle(.brown)
                }
            }
            Divider()
            VStack(spacing: 20) {
                Text("Select a day")
                    .font(.title2.bold())
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            selectedMonth -= 1
                        }
                    } label: {
                        Image(systemName: "arrowtriangle.backward.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.yellow)
                    }
                    Spacer()
                    Text(getMonthYearString())
                        .font(.title2)
                    Spacer()
                    Button {
                        withAnimation {
                            selectedMonth += 1
                        }
                    } label: {
                        Image(systemName: "arrowtriangle.forward.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.yellow)
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
                            Text("")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        } else {
                            Text("\(calendarDate.day)")
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
                Spacer()
            }
        }
        .padding()
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

struct CalendarDate: Identifiable {
    var id = UUID()
    var day: Int
    var date: Date
}

#Preview {
    ContentView()
}
