//
//  Category.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/04/2024.
//

import Foundation

protocol Category: Identifiable, CaseIterable, Equatable{
    var id: String { get }
    var shortName: String { get }
    var thumbnailName: String { get }
}
