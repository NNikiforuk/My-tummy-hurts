//
//  SelectChartType.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct SelectChartType: View {
    @Binding var chartType: ChartMode
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionTitle(title: "Select chart type", textColor: Color("SecondaryText"))
                .textCase(.uppercase)
            VStack(spacing: 10) {
                SelectableCard(
                    title: ChartMode.defaultChart.localizedTitle,
                    isSelected: chartType == ChartMode.defaultChart,
                    onTap: { chartType = ChartMode.defaultChart })
                
                SelectableCard(
                    title: ChartMode.checkSpecificSymptom.localizedTitle,
                    isSelected: chartType == ChartMode.checkSpecificSymptom,
                    onTap: { chartType = ChartMode.checkSpecificSymptom })
            }
            .grayOverlayModifier()
            .contentShape(Rectangle())
        }
        .padding(.top, 10)
    }
}

struct SelectableCard: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .imageScale(.large)
                    .foregroundStyle(isSelected ? .accent : Color("SecondaryText"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                }
                Spacer()
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}
