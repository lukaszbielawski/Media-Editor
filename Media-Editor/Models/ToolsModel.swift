//
//  ToolsModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 12/02/2024.
//

import Combine
import Foundation
import SwiftUI

struct ToolsModel {
    let paddingFactor: Double = 0.1

    var leftFloatingButtonIcon = "arrow.uturn.backward"

    var rightFloatingButtonIcon = "checkmark"

    var isImportPhotoViewShown = false
    var isDeleteImageAlertPresented = false
    var layersOpacity = 1.0

    var photoExportFormat: PhotoFormatType = .png
    var colorArray: [Color] = [
        Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0),
        Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0),
        Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.0)
    ]
}
