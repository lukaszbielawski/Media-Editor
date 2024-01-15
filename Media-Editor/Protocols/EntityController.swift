//
//  Entity.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 15/01/2024.
//

import CoreData
import Foundation

protocol EntityController<Entity>: AnyObject {
    associatedtype Entity
    associatedtype PrimaryKey

    var context: NSManagedObjectContext { get }

    init(context: NSManagedObjectContext)

    func fetch(for key: PrimaryKey) -> Entity?
    func fetchAll() -> [Entity]
    func update(for key: PrimaryKey, entityToUpdate: (Entity) -> ()) -> Bool
    func delete(for key: PrimaryKey) -> Bool
}

extension EntityController {
    func saveChanges() -> Bool {
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                return false
            }
        }
        return false
    }
}
