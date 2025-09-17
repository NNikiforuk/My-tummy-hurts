//
//  Components.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI
import Foundation

struct SiteTitle: View {
    let title: LocalizedStringKey
    
    var body: some View {
        Text(title)
            .font(.title2.bold())
            .padding(.vertical, 10)
            .foregroundStyle(Color("PrimaryText"))
    }
}

struct SectionTitle: View {
    let title: LocalizedStringKey
    
    var body: some View {
        Text(title)
            .bold()
            .foregroundStyle(Color("SecondaryText"))
    }
}


struct NoDataAlert: View {
    let text: LocalizedStringKey
    
    var body: some View {
        Text(text)
            .font(.callout)
            .padding(20)
            .foregroundStyle(Color("SecondaryText"))
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }
}

struct NoDataTexts: View {
    @Binding var analyticsType: AnalyticsMode
    
    let noMealNotes: Bool
    let noSymptomNotes: Bool
    
    var body: some View {
        switch analyticsType {
        case .barChart:
            if noMealNotes && noSymptomNotes {
                NoDataAlert(text: "Add meals and negative symptoms. The more you add - the better the conclusions will be")
            } else if noMealNotes {
                NoDataAlert(text: "Add meals to see charts. The more you add - the better the conclusions will be")
            } else if noSymptomNotes {
                noSymptoms
            }
        case .calendarView:
            if noSymptomNotes {
                noSymptoms
            }
        }
    }
    
    var noSymptoms: some View {
        NoDataAlert(text: "Add symptoms to see charts. The more you add - the better the conclusions will be")
    }
}

func onSameDay<T>(
    _ items: [T],
    as date: Date,
    calendar: Calendar = .current,
    getTime: (T) -> Date?
) -> [T] {
    items.filter { item in
        guard let t = getTime(item) else { return false }
        return calendar.isDate(t, inSameDayAs: date)
    }
}
