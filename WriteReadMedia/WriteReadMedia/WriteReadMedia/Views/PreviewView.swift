//
//  PreviewView.swift
//  WriteReadMedia
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit
import CoreImage
import GLKit

let THFilterSelectionChangedNotification = Notification.Name(rawValue: "filter_selection_changed");


class PreviewView: GLKView {
    var filter: CIFilter?
    var coreImageContext: CIContext?
    
    var drawableBounds: CGRect?
    
    override init(frame: CGRect, context: EAGLContext) {
        super.init(frame: frame, context: context)
        enableSetNeedsDisplay = true
        backgroundColor = .black
        isOpaque = true
        
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        
        self.frame = frame
        
        bindDrawable()
        
        drawableBounds = bounds
        drawableBounds?.size.width = CGFloat(drawableWidth)
        drawableBounds?.size.height = CGFloat(drawableHeight)
        
        NotificationCenter.default.addObserver(self, selector: #selector(filterChanged(_:)), name: THFilterSelectionChangedNotification, object: nil)
    }
    
    @objc
    func filterChanged(_ notification: Notification) {
        self.filter = notification.object as? CIFilter
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        enableSetNeedsDisplay = true
        backgroundColor = .black
        isOpaque = true
        
        transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        
        self.frame = frame
        
        bindDrawable()
        
        drawableBounds = bounds
        drawableBounds?.size.width = CGFloat(drawableWidth)
        drawableBounds?.size.height = CGFloat(drawableHeight)
        
        NotificationCenter.default.addObserver(self, selector: #selector(filterChanged(_:)), name: THFilterSelectionChangedNotification, object: nil)
    }
}

extension PreviewView: ImageTarget {
    func setImage(image source: CIImage) {
        bindDrawable()
        filter?.setValue(source, forKey: kCIInputImageKey)
        guard let filteredImage = filter?.outputImage else {return}
        let cropRect = CenterCropImageRect(sourceRect: filteredImage.extent, previewRect: drawableBounds ?? .zero)
        coreImageContext?.draw(filteredImage, in: drawableBounds ?? .zero, from: cropRect)
        display()
        filter?.setValue(nil, forKey: kCIInputImageKey)
    }
}
