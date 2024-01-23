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
    let photoController: PhotoEntityController

    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")

        let context = container.viewContext
        projectController = ProjectEntityController(context: context)
        photoController = PhotoEntityController(context: context)

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

        let firstProject = ImageProjectEntity(id: UUID(),
                                              title: "Preview Project I",
                                              isMovie: false,
                                              context: controller.container.viewContext)

        let secondProject = ImageProjectEntity(id: UUID(),
                                               title: "Preview Project II",
                                               isMovie: true,
                                               context: controller.container.viewContext)

        return controller
    }()
}
