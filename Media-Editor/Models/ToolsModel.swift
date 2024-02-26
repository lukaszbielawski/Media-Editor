//
//  ToolsModel.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 12/02/2024.
//

import Foundation
import SwiftUI
import Combine

struct ToolsModel {
    let paddingFactor: Double = 0.1

    var leftFloatingButtonAction: (() -> Void)?
    var leftFloatingButtonIcon = "arrow.uturn.backward"
    var rightFloatingButtonAction: (() -> Void)?
    var rightFloatingButtonIcon = "checkmark"
    
    var sliderPercentage: CGFloat?
    var debounceSaveSubject = PassthroughSubject<Void, Never>()

    var isImportPhotoViewShown = false
    var isDeleteImageAlertPresented = false
    var layersOpacity = 1.0
    var centerButtonFunction: (() -> Void)?

    var photoExportFormat: PhotoFormatType = .png
    var colorArray: [Color] = [
        Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 1.0),
        Color(red: 0.0, green: 0.0, blue: 0.0, opacity: 1.0),
        Color(red: 1.0, green: 1.0, blue: 1.0, opacity: 0.0)
    ]
}
