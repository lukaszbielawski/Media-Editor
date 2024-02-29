//
//  FilterType.swift
//  Media-Editor
//
//  Created by Łukasz Bielawski on 22/02/2024.
//

import Foundation
import UIKit

enum FilterType: CaseIterable, Equatable {
    case gaussianBlur(value: CGFloat)
    case discBlur(value: CGFloat)
    case motionBlur(value: CGFloat)
    case zoomBlur(value: CGFloat)

    case brightness(value: CGFloat)
    case contrast(value: CGFloat)
    case saturation(value: CGFloat)
    case exposure(value: CGFloat)
    case sharpness(value: CGFloat)
    case gamma(value: CGFloat)
    case vibrance(value: CGFloat)
    case temperature(value: CGFloat)

    case fade
    case instant
    case mono
    case noir
    case process
    case sepia
    case chrome
    case tonal
    case transfer

    case bump(value: CGFloat)
    case bumpLinear(value: CGFloat)
    case circleSplash(value: CGFloat)
    case glass(value: CGFloat)
    case lightTunnel(value: CGFloat)

    case comic
    case colorInvert
    case edgeWork(value: CGFloat)
    case lineOverlay(value: CGFloat)
    case pixellate(value: CGFloat)
    case crystalize(value: CGFloat)

    var category: FilterCategoryType {
        return switch self {
        case .gaussianBlur,
             .discBlur,
             .motionBlur,
             .zoomBlur:
            .blur

        case .brightness,
             .contrast,
             .saturation,
             .exposure,
             .sharpness,
             .gamma,
             .vibrance,
             .temperature:
            .correction

        case .fade,
             .instant,
             .mono,
             .noir,
             .process,
             .sepia,
             .chrome,
             .tonal,
             .transfer:
            .effect

        case .bump,
             .bumpLinear,
             .circleSplash,
             .glass,
             .lightTunnel:
            .distortion

        case .comic,
             .colorInvert,
             .edgeWork,
             .lineOverlay,
             .pixellate,
             .crystalize:
            .special
        }
    }

    var filterName: String {
        return switch self {
        case .gaussianBlur:
            "CIGaussianBlur"
        case .discBlur:
            "CIDiscBlur"
        case .motionBlur:
            "CIMotionBlur"
        case .zoomBlur:
            "CIZoomBlur"

        case .brightness:
            "CIColorControls"
        case .contrast:
            "CIColorControls"
        case .saturation:
            "CIColorControls"
        case .exposure:
            "CIExposureAdjust"
        case .sharpness:
            "CISharpenLuminance"
        case .gamma:
            "CIGammaAdjust"
        case .vibrance:
            "CIVibrance"
        case .temperature:
            "CITemperatureAndTint"

        case .fade:
            "CIPhotoEffectFade"
        case .instant:
            "CIPhotoEffectInstant"
        case .mono:
            "CIPhotoEffectMono"
        case .noir:
            "CIPhotoEffectNoir"
        case .process:
            "CIPhotoEffectProcess"
        case .sepia:
            "CISepiaTone"
        case .chrome:
            "CIPhotoEffectChrome"
        case .tonal:
            "CIPhotoEffectTonal"
        case .transfer:
            "CIPhotoEffectTransfer"

        case .bump:
            "CIBumpDistortion"
        case .bumpLinear:
            "CIBumpDistortionLinear"
        case .circleSplash:
            "CICircleSplashDistortion"
        case .glass:
            "CIGlassDistortion"
        case .lightTunnel:
            "CILightTunnel"

        case .comic:
            "CIComicEffect"
        case .colorInvert:
            "CIColorInvert"
        case .edgeWork:
            "CIEdgeWork"
        case .lineOverlay:
            "CILineOverlay"
        case .pixellate:
            "CIPixellate"
        case .crystalize:
            "CICrystallize"
        }
    }

