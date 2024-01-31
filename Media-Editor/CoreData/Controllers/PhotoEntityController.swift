//
//  PhotoEntityController.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 15/01/2024.
//

import CoreData
import Foundation

final class PhotoEntityController: EntityController {
    typealias Entity = PhotoEntity

    typealias PrimaryKey = String

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    var context: NSManagedObjectContext

    func fetch(for key: String) -> PhotoEntity? {
        let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "fileName == %@", key)

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error fetching media entity with primary key \(key): \(error.localizedDescription)")
            return nil
        }
    }

    func fetchAll() -> [PhotoEntity] {
        let fetchRequest: NSFetchRequest<PhotoEntity> = PhotoEntity.fetchRequest()

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching media entities")
            return []
        }
    }

    func update(for key: String, entityToUpdate: (PhotoEntity) -> Void) {
        guard let entity = fetch(for: key) else { return }
        entityToUpdate(entity)
    }

    func delete(for key: String) {
        guard let entity = fetch(for: key) else { return }
        do {
            try deleteMediaFile(for: entity)
            context.delete(entity)
        } catch {
            print("Error removing media file from documents directory")
        }
    }

    private func deleteMediaFile(for media: PhotoEntity) throws {
        try FileManager.default.removeItem(atPath: media.absoluteFilePath)
    }
}
