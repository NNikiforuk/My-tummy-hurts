//
//  FAQ.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 30/10/2024.
//

import SwiftUI

struct Info: Identifiable {
    var id: Int
    var text: String
}

struct FAQ: View {
    let infos: [Info] = [
        Info(id: 1, text: "Choose a given calendar day"),
        Info(id: 2, text: "Throughout the day, write down the foods and drinks you consume and at what time"),
        Info(id: 3, text: "Try to write down all the ingredients of the foods and drinks. You can leave out the neutral ones such as water"),
        Info(id: 4, text: "If any negative symptopms appear, come back here and add them after a particular meal"),
        Info(id: 5, text: "Example of symptopms: diarrhea, abdominal pain, constipation, vomiting, nausea, stomach pain, etc."),
        Info(id: 6, text: "Collect all the data. Based on them, we will check whether there is a possibility of a reaction to a particular component of your diet"),
        Info(id: 7, text: "The result can help you see what can harm you and what can't. You can also show it to your doctor")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            ForEach(infos, id: \.id) { info in
                HStack(alignment: .top, spacing: 15) {
                    Text("\(info.id)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.brown)
//                        .background(
//                            Circle()
//                                .stroke(
//                                    Color.brown.opacity(0.8),
//                                    style: StrokeStyle(
//                                        lineWidth: 3
//                                    )
//                                )
//                        )
                    Text(info.text)
                }
            }
        }
        .padding()
        .navigationTitle("How does i work?")
    }
}

#Preview {
    FAQ()
}