    var shortName: String {
        return switch self {
        case .gaussianBlur:
            "Gauss"
        case .discBlur:
            "Disk"
        case .motionBlur:
            "Motion"
        case .zoomBlur:
            "Zoom"

        case .brightness:
            "Brightness"
        case .contrast:
            "Contrast"
        case .saturation:
            "Saturation"
        case .exposure:
            "Exposure"
        case .sharpness:
            "Sharpness"
        case .gamma:
            "Gamma"
        case .vibrance:
            "Vibrance"
        case .temperature:
            "Temperature"

        case .fade:
            "Fade"
        case .instant:
            "Polaroid"
        case .mono:
            "Mono"
        case .noir:
            "Noir"
        case .process:
            "Vintage"
        case .sepia:
            "Sepia"
        case .chrome:
            "Chrome"
        case .tonal:
            "Tonal"
        case .transfer:
            "Transfer"

        case .bump:
            "Bump"
        case .bumpLinear:
            "Bump Linear"
        case .circleSplash:
            "Splash"
        case .glass:
            "Glass"
        case .lightTunnel:
            "Light Tunnel"

        case .comic:
            "Comic"
        case .colorInvert:
            "Invert"
        case .edgeWork:
            "Edge Work"
        case .lineOverlay:
            "Line Overlay"
        case .pixellate:
            "Pixellate"
        case .crystalize:
            "Crystalize"
        }
    }

    var parameterValueRange: ClosedRange<CGFloat>? {
        return switch self {
        case .gaussianBlur:
            0.00 ... 100.0
        case .discBlur:
            0.00 ... 150.0
        case .motionBlur:
            0.00 ... 150.0
        case .zoomBlur:
            0.00 ... 80.0

        case .brightness:
            -0.5 ... 0.5
        case .contrast:
            0.5 ... 1.5
        case .saturation:
            0.0 ... 3.0
        case .exposure:
            -2.0 ... 2.0
        case .sharpness:
            0.0 ... 1500.0
        case .gamma:
            0.1 ... 4.0
        case .vibrance:
            -2.0 ... 2.0
        case .temperature:
            2000 ... 20000

        case .fade:
            nil
        case .instant:
            nil
        case .mono:
            nil
        case .noir:
            nil
        case .process:
            nil
        case .sepia:
            nil
        case .chrome:
            nil
        case .tonal:
            nil
        case .transfer:
            nil

        case .bump:
            0.0 ... 1500
        case .bumpLinear:
            0.0 ... 1500
        case .circleSplash:
            0.0 ... 1500
        case .glass:
            0.0 ... 10000.0
        case .lightTunnel:
            10.0 ... 800.0

        case .comic:
            nil
        case .colorInvert:
            nil
        case .edgeWork:
            0.0 ... 1.0
        case .lineOverlay:
            0.0 ... 2.0
        case .pixellate:
            1.0 ... 500.0
        case .crystalize:
            1.0 ... 500.0
        }
    }

    var parameterDefaultValue: CGFloat? {
        return switch self {
        case .gaussianBlur:
            40.0
        case .discBlur:
            80.0
        case .motionBlur:
            70.0
        case .zoomBlur:
            40.0

        case .brightness:
            0.0
        case .contrast:
            1.0
        case .saturation:
            1.0
        case .exposure:
            0.0
        case .sharpness:
            0.0
        case .gamma:
            1.0
        case .vibrance:
            0.0
        case .temperature:
            6500

        case .fade:
            nil
        case .instant:
            nil
        case .mono:
            nil
        case .noir:
            nil
        case .process:
            nil
        case .sepia:
            nil
        case .chrome:
            nil
        case .tonal:
            nil
        case .transfer:
            nil

        case .bump:
            750.0
        case .bumpLinear:
            750.0
        case .circleSplash:
            750.0
        case .glass:
            5000.0
        case .lightTunnel:
            405.0

        case .comic:
            nil
        case .colorInvert:
            nil
        case .edgeWork:
            0.5
        case .lineOverlay:
            0.5
        case .pixellate:
            30.0
        case .crystalize:
            30.0
        }
    }

    var parameterName: String? {
        return switch self {
        case .gaussianBlur:
            "inputRadius"
        case .discBlur:
            "inputRadius"
        case .motionBlur:
            "inputRadius"
        case .zoomBlur:
            "inputAmount"

        case .brightness:
            "inputBrightness"
        case .contrast:
            "inputContrast"
        case .saturation:
            "inputSaturation"
        case .exposure:
            "inputEV"
        case .sharpness:
            "inputRadius"
        case .gamma:
            "inputPower"
        case .vibrance:
            "inputAmount"
        case .temperature:
            "inputTargetNeutral"

        case .fade:
            nil
        case .instant:
            nil
        case .mono:
            nil
        case .noir:
            nil
        case .process:
            nil
        case .sepia:
            nil
        case .chrome:
            nil
        case .tonal:
            nil
        case .transfer:
            nil

        case .bump:
            "inputRadius"
        case .bumpLinear:
            "inputRadius"
        case .circleSplash:
            "inputRadius"
        case .glass:
            "inputScale"
        case .lightTunnel:
            "inputRadius"

        case .comic:
            nil
        case .colorInvert:
            nil
        case .edgeWork:
            "inputRadius"
        case .lineOverlay:
            "inputEdgeIntensity"
        case .pixellate:
            "inputScale"
        case .crystalize:
            "inputRadius"
        }
    }

