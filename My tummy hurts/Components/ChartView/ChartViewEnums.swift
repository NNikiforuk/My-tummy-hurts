//
//  ChartViewEnums.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 04/11/2025.
//

import SwiftUI
import Foundation

enum ChartMode: String, CaseIterable, Identifiable {
    case problematicIngredients = "Ingredients linked with discomfort"
    case potentiallySafeIngredients = "Ingredients with low impact"
    case checkSpecificSymptom = "View by symptom"
    
    var id: Self { self }
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}

enum AnalyticsMode: String, CaseIterable, Identifiable {
    case barChart = "Ingredient patterns"
    case calendarView = "Monthly calendar"
    
    var id: Self { self }
    var localized: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}

enum NoteEnum {
    case meal(MealNote)
    case symptom(SymptomNote)
}

extension NoteEnum {
    var time: Date {
        switch self {
        case .meal(let m): return m.createdAt!
        case .symptom(let s): return s.createdAt!
        }
    }
    
    var isSymptom: Bool {
        switch self {
        case .meal: return false
        case .symptom: return true
        }
    }
    
    var desc: String? {
        switch self {
        case .meal(let meal):
            return meal.ingredients
        case .symptom(let symptom):
            return symptom.symptom
        }
    }
    
    var critical: Bool? {
        switch self {
        case .meal(_):
            return nil
        case .symptom(let symptom):
            return symptom.critical
        }
    }
}
