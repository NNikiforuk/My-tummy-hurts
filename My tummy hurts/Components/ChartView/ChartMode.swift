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
        case .defaultChart: "Matches each symptom to its most recent preceding meal and counts the top X ingredients"
        case .limitByHours: "Limit to meals eaten within the last X hours"
        }
    }
}
