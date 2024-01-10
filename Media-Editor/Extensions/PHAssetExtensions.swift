//
//  PHAsset.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 08/01/2024.
//

import Foundation
import Photos

extension PHAsset {
    var formattedDuration: String {
        let hours = Int(self.duration / 3600)
        let minutes = Int((self.duration.truncatingRemainder(dividingBy: 3600)) / 60)
        let seconds = Int(self.duration.truncatingRemainder(dividingBy: 60))
        
        if hours > 1 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
       
    }
}
