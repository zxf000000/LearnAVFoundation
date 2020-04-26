//
//  VideoTransition.swift
//  FifteenSeconds_Swift
//

//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation
import CoreMedia

enum VideoTransitionType: Int {
    case none = 0
    
    case wipe
    case dissolve
    case push
}

enum PushTransitionDirection: Int {
    case leftToRight = 0
    case rightToLeft
    case topToBottom
    case bottomToTop
    case invalid
    
}


struct VideoTransition {
    var type: VideoTransitionType
    var timeRange: CMTimeRange
    var duration: CMTime
    var direction: PushTransitionDirection
        
//    static func fadeInTransition(with duration: CMTime) -> Self {
//        var transition = Self()
//        transition.type = .fadeIn
//        transition.duration = duration
//        return transition
//    }
//
//    static func fadeOutTransition(with duration: CMTime) -> Self {
//        var transition = Self()
//        transition.type = .fadeOut
//        transition.duration = duration
//        return transition
//    }
    
    static func dissolveTransition(with duration: CMTime) -> Self {
        var transition = Self()
        transition.type = .dissolve
        transition.duration = duration
        return transition
    }
    
    static func pushTransition(with duration: CMTime) -> Self {
        var transition = Self()
        transition.type = .push
        transition.duration = duration
        return transition
    }
    
    
        
    
    
    init() {
        type = .none
        direction = .invalid
        timeRange = CMTimeRange()
        duration = .zero
    }
    
    
    
}
