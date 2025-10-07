//
//  Test.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/10/2025.
//

import SwiftUI

struct Test: View {
    @Environment(\.dynamicTypeSize) var sizeCategory
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .minimumScaleFactor(sizeCategory.customMinScaleFactor)
    }
}

#Preview {
    Test()
}
