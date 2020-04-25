//
//  MediaTrack.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation

enum MediaTrackType: Int {
    case video = 0
    case title
    case commontary
    case music
}

class TimeLine {
    var videos: [Any]?
    var transitons: [Any]?
    var titles: [Any]?
    var voiceOvers: [Any]?
    var musicItems: [Any]?
    
    func isSimpleTimeline() -> Bool {
        
        // TODO: 待定
//        guard let items = musicItems else {
//            if (transitons?.count ?? 0) > 0 || (titles?.count ?? 0) > 0 {
//                return false
//            }
//            return true
//        }
//        for (_, item) in items.enumerated() {
//            if (item as! AudioItem).volumnAutomation?.count ?? 0 > 0 {
//                return false
//            }
//        }
//        if (transitons?.count ?? 0) > 0 || (titles?.count ?? 0) > 0 {
//            return false
//        }
        return true
    }
}
