//
//  RevertModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 01/05/2024.
//

import Foundation

class RevertModel: ObservableObject {
    @Published var latestSnapshot: SnapshotModel!

    @Published var redoModel: [SnapshotModel] = .init()

    @Published var undoModel: [SnapshotModel] = .init()

    convenience init(_ latestSnapshot: SnapshotModel) {
        self.init()
        self.latestSnapshot = latestSnapshot
    }
}
