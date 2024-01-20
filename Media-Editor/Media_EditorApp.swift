//
//  Media_EditorApp.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 05/01/2024.
//

import SwiftUI
import CoreData
import Photos

@main
struct Media_EditorApp: App {
    @Environment(\.scenePhase) var scenePhase
    var context = PersistenceController.shared.container.viewContext
    
    var body: some Scene {
        WindowGroup {
            MenuView()
                .background(Color(.background))
        }
        .onChange(of: scenePhase) { _ in
            PersistenceController.shared.saveChanges()
        }
        
    }
}
