//
//  My_tummy_hurtsApp.swift
//  My tummy hurts
//
//  Created by Natalia Nikiforuk on 03/09/2025.
//

import SwiftUI

@main
struct My_tummy_hurtsApp: App {
    //    let persistenceController = PersistenceController.shared
    @StateObject private var vm = CoreDataViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
                //                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            .environmentObject(vm)
        }
    }
}
