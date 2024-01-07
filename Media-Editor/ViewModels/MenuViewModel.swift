//
//  MenuViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import Combine
import SwiftUI
import CoreData

class MenuViewModel: ObservableObject {
    @Published var selectedProject: ProjectEntity?

    @Published var projects: [ProjectEntity] = PersistenceController.shared.fetchAllProjects()
    
    func updateUIAndSaveChanges(context: NSManagedObjectContext) {
        
        objectWillChange.send()
        
        context.perform {
            PersistenceController.shared.saveChanges()
        }
        
    }
    
    func deleteProject(_ projectToDelete: ProjectEntity) {
        let index = projects.firstIndex { $0.id == projectToDelete.id }
        guard let index else { return }
        projects.remove(at: index)
    }
}
