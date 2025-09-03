//
//  Titles.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import Foundation
import SwiftUI

struct SiteTitle: View {
    let title: String
    
    var body: some View {
        Text(LocalizedStringKey(title))
            .font(.title2.bold())
            .padding(.vertical, 10)
    }
}

struct SectionTitle: View {
    let title: String
    
    var body: some View {
        Text(LocalizedStringKey(title))
            .bold()
            .padding(.bottom, 20)
    }
}
