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
        case .defaultChart: "Pre-symptom ingredients"
        case .checkSpecificSymptom: "Check specific symptom"
        }
    }
    var infoText: String {
        switch self {
        case .defaultChart: "Top ingredients consumed directly before any negative symptom"
        case .checkSpecificSymptom: "Example: top ingredients consumed within 5 hours before each occurrence of heartburn"
        }
    }
    var localizedTitle: String {
        NSLocalizedString(self.title, comment: "")
    }
    var localizedInfo: String {
        NSLocalizedString(self.infoText, comment: "")
    }
}
