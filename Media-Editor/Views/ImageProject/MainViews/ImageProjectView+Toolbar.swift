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
            Label("Back", systemImage: "chevron.left")
                .labelStyle(.titleAndIcon)
                .onTapGesture {
                    dismiss()
                }
                .foregroundStyle(Color(.tint))
        }
        ToolbarItemGroup(placement: .principal) {
            HStack {
                Group {
                    Spacer().frame(width: 11)
                    Label("Undo", systemImage: "arrowshape.turn.up.backward.fill")
                        .opacity(vm.currentRevertModel.undoModel.count > 0 ? 1.0 : 0.5)
                        .onTapGesture {
                            vm.performUndo()
                        }
                    Label("Redo", systemImage: "arrowshape.turn.up.forward.fill")
                        .opacity(vm.currentRevertModel.redoModel.count > 0 ? 1.0 : 0.5)
                        .onTapGesture {
                            vm.performRedo()
                        }
                    Spacer().frame(width: 22)
                    Label("Center", systemImage: "camera.metering.center.weighted")
                        .onTapGesture {
                            vm.centerButtonFunction?()
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
                        vm.isExportSheetPresented = true
                    }
                }
                .foregroundStyle(Color(.tint))
        }
    }
}
