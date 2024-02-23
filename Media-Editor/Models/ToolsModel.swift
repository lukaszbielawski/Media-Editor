//
//  ToolsModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 12/02/2024.
//

import Foundation
import SwiftUI

struct ToolsModel {
    let paddingFactor: Double = 0.1

    var leftFloatingButtonAction: (() -> Void)?
    var leftFloatingButtonIcon = "arrow.uturn.backward"
    var rightFloatingButtonAction: (() -> Void)?
    var rightFloatingButtonIcon = "checkmark"

    var sliderPercentage: CGFloat?

    var isImportPhotoViewShown = false
    var isDeleteImageAlertPresented = false
    var layersOpacity = 1.0
    var centerButtonFunction: (() -> Void)?
}
