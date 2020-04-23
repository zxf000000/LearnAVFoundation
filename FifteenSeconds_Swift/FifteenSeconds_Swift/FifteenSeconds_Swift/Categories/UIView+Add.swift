//
//  UIView+Add.swift
//  FifteenSeconds_Swift
//
//  Created by mr.zhou on 2020/4/22.
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit


extension UIView {
    
    func toImage() -> UIImage {
        return toImage(with: bounds.size)
    }
    
    func toImageView() -> UIImageView {
        return toImageView(with: bounds.size)
    }
    
    func toImage(with size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func toImageView(with size: CGSize) -> UIImageView {
        let imageView = UIImageView(image: toImage(with: size))
        imageView.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: size.width, height: size.height)
        return imageView
    }
    
}
