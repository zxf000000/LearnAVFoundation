//
//  BasicCompositionBuilder.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation

class BasicCompositionBuilder: CompositionBuilder {
    private var timeline: TimeLine!
    private var composition: AVMutableComposition!
    init(timeline: TimeLine) {
        self.timeline = timeline
    }
    
    func buildComposition() -> Composition? {
        composition = AVMutableComposition()
        if timeline.videos?.count ?? 0 > 0 {
            addCompositionOfType(mediaType: .video, with: timeline.videos as! [MediaItem])
        }
        if timeline.voiceOvers?.count ?? 0 > 0 {
            addCompositionOfType(mediaType: .audio, with: timeline.voiceOvers as! [MediaItem])
        }
        if timeline.musicItems?.count ?? 0 > 0 {
            addCompositionOfType(mediaType: .audio, with: timeline.musicItems as! [MediaItem])
        }
        return BasicComposition(composition: composition)
    }
    
    func addCompositionOfType(mediaType: AVMediaType, with mediaItems: [MediaItem]) {
        if mediaItems.count > 0 {
            let trackID = kCMPersistentTrackID_Invalid
            let compositionTrack = composition.addMutableTrack(withMediaType: mediaType, preferredTrackID: trackID)
            var cursorTime: CMTime? = CMTime.zero
            for item in mediaItems {
                if item.startTimeInTimeLine != CMTime.invalid {
                    cursorTime = item.startTimeInTimeLine
                }
                guard let assetTrack = item.asset?.tracks(withMediaType: mediaType).first else { continue }
                try! compositionTrack?.insertTimeRange(item.timeRange!, of: assetTrack, at: cursorTime!)
                cursorTime = CMTimeAdd(cursorTime!, item.timeRange?.duration ?? .zero)
            }
            
            
            
        }
    }
}
