//
//  ProjectEditorViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import Foundation

class ProjectEditorViewModel: ObservableObject {
    @Published var project: ProjectEntity
    @Published var media = [MediaEntity]()
    
    
    
    
    init(project: ProjectEntity) {
        self.project = project
        if let mediaEntities = project.projectEntityToMediaEntity {
            for entity in mediaEntities {
                media.append(entity)
            }
        }
    }

}
