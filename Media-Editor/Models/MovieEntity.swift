//
//  MovieEntity.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 06/01/2024.
//

import Foundation
import SwiftUI

struct Movie: Frameable {
    var projectName: String
    var lastEditDate: Date = Date.now
    var thumbnail: UIImage = UIImage(named: "ex_image")!
}

