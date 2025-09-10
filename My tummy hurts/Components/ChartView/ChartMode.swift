//
//  ChartMode.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI
import Foundation

enum ChartMode: String, CaseIterable, Identifiable {
    case defaultChart, limitByHours
    var id: Self { self }
    var title: String {
        switch self {
        case .defaultChart: "Pre-symptom meals"
        case .limitByHours: "Meals within X hours before symptom"
        }
    }
    var infoText: String {
        switch self {
        case .defaultChart: "Top x ingredients that immediately caused you stomach problems"
        case .limitByHours: "Limit to meals eaten within the last X hours"
        }
    }
}
