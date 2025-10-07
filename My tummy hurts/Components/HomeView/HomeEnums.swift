//
//  HomeEnums.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import Foundation
import SwiftUI

enum Appearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: Self { self }
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}

enum NoteTab: String, Identifiable, CaseIterable {
    case meals = "Meals"
    case symptoms = "Symptoms"
    
    var id: Self { self }
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
    
    func icon() -> String {
        switch self {
        case .meals:
            return "fork.knife"
        case .symptoms:
            return "toilet"
        }
    }
}

enum SymptomTagsEnum: String, Identifiable, CaseIterable {
    case blue, red
    
    var id: Self { self }
}

extension SymptomTagsEnum {
    var desc: String {
        switch self {
        case .blue:
            "minor"
        case .red:
            "major"
        }
    }
    
    var localized: String {
        NSLocalizedString(self.desc, comment: "")
    }
    
    var color: Color {
        switch self {
        case .blue:
                .blue
        case .red:
                .red
        }
    }
    
    var priority: Int {
        switch self {
        case .blue: return 1
        case .red: return 2
        }
    }
}

extension DynamicTypeSize {
    var customMinScaleFactor: CGFloat {
        switch self {
        case .xSmall, .small, .medium:
            return 1.0
        case .large, .xLarge, .xxLarge:
            return 0.6
        default:
            return 0.85
        }
    }
    
    var calHeader: CGFloat {
        switch self {
        case .xSmall, .small, .medium:
            return 1.0
        case .large, .xLarge, .xxLarge:
            return 0.3
        default:
            return 0.5
        }
    }
}
