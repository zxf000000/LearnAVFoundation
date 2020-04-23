//
//  AudioItem.swift
//  FifteenSeconds_Swift
//
//  Created by 壹九科技1 on 2020/4/22.
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation

class AudioItem: MediaItem {
    var volumnAutomation: [VolumeAutomation]?
    
    override var mediaType: AVMediaType? {
        get {
            return AVMediaType.audio
        }
    }
    
    
}