    var thumbnailName: String {
        return switch self {
        case .gaussianBlur:
            "gaussianBlur"
        case .discBlur:
            "discBlur"
        case .motionBlur:
            "motionBlur"
        case .zoomBlur:
            "zoomBlur"
        case .brightness:
            "brightness"
        case .contrast:
            "contrast"
        case .saturation:
            "saturation"
        case .exposure:
            "exposure"
        case .sharpness:
            "sharpness"
        case .gamma:
            "gamma"
        case .vibrance:
            "vibrance"
        case .temperature:
            "temperature"
        case .fade:
            "fade"
        case .instant:
            "instant"
        case .mono:
            "mono"
        case .noir:
            "noir"
        case .process:
            "process"
        case .sepia:
            "sepia"
        case .chrome:
            "chrome"
        case .tonal:
            "tonal"
        case .transfer:
            "transfer"
        case .bump:
            "bump"
        case .bumpLinear:
            "bumpLinear"
        case .circleSplash:
            "circleSplash"
        case .glass:
            "glass"
        case .lightTunnel:
            "lightTunnel"
        case .comic:
            "comic"
        case .colorInvert:
            "colorInvert"
        case .edgeWork:
            "edgeWork"
        case .lineOverlay:
            "lineOverlay"
        case .pixellate:
            "pixellate"
        case .crystalize:
            "crystalize"
        }
    }

    static var allCases: [Self] {
        return [.gaussianBlur(value: gaussianBlur(value: 0.0).parameterDefaultValue!),
                .discBlur(value: discBlur(value: 0.0).parameterDefaultValue!),
                .motionBlur(value: motionBlur(value: 0.0).parameterDefaultValue!),
                .zoomBlur(value: zoomBlur(value: 0.0).parameterDefaultValue!),

                .brightness(value: brightness(value: 0.0).parameterDefaultValue!),
                .contrast(value: contrast(value: 0.0).parameterDefaultValue!),
                .saturation(value: saturation(value: 0.0).parameterDefaultValue!),
                .exposure(value: exposure(value: 0.0).parameterDefaultValue!),
                .sharpness(value: sharpness(value: 0.0).parameterDefaultValue!),
                .gamma(value: gamma(value: 0.0).parameterDefaultValue!),
                .vibrance(value: vibrance(value: 0.0).parameterDefaultValue!),
                .temperature(value: temperature(value: 0.0).parameterDefaultValue!),

                .fade,
                .instant,
                .mono,
                .noir,
                .process,
                .sepia,
                .chrome,
                .tonal,
                .transfer,

                .bump(value: bump(value: 0.0).parameterDefaultValue!),
                .bumpLinear(value: bumpLinear(value: 0.0).parameterDefaultValue!),
                .circleSplash(value: circleSplash(value: 0.0).parameterDefaultValue!),
                .glass(value: glass(value: 0.0).parameterDefaultValue!),
                .lightTunnel(value: lightTunnel(value: 0.0).parameterDefaultValue!),

                .comic,
                .colorInvert,
                .edgeWork(value: edgeWork(value: 0.0).parameterDefaultValue!),
                .lineOverlay(value: lineOverlay(value: 0.0).parameterDefaultValue!),
                .pixellate(value: pixellate(value: 0.0).parameterDefaultValue!),
                .crystalize(value: crystalize(value: 0.0).parameterDefaultValue!)]
    }

