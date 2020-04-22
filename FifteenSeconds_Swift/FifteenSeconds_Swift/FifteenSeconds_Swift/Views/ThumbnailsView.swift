//
//  ThumbnailsView.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

let THUMBNAIL_SIZE = CGSize(width: 113, height: 64)

class ThumbnailsView: UIView {

    var thumbnails: [UIImage]? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        var xPos: CGFloat = 0.0
        guard let images = thumbnails else {return}
        for image in images {
            image.draw(in: CGRect(x: xPos, y: 0, width: THUMBNAIL_SIZE.width, height: THUMBNAIL_SIZE.height))
            xPos += THUMBNAIL_SIZE.width
        }
    }
}

