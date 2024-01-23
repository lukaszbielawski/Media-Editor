//
//  ProjectEntityController.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 15/01/2024.
//

import CoreData
import Foundation

final class ProjectEntityController: EntityController {
    typealias Entity = ImageProjectEntity

    var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetch(for key: UUID) -> ImageProjectEntity? {
        let fetchRequest: NSFetchRequest<ImageProjectEntity> = ImageProjectEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", key as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Error fetching object with ID \(key): \(error.localizedDescription)")
            return nil
        }
    }

    func fetchAll() -> [ImageProjectEntity] {
        let fetchRequest: NSFetchRequest<ImageProjectEntity> = ImageProjectEntity.fetchRequest()

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch movies: \(error)")
            return []
        }
    }

    func update(for key: UUID, entityToUpdate: (ImageProjectEntity) -> Void) -> Bool {
        guard let entity = fetch(for: key) else { return false }
        entityToUpdate(entity)
        return saveChanges()
    }

    func delete(for key: UUID) -> Bool {
        guard let entity = fetch(for: key) else { return false }

        let success = entity.imageProjectEntityToPhotoEntity?
            .map { PersistenceController.shared.photoController.delete(for: $0.fileName!) }
            .first { $0 == false } ?? true

        if success {
            context.delete(entity)
            return saveChanges()
        } else {
            return false
        }
    }
}
