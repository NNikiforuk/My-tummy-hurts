//
//  DayView.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 29/10/2024.
//

import SwiftUI

struct DayView: View {
    var body: some View {
        VStack {
            HStack {
                Text("30 October 2024")
                    .font(.title.bold())
                Button {
                    
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                }
            }
        }
        
    }
}

#Preview {
    DayView()
}
