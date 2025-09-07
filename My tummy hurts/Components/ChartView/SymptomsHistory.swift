//
//  SymptomsHistory.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct SymptomsHistory: View {
    @EnvironmentObject var model: ViewModel
    
    @State private var picked: Date? = nil
    
    var body: some View {
        VStack {
            ScrollView {
                ChartsCalendar(selectedDate: $picked)
                    .environmentObject(model)
                TagsDescription()
            }
            //            .grayOverlayModifier()
        }
    }
}

struct ChartsCalendar: UIViewRepresentable {
    @EnvironmentObject var model: ViewModel
    
    @Binding var selectedDate: Date?
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> UICalendarView {
        let cal = UICalendarView()
        cal.calendar   = .current
        cal.locale     = .current
        cal.fontDesign = .rounded
        cal.availableDateRange = DateInterval(start: .distantPast, end: .distantFuture)
        cal.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        cal.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        cal.delegate = context.coordinator
        context.coordinator.calendarView = cal
        
        let sel = UICalendarSelectionSingleDate(delegate: context.coordinator)
        cal.selectionBehavior = sel
        context.coordinator.selection = sel
        
        cal.visibleDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return cal
    }
    
    func updateUIView(_ uiView: UICalendarView, context: Context) {
        uiView.locale = .current
        let cal = uiView.calendar
        let comps = selectedDate.map { cal.dateComponents([.year,.month,.day], from: $0) }
        context.coordinator.selection?.setSelected(comps, animated: false)
        if let c = comps { uiView.visibleDateComponents = c }
        
        context.coordinator.rebuildDecorations(from: model.symptomNotes, calendar: cal)
        
        let visible = uiView.visibleDateComponents
        guard let year = visible.year, let month = visible.month else { return }
        
        let first = DateComponents(calendar: cal, year: year, month: month, day: 1)
        guard let monthDate = cal.date(from: first),
              let range = cal.range(of: .day, in: .month, for: monthDate) else { return }
        
        let compsToReload = range.map {
            DateComponents(calendar: cal, year: year, month: month, day: $0)
        }
        uiView.reloadDecorations(forDateComponents: compsToReload, animated: false)
    }
    
    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        private struct DayKey: Hashable { let y: Int, m: Int, d: Int }
        var parent: ChartsCalendar
        weak var calendarView: UICalendarView?
        weak var selection: UICalendarSelectionSingleDate?
        private var decorations: [DayKey: UICalendarView.Decoration] = [:]
        
        init(_ parent: ChartsCalendar) { self.parent = parent }
        
        private func key(from date: Date, cal: Calendar) -> DayKey {
            let c = cal.dateComponents([.year,.month,.day], from: date)
            return DayKey(y: c.year!, m: c.month!, d: c.day!)
        }
        
        private func key(from comps: DateComponents) -> DayKey? {
            guard let y = comps.year, let m = comps.month, let d = comps.day else { return nil }
            return DayKey(y: y, m: m, d: d)
        }
        
        func rebuildDecorations(from symptoms: [SymptomNote], calendar cal: Calendar) {
            var daily: [DayKey: SymptomTagsEnum] = [:]
            
            for s in symptoms {
                guard let date = s.createdAt else { continue }
                let tag: SymptomTagsEnum = (s.critical == true) ? .red : .blue
                let k = key(from: date, cal: cal)
                
                if let existing = daily[k] {
                    if tag.priority > existing.priority { daily[k] = tag }
                } else {
                    daily[k] = tag
                }
            }
            
            decorations.removeAll(keepingCapacity: true)
            for (k, tag) in daily {
                let uiColor = UIColor(tag.color)
                decorations[k] = .image(UIImage(systemName: "circle.fill"),
                                        color: uiColor,
                                        size: .large)
            }
        }
        
        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents)
        -> UICalendarView.Decoration? {
            guard let k = key(from: dateComponents) else { return nil }
            return decorations[k]
        }
        
        func dateSelection(_ selection: UICalendarSelectionSingleDate,
                           didSelectDate comps: DateComponents?) {
            parent.selectedDate = comps.flatMap { Calendar.current.date(from: $0) }
        }
    }
}

struct TagsDescription: View {
    var body: some View {
        HStack(spacing: 30) {
            ForEach(SymptomTagsEnum.allCases) { el in
                HStack {
                    Circle().fill(el.color)
                        .frame(width: 15, height: 15)
                    Text(el.desc)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top, 5)
    }
}

#Preview {
    SymptomsHistory()
}
