//
//  THFunctions.swift
//  WriteReadMedia
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

func CenterCropImageRect(sourceRect: CGRect, previewRect: CGRect) -> CGRect {
    let sourceAspectRatio = sourceRect.width / sourceRect.height
    let previewAspectRatio = previewRect.width / previewRect.height
    
    var drawRect = sourceRect
    if sourceAspectRatio > previewAspectRatio {
        let scaleHeight = drawRect.height * previewAspectRatio
        drawRect.origin.x += (drawRect.size.width - scaleHeight) / 2.0
        drawRect.size.width = scaleHeight
    } else {
        drawRect.origin.y += (drawRect.height - drawRect.width / previewAspectRatio) / 2
        drawRect.size.height = drawRect.size.width / previewAspectRatio
    }
    return drawRect
}

func TransformForDeviceORientation(orienetation: UIDeviceOrientation) -> CGAffineTransform {
    var result: CGAffineTransform = CGAffineTransform.identity
    
    switch orienetation {
    case .landscapeRight:
        result = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    case .landscapeLeft:
        result = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 3))
    case .portrait:
        break
    case .faceUp:
        break
    case .faceDown:
        result = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
    default:
        break
    }
    
    return result
}
