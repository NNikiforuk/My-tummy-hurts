//
//  ChartMode.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI
import Foundation

enum ChartMode: String, CaseIterable, Identifiable {
    case defaultChart, checkSpecificSymptom
    var id: Self { self }
    var title: String {
        switch self {
        case .defaultChart: "Suspicious ingredients"
        case .checkSpecificSymptom: "Check specific symptom"
        }
    }
    var localizedTitle: String {
        NSLocalizedString(self.title, comment: "")
    }
    var desc: String {
        switch self {
        case .defaultChart: "Based on all meals and symptoms within 8 hours"
        case .checkSpecificSymptom: ""
        }
    }
    var localizedDesc: String {
        NSLocalizedString(self.desc, comment: "")
    }
}
