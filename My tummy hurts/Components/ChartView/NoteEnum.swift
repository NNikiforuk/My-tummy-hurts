//
//  NoteEnum.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import Foundation

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
            return symptom.symptoms
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
