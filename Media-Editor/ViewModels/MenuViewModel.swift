//
//  MenuViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import Combine
import CoreData
import SwiftUI

class MenuViewModel: ObservableObject {
    @Published var selectedProject: ProjectEntity?
    @Published var projects: [ProjectEntity] = PersistenceController.shared.fetchAllProjects()
    @Published var keyboardHeight: CGFloat = 0.0
    @Published var keyboardAnimation: Animation?
    
    @Published private var keyboardNotificationService = KeyboardNotificationService()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscribtions()
    }
    
    private func setupSubscribtions() {
        let animationPublisher = keyboardNotificationService.animationPublisher
        animationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                keyboardAnimation = value
            }
            .store(in: &cancellables)
        
        let keyboardHeightPublisher = keyboardNotificationService.keyboardHeightPublisher
        keyboardHeightPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                keyboardHeight = value
            }
            .store(in: &cancellables)
    }
    
    func updateUIAndSaveChanges() {
        objectWillChange.send()
        let controller = PersistenceController.shared
        controller.container.viewContext.perform {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                controller.saveChanges()
            }
            
        }
    }
    
    func deleteProject(_ projectToDelete: ProjectEntity) {
        let index = projects.firstIndex { $0.id == projectToDelete.id }
        guard let index else { return }
        do {
            try projectToDelete.projectEntityToMediaEntity?.forEach { try deleteMediaFile(forEntity: $0) }
        } catch {
            print(error)
        }
//        projectToDelete.projectEntityToMediaEntity?.removeAll()
        projects.remove(at: index)
    }
    
    func deleteMediaFile(forEntity media: MediaEntity) throws {
        try FileManager.default.removeItem(atPath: media.filePath!)
    }
}
