//
//  ImageProjectViewToolbar.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 09/02/2024.
//

import SwiftUI

struct ImageProjectViewToolbar: ToolbarContent {
    @EnvironmentObject var vm: ImageProjectViewModel
    @State var isSaved: Bool = false
    @State var isArrowActive = (undo: true, redo: false)

    @Environment(\.dismiss) var dismiss

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarLeading) {
            Label(isSaved ? "Back" : "Save", systemImage: isSaved ? "chevron.left" : "square.and.arrow.down")
                .labelStyle(.titleAndIcon)
                .onTapGesture {
                    if isSaved {
                        dismiss()
                    } else {
                        // TODO: save action
                        isSaved = true
                    }
                }
                .foregroundStyle(Color(.tint))
        }
        ToolbarItemGroup(placement: .principal) {
            HStack {
                Group {
                    Spacer().frame(width: 11)
                    Label("Undo", systemImage: "arrowshape.turn.up.backward.fill")
                        .opacity(isArrowActive.undo ? 1.0 : 0.5)
                        .onTapGesture { print("undo") }
                    Label("Redo", systemImage: "arrowshape.turn.up.forward.fill")
                        .opacity(isArrowActive.redo ? 1.0 : 0.5)
                        .onTapGesture { print("redo") }
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
                .onTapGesture {}
                .foregroundStyle(Color(.tint))
        }
    }
}
