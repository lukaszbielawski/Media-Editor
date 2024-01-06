//
//  Media_EditorApp.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/01/2024.
//

import SwiftUI
import CoreData

@main
struct Media_EditorApp: App {
    var context = PersistenceController.shared.persistentContainer.viewContext
    
    var body: some Scene {
        WindowGroup {
            MenuView()
                .background(Color(.background))
                .environment(\.managedObjectContext, context)
        }
    }
}
