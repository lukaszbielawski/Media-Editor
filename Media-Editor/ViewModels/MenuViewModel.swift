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
    @Published var projects: [ProjectEntity] = PersistenceController.shared.projectController.fetchAll()
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
    
    func deleteProject(_ projectToDelete: ProjectEntity) {
        let index = projects.firstIndex { $0.id == projectToDelete.id }
        guard let index else { return }
        
        projects.remove(at: index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if PersistenceController.shared.projectController.delete(for: projectToDelete.id!) {
                self?.objectWillChange.send()
            }
        }
    }
    
    func updateProjectTitle(title: String) {
        guard let selectedProject else { return }
        if PersistenceController.shared.projectController.update(for: selectedProject.id!, entityToUpdate: { entity in
            entity.title = title
        }) {
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
            }
        }
    }
    
    
}
