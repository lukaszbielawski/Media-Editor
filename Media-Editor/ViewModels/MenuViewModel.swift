//
//  MenuViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import SwiftUI

class MenuViewModel: ObservableObject {
    @Published var selectedProject: ProjectEntity?

    @Published var projects: [ProjectEntity] = PersistenceController.shared.fetchAllProjects()

    func findIndexForUUID(uuid: UUID) -> Int? {
        return projects.firstIndex(of: PersistenceController.shared.fetchProject(withID: uuid)!)
    }
}