    mutating func changeValue(value: CGFloat) {
        switch self {
        case .gaussianBlur:
            self = .gaussianBlur(value: value)
        case .discBlur:
            self = .discBlur(value: value)
        case .motionBlur:
            self = .motionBlur(value: value)
        case .zoomBlur:
            self = .zoomBlur(value: value)

        case .brightness:
            self = .brightness(value: value)
        case .contrast:
            self = .contrast(value: value)
        case .saturation:
            self = .saturation(value: value)
        case .exposure:
            self = .exposure(value: value)
        case .sharpness:
            self = .sharpness(value: value)
        case .gamma:
            self = .gamma(value: value)
        case .vibrance:
            self = .vibrance(value: value)
        case .temperature:
            self = .temperature(value: value)

        case .fade:
            break
        case .instant:
            break
        case .mono:
            break
        case .noir:
            break
        case .process:
            break
        case .sepia:
            break
        case .chrome:
            break
        case .tonal:
            break
        case .transfer:
            break

        case .bump:
            self = .bump(value: value)
        case .bumpLinear:
            self = .bumpLinear(value: value)
        case .circleSplash:
            self = .circleSplash(value: value)
        case .glass:
            self = .glass(value: value)
        case .lightTunnel:
            self = .lightTunnel(value: value)

        case .comic:
            break
        case .colorInvert:
            break
        case .edgeWork:
            self = .edgeWork(value: value)
        case .lineOverlay:
            self = .lineOverlay(value: value)
        case .pixellate:
            self = .pixellate(value: value)
        case .crystalize:
            self = .crystalize(value: value)
        }
    }

    func createFilter(image: CIImage) -> CIFilter {
        let filter = CIFilter(name: filterName)
        filter?.setValue(image, forKey: kCIInputImageKey)

        let sizeCorrectionFactor = hypot(image.extent.size.width, image.extent.size.height) / referenceDiagonalWidth

        switch self {
        case .gaussianBlur(let value):
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)
        case .discBlur(let value):
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)
        case .motionBlur(let value):
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)
        case .zoomBlur(let value):
            let centerVector = CIVector(x: image.extent.midX, y: image.extent.midY)
            filter?.setValue(centerVector, forKey: kCIInputCenterKey)
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)

        case .brightness(let value):
            filter?.setValue(value, forKey: parameterName!)
        case .contrast(let value):
            filter?.setValue(value, forKey: parameterName!)
        case .saturation(let value):
            filter?.setValue(value, forKey: parameterName!)
        case .exposure(let value):
            filter?.setValue(value, forKey: parameterName!)
        case .sharpness(let value):
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)
        case .gamma(let value):
            filter?.setValue(value, forKey: parameterName!)
        case .vibrance(let value):
            filter?.setValue(value, forKey: parameterName!)
        case .temperature(let value):
            let vector = CIVector(x: value, y: 0.0)
            filter?.setValue(vector, forKey: parameterName!)

        case .bump(let value):
            let centerVector = CIVector(x: image.extent.midX, y: image.extent.midY)
            filter?.setValue(centerVector, forKey: kCIInputCenterKey)
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)
        case .bumpLinear(let value):
            let centerVector = CIVector(x: image.extent.midX, y: image.extent.midY)
            filter?.setValue(centerVector, forKey: kCIInputCenterKey)
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)
        case .circleSplash(let value):
            let centerVector = CIVector(x: image.extent.midX, y: image.extent.midY)
            filter?.setValue(centerVector, forKey: kCIInputCenterKey)
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)
        case .glass(let value):
            let centerVector = CIVector(x: image.extent.midX, y: image.extent.midY)
            filter?.setValue(image, forKey: "inputTexture")
            filter?.setValue(centerVector, forKey: kCIInputCenterKey)
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)
        case .lightTunnel(let value):
            let centerVector = CIVector(x: image.extent.midX, y: image.extent.midY)
            filter?.setValue(centerVector, forKey: kCIInputCenterKey)
            filter?.setValue(45.0, forKey: "inputRotation")
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)

        case .fade:
            break
        case .instant:
            break
        case .mono:
            break
        case .noir:
            break
        case .process:
            break
        case .sepia:
            filter?.setValue(1.0, forKey: kCIInputIntensityKey)
        case .chrome:
            break
        case .tonal:
            break
        case .transfer:
            break

        case .comic:
            break
        case .colorInvert:
            break
        case .edgeWork(let value):
            filter?.setValue(value, forKey: parameterName!)
        case .lineOverlay(let value):
            filter?.setValue(value, forKey: parameterName!)
        case .pixellate(let value):
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)
        case .crystalize(let value):
            filter?.setValue(value * sizeCorrectionFactor, forKey: parameterName!)
        }
        return filter!
    }
}

extension FilterType: Identifiable {
    var id: String { shortName }

    var parameterRangeAverage: CGFloat? {
        guard let parameterValueRange else { return nil }
        return (parameterValueRange.upperBound +
            parameterValueRange.lowerBound) * 0.5
    }

    var referenceDiagonalWidth: CGFloat {
        return hypot(3000, 2000)
    }
}
