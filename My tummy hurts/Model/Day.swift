//
//  Day.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 04/11/2024.
//

import Foundation
import SwiftData


@Model
class Day {
    var id: String
    var meals: [Meal]
    var symptoms: [Symptom]
    
    init(id: String = UUID().uuidString, meals: [Meal] = [], symptoms: [Symptom] = []) {
        self.id = id
        self.meals = meals
        self.symptoms = symptoms
    }
    }

@Model
class Meal {
    var time: Date
    var ingredients: [String]
    
    init(time: Date = Date(), ingredients: [String] = []) {
        self.time = time
        self.ingredients = ingredients
    }
}

@Model
class Symptom {
    var time: Date
    var symptoms: [String]
    
    init(time: Date = Date(), symptoms: [String] = []) {
        self.time = time
        self.symptoms = symptoms
    }
}
