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
    @AppStorage("firstInstallAt") private var firstInstallAt: Double = 0
    
    init() {
            if firstInstallAt == 0 {
                firstInstallAt = Date().timeIntervalSince1970
            }
        }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if isOnboarding {
                    WelcomeView(isOnboarding: $isOnboarding)
                        .navigationTitle("")
                        .navigationBarTitleDisplayMode(.inline)
//                        .toolbar {
//                            ToolbarItem(placement: .topBarTrailing) {
//                                ToolbarSkipButton(isOnboarding: $isOnboarding)
//                            }
//                        }
//                        .toolbarBackground(.visible, for: .navigationBar)
                } else {
                    HomeView(isOnboarding: $isOnboarding)
                }
            }
            .environmentObject(vm)
        }
    }
}
