//
//  MenuViewModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import Combine
import CoreData
import SwiftUI

@MainActor
final class MenuViewModel: ObservableObject {
    @Published var selectedProject: ImageProjectEntity?
    @Published var projects: [ImageProjectEntity] = PersistenceController.shared.projectController.fetchAll()
    @Published var keyboardHeight: CGFloat = 0.0
    @Published var keyboardAnimation: Animation?

    private var keyboardNotificationService = KeyboardNotificationService()

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSubscribtions()
    }

    private func setupSubscribtions() {
        keyboardNotificationService
            .keyboardWillShowNotificationPublisher
            .receive(on: DispatchQueue.main)
            .catch { error in
                print(error)
                return Empty<(Animation, CGFloat), Never>()
            }
            .assertNoFailure()
            .sink { [weak self] animation, keyboardHeight in
                guard let self else { return }
                self.keyboardAnimation = animation
                self.keyboardHeight = keyboardHeight
            }
            .store(in: &cancellables)

        keyboardNotificationService
            .keyboardWillHideNotificationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] value in
                keyboardHeight = value
            }
            .store(in: &cancellables)
    }

    func deleteProject(_ projectToDelete: ImageProjectEntity) {
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
            objectWillChange.send()
        }
    }
}
