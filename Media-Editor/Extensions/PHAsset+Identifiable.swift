//
//  PHAsset+Identifiable.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/01/2024.
//

import Foundation
import Photos

extension PHAsset: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
