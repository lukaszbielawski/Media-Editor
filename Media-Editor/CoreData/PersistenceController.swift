//
//  PersistenceController.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import CoreData
import Foundation

class PersistenceController {
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
            if try! container.viewContext.count(for: ProjectEntity.fetchRequest()) == 0 {
                let firstProject = ProjectEntity(id: UUID(), title: "Preview Project I",
                                                 lastEditDate: Date.now, isMovie: false, context: container.viewContext)

                let secondProject = ProjectEntity(id: UUID(), title: "Preview Project II",
                                                  lastEditDate: Date.distantPast, isMovie: true, context: container.viewContext)
            }
        }
        return container
    }()

    var preview: [ProjectEntity] {
        let firstProject = ProjectEntity(id: UUID(), title: "Preview Project I",
                                         lastEditDate: Date.now, isMovie: false, context: persistentContainer.viewContext)

        let secondProject = ProjectEntity(id: UUID(), title: "Preview Project II",
                                          lastEditDate: Date.distantPast, isMovie: true, context: persistentContainer.viewContext)

        do {
            try persistentContainer.viewContext.save()
            return [firstProject, secondProject]
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    func fetchAllProjects() -> [ProjectEntity] {
        let fetchRequest: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch movies: \(error)")
        }
        return []
    }

    func fetchProject(withID id: UUID) -> ProjectEntity? {
        let fetchRequest: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching object with ID \(id): \(error.localizedDescription)")
            return nil
        }
    }

    static let shared = PersistenceController()
    private init() {}

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteObject(object: NSManagedObject?) {
        guard let object else { return }
        let context = persistentContainer.viewContext
        context.delete(object)
    }
}
