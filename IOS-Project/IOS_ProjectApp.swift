//
//  IOS_ProjectApp.swift
//  IOS-Project
//
//  Created by Максим Шепета on 13/06/2024.
//

import SwiftUI

@main
struct IOS_ProjectApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
