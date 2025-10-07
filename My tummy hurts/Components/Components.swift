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
    let textColor: Color
    
    var body: some View {
        Text(title)
            .bold()
            .foregroundStyle(textColor)
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

struct ToolbarSkipButton: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
        Button(LocalizedStringKey("Skip")) {
            isOnboarding = false
        }
        .foregroundStyle(.accent)
        .buttonStyle(.automatic)
    }
}

struct DeleteBtn: View {
    let action: () -> Void
    
    var body: some View {
        Button(LocalizedStringKey("Delete"), role: .destructive, action: action)
            .foregroundStyle(.red)
    }
}

struct DeleteBtnTextIcon: View {
    let title: LocalizedStringKey
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(title, systemImage: icon, role: .destructive, action: action)
            .foregroundStyle(.red)
    }
}

struct SaveBtn: View {
    let action: () -> Void
    
    var body: some View {
        Button(LocalizedStringKey("Save"), action: action)
    }
}

struct CancelBtn: View {
    let action: () -> Void
    
    var body: some View {
        Button(LocalizedStringKey("Cancel"), role: .cancel, action: action)
    }
}

struct OnboardingPageTitle: View {
    let text: LocalizedStringKey
    
    var body: some View {
       Text(text)
            .font(.title.bold())
            .padding(.vertical, 20)
    }
}

struct DefaultFontView: View {
    var title: String
    
    @Binding var bindingData: Date
    
    
    var body: some View {
        DatePicker(
            title,
            selection: $bindingData,
            displayedComponents: [.date, .hourAndMinute]
        )
        .customPickerModifier()
    }
}

struct BiggerFontView: View {
    var title: LocalizedStringKey
    
    @Binding var bindingData: Date
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                SectionTitle(title: title, textColor: .primaryText)
                   Spacer()
            }
            .padding(.top, 40)
            CustomDataPicker(bindingData: $bindingData, title: title, isTime: false)
            CustomDataPicker(bindingData: $bindingData, title: title, isTime: true)
        }
    }
}

struct CustomDataPicker: View {
    @Binding var bindingData: Date
    
    var title: LocalizedStringKey
    let isTime: Bool
    
    var body: some View {
        DatePicker(
            title,
            selection: $bindingData,
            displayedComponents: isTime ? .hourAndMinute : .date
        )
        .datePickerStyle(.compact)
        .labelsHidden()
    }
}
