//
//  Dupa.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 17/09/2025.
//

import SwiftUI

struct Dupa: View {
    let meal: MealNote
    @EnvironmentObject private var vm: CoreDataViewModel
    
    var body: some View {
        niki
    }
}

extension Dupa {
    private var niki: some View {
        VStack {
            Text(meal.ingredients ?? "")
        }
    }
}
