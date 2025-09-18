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
    @AppStorage("isOnboarding") private var isOnboarding = true
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isOnboarding {
                    WelcomeView(isOnboarding: $isOnboarding)
                } else {
                    HomeView()
                        .environmentObject(vm)
                }
            }
        }
    }
}
