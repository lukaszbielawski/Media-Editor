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
    func update(for key: PrimaryKey, entityToUpdate: (Entity) -> Void)
    func delete(for key: PrimaryKey)
}
