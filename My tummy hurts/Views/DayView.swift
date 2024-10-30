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
                VStack(alignment: .leading) {
                    Text("30 October 2024")
                        .font(.title.bold())
                    Text("List of meals, drinks + symptoms after")
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 45)
                        .foregroundColor(.yellow)
                }
            }
            VStack {
                
            }
        }
        .padding()
    }
}

#Preview {
    DayView()
}
