//
//  ImageProjectViewToolbar.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 09/02/2024.
//
//

import SwiftUI

extension ImageProjectView {
    @ToolbarContentBuilder var imageProjectToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Label(isSaved ? "Back" : "Save", systemImage: isSaved ? "chevron.left" : "square.and.arrow.down")
                .labelStyle(.titleAndIcon)
                .onTapGesture {
                    if isSaved {
                        dismiss()
                    } else {
                        // TODO: save action
                        isSaved = true
                        print(isSaved)
                    }
                }
                .foregroundStyle(Color(.tint))
        }
        ToolbarItemGroup(placement: .principal) {
            HStack {
                Group {
                    Spacer().frame(width: 11)
                    Label("Undo", systemImage: "arrowshape.turn.up.backward.fill")
                        .opacity(vm.undoModel.count > 0 ? 1.0 : 0.5)
                        .onTapGesture {
                            vm.performUndo()
                        }
                    Label("Redo", systemImage: "arrowshape.turn.up.forward.fill")
                        .opacity(vm.redoModel.count > 0 ? 1.0 : 0.5)
                        .onTapGesture {
                            vm.performRedo()
                        }
                    Spacer().frame(width: 22)
                    Label("Center", systemImage: "camera.metering.center.weighted")
                        .onTapGesture {
                            vm.tools.centerButtonFunction?()
                        }
                }
                .foregroundStyle(Color(.tint))
            }.frame(maxWidth: .infinity)
        }
        ToolbarItemGroup(placement: .topBarTrailing) {
            Label("Export", systemImage: "square.and.arrow.up.on.square.fill")
                .labelStyle(.titleAndIcon)
                .onTapGesture {
                    Task {
                        await vm.exportProjectToPhotoLibrary()
                    }
                }
                .foregroundStyle(Color(.tint))
        }
    }
}
