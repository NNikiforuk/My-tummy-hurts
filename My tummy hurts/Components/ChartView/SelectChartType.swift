//
//  SelectChartType.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct SelectChartType: View {
    @Binding var chartType: ChartMode
    @State private var showInfoAll = false
    @State private var showInfoSpecificSymptom = false
    @State private var showInfoLimit = false
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "SELECT CHART TYPE")
            VStack(spacing: 20) {
                SelectableCard(
                    showInfo: $showInfoAll,
                    title: ChartMode.defaultChart.title,
                    isSelected: chartType == ChartMode.defaultChart,
                    infoText: ChartMode.defaultChart.infoText,
                    onTap: { chartType = ChartMode.defaultChart })
                
                SelectableCard(
                    showInfo: $showInfoSpecificSymptom,
                    title: ChartMode.checkSpecificSymptom.title,
                    isSelected: chartType == ChartMode.checkSpecificSymptom,
                    infoText: ChartMode.checkSpecificSymptom.infoText,
                    onTap: { chartType = ChartMode.checkSpecificSymptom })
                
//                SelectableCard(
//                    showInfo: $showInfoLimit,
//                    title: ChartMode.limitByHours.title,
//                    isSelected: chartType == ChartMode.limitByHours,
//                    infoText: ChartMode.limitByHours.infoText,
//                    onTap: { chartType = ChartMode.limitByHours })
            }
            .grayOverlayModifier()
            .contentShape(Rectangle())
        }
        .padding(.top, 40)
    }
}

struct SelectableCard: View {
    @Binding var showInfo: Bool
    
    let title: String
    let isSelected: Bool
    let infoText: String
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .imageScale(.large)
                    .foregroundStyle(isSelected ? .accent : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Button {
                        withAnimation { showInfo.toggle() }
                    } label: {
                        Label("More info", systemImage: "info.circle")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.top, 5)
                    }
                    if showInfo {
                        Text(infoText)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .transition(.opacity)
                            .padding(.top, 5)
                    }
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}
