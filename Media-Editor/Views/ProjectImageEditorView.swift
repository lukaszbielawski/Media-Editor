//
//  ProjectImageEditorView.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 11/01/2024.
//

import SwiftUI

struct ProjectImageEditorView: View {
    @StateObject var vm: ProjectEditorViewModel
    init(project: ProjectEntity?) {
        _vm = StateObject(wrappedValue: ProjectEditorViewModel(project: project!))
    }

    var body: some View {
        ScrollView {
            ForEach(vm.project.media) { media in
                HStack {
                    Image(uiImage: UIImage(contentsOfFile: media.absoluteFilePath)!)
    
                        .centerCropped()
                    Text(media.fileName ?? "nil")
                        .onAppear {
                            print(media.fileName!)
                        }
                }
            }
        }
    }
}

#Preview {
    let project = PersistenceController.preview.projectController.fetchAll().first!
    let binding: Binding<ProjectEntity> = .constant(project)
    return MenuTileView(project: binding) { _ in }
}
