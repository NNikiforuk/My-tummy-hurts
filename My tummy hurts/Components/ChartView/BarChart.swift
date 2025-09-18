//
//  BarChart.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct BarChart: View {
    let data: [(String, Int)]
    
    var maxValue: Int {
        data.map { $0.1 }.max() ?? 1
    }
    
    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let barCount = max(data.count, 1)
            let spacing: CGFloat = 8
            let totalSpacing = spacing * CGFloat(barCount - 1)
            let barWidthRaw = (totalWidth - totalSpacing) / CGFloat(barCount)
            let barWidth = min(barWidthRaw, 70)
            let textHeight: CGFloat = 45
            
            HStack(spacing: spacing) {
                ForEach(data, id: \.0) { entry in
                    barView(entry: entry,
                            barWidth: barWidth,
                            maxValue: maxValue,
                            geo: geo,
                            textHeight: textHeight)
                }
            }
        }
    }
    
    private func barView(entry: (String, Int),
                         barWidth: CGFloat,
                         maxValue: Int,
                         geo: GeometryProxy,
                         textHeight: CGFloat) -> some View {
        return VStack {
            Spacer()
            Text("\(entry.1)")
                .font(.caption2)
                .foregroundStyle(Color("PrimaryText"))
            Rectangle()
                .fill(.accent)
                .frame(
                    width: barWidth,
                    height: maxValue == 0 ? 0 :
                        CGFloat(entry.1) / CGFloat(maxValue) * (geo.size.height - textHeight)
                )
            Text(entry.0)
                .font(.caption2)
                .frame(width: barWidth)
                .lineLimit(1)
                .foregroundStyle(Color("PrimaryText"))
        }
        .frame(width: barWidth)
    }
    
}
