//
//  UIColor+Add.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

extension UIColor {
    func lighterColor() -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) == true {
            return UIColor(hue: hue, saturation: saturation, brightness: min(brightness * 1.3, 1.0), alpha: alpha)
        }
        return UIColor()
    }
    func darkerColor() -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) == true {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * 0.85, alpha: alpha)
        }
        return UIColor()
    }
}
