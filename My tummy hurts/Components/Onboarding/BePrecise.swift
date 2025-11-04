//
//  BePrecise.swift
//  Tummy hurts
//
//  Created by Natalia Nikiforuk on 11/03/2025.
//

import SwiftUI

struct Sentence: Hashable {
    let sentence: String
}

struct BePrecise: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    let data = [
        Sentence(sentence: "More data = better graphs"),
        Sentence(sentence: "Be as specific as possible"),
        Sentence(sentence: "Be consistent"),
        Sentence(sentence: "For example, always use „rye bread” instead of „bread rye”")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(data, id: \.self) { sentence in
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(.accent)
                        Text(sentence.sentence)
                            .font(.body)
                    }
                    .font(.callout)
                    .padding(.bottom, 10)
                    .padding(.horizontal, 20)
                }
                Spacer()
            }
            .minimumScaleFactor(sizeCategory.customMinScaleFactor)
            .padding()
        }
    }
}
