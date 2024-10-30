//
//  UserData.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 29/10/2024.
//

import Foundation

struct UserData: Codable, Hashable {
    var date: String
    var entries: [Entry]
    
    struct Entry: Codable, Hashable {
        var id: Int
        var meal: Meal
        var symptom: Symptom
        
        struct Meal: Codable, Hashable {
            var time: String
            var ingredients: [String]
        }
        
        struct Symptom: Codable, Hashable {
            var time: String
            var description: [String]
        }
    }
}
