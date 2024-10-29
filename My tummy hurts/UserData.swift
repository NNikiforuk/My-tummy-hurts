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
        var type: String
        var time: String
        var ingredients: [String]
        var symptoms: [Symptom]
        
        struct Symptom: Codable, Hashable {
            var time: String
            var description: String
        }
    }
}


