//
//  Time_CapsuleApp.swift
//  Time Capsule
//
//  Created by Abraham Guerrero on 8/27/25.
//

import SwiftUI

@main
struct Time_CapsuleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
