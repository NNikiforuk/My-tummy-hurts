//
//  My_tummy_hurtsApp.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

@main
struct My_tummy_hurtsApp: App {
    @StateObject private var vm = CoreDataViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(vm)
        }
    }
}
