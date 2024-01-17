//
//  MediaEntityController.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 15/01/2024.
//

import CoreData
import Foundation

final class MediaEntityController: EntityController {
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
    
    func update(for key: String, entityToUpdate: (PhotoEntity) -> ()) -> Bool {
        guard let entity = fetch(for: key) else { return false }
        entityToUpdate(entity)
        return saveChanges()
    }
    
    func delete(for key: String) -> Bool {
        guard let entity = fetch(for: key) else { return false }
        do {
            try deleteMediaFile(for: entity)
            context.delete(entity)
            return true
        } catch {
            print("Error removing media file from documents directory")
            return false
        }
    }
    
    private func deleteMediaFile(for media: PhotoEntity) throws {
        try FileManager.default.removeItem(atPath: media.absoluteFilePath)
    }
}
