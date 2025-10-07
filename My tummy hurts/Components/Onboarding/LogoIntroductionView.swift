//
//  WeekIntroductionView.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 10/03/2025.
//

import SwiftUI

struct LogoIntroductionView: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var body: some View {
        VStack {
            LogoView()
            Text("Eat. Track.")
                .font(.title2)
                .multilineTextAlignment(.center)
            hilightedText(
                str: NSLocalizedString("Uncover what's hurting your gut", comment: ""),
                searched: localizedSearchWord(),
                styles: { text in
                    text
                        .font(.myFont)
                        .foregroundColor(Color("WhiteCustom"))
                }
            )
            .font(.title2)
            .multilineTextAlignment(.center)
        }
        .minimumScaleFactor(sizeCategory.customMinScaleFactor)
    }
    
    func hilightedText(
        str: String,
        searched: String,
        styles: (Text) -> Text
    ) -> Text {
        guard !str.isEmpty && !searched.isEmpty else { return Text(str) }
        
        var result: Text?
        let parts = str.components(separatedBy: searched)
        
        for i in parts.indices {
            result = (result == nil ? Text(parts[i]) : result! + Text(parts[i]))
            
            if i != parts.count - 1 {
                result = result! + styles(Text(searched))
            }
        }
        
        return result ?? Text(str)
    }
    
    func localizedSearchWord() -> String {
        let locale = Locale.current.language.languageCode?.identifier ?? "en"
        switch locale {
        case "pl":
            return "szkodzi"
        case "fr":
            return "nuit"
        case "es":
            return "daño"
        case "de":
            return "schadet"
        default:
            return "hurting"
        }
    }
}

struct LogoView: View {
    var body: some View {
        Image("AppIconPreview")
            .resizable()
            .frame(width: 100, height: 100)
    }
}

