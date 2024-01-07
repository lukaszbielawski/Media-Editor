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
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { [unowned self] _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
            if try! container.viewContext.count(for: ProjectEntity.fetchRequest()) == 0 {
                _ = ProjectEntity(id: UUID(), title: "Preview Project I",
                                                 lastEditDate: Date.now, isMovie: false, context: container.viewContext)

                _ = ProjectEntity(id: UUID(), title: "Preview Project II",
                                                  lastEditDate: Date.distantPast, isMovie: true, context: container.viewContext)
            }
        }
    }

    func fetchAllProjects() -> [ProjectEntity] {
        let fetchRequest: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()

        do {
            return try container.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch movies: \(error)")
        }
        return []
    }

    func fetchProject(withID id: UUID) -> ProjectEntity? {
        let fetchRequest: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try container.viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching object with ID \(id): \(error.localizedDescription)")
            return nil
        }
    }

    func saveChanges() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        let firstProject = ProjectEntity(id: UUID(), title: "Preview Project I",
                                         lastEditDate: Date.now, isMovie: false, context: controller.container.viewContext)

        let secondProject = ProjectEntity(id: UUID(), title: "Preview Project II",
                                          lastEditDate: Date.distantPast, isMovie: true, context: controller.container.viewContext)

        return controller
    }()
}
