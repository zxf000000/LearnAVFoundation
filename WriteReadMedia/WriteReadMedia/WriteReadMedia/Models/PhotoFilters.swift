//
//  PhotoFilters.swift
//  WriteReadMedia
//
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation
import CoreImage

class PhotoFilters {
    class func filterNames() -> [String] {
        return [
            "CIPhotoEffectChrome",
            "CIPhotoEffectFade",
            "CIPhotoEffectInstant",
            "CIPhotoEffectMono",
            "CIPhotoEffectNoir",
            "CIPhotoEffectProcess",
            "CIPhotoEffectTonal",
            "CIPhotoEffectTransfer"
        ]
    }
    
    class func filterDisplayNames() -> [String] {
        var displayNames = [String]()
        for name in filterNames() {
            displayNames.append(name)
        }
        return displayNames
    }
    
    class func defaultFilter() -> CIFilter {
        return CIFilter(name: filterNames().first ?? "") ?? CIFilter()
    }
    
    class func filterForDisplayName(_ displayName: String) -> CIFilter? {
        for name in filterNames() {
            if name.contains(displayName) {
                return CIFilter(name: displayName) ?? CIFilter()
            }
        }
        return nil
    }
    
}
