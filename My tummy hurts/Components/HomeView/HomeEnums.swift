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


