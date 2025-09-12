//
//  HowManyHoursBack.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 07/09/2025.
//

import SwiftUI

struct HowManyHoursBack: View {
    @Binding var value: Int
    
    var range: ClosedRange<Int>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionTitle(title: "HOW MANY HOURS BACK")
            Stepper(value: $value, in: range) {
                Text("\(value) h")
                    .font(.subheadline)
            }
            .grayOverlayModifier()
        }
    }
}
