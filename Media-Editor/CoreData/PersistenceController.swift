//
//  PersistenceController.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import CoreData
import Foundation

class PersistenceController {
    var container: NSPersistentContainer

    static let shared = PersistenceController()

    let projectController: ProjectEntityController
    let mediaController: MediaEntityController

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")

        let context = container.viewContext
        projectController = ProjectEntityController(context: context)
        mediaController = MediaEntityController(context: context)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }

    func saveChanges() {}

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        let firstProject = ProjectEntity(id: UUID(), title: "Preview Project I",
                                         lastEditDate: Date.now, isMovie: false, context: controller.container.viewContext)

        let secondProject = ProjectEntity(id: UUID(), title: "Preview Project II",
                                          lastEditDate: Date.distantPast, isMovie: true, context: controller.container.viewContext)

        return controller
    }()
}
