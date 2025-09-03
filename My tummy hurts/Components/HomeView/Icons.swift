//
//  Icons.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import Foundation
import SwiftUI

struct PlusIcon: View {
    var body: some View {
        HStack {
            Image(systemName: "plus")
            Text("List item")
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 10)
    }
}
