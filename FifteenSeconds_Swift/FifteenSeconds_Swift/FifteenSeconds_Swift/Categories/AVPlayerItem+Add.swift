//
//  AVPlayerItem+Add.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import AVKit

var SynchronizedLayerKey = ""

extension AVPlayerItem {
    var titleLayer: AVSynchronizedLayer? {
        set {
            objc_setAssociatedObject(self, &SynchronizedLayerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &SynchronizedLayerKey) as? AVSynchronizedLayer
        }
    }
    
    func hasValidDuration() -> Bool {
        return status == .readyToPlay && !CMTIME_IS_INVALID(duration)
    }
    
    func muteAudioTracks(value: Bool) {
        for track in tracks {
            if track.assetTrack?.mediaType == .audio {
                track.isEnabled = !value
            }
        }
    }
}
