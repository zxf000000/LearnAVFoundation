//
//  AudioMixCompositionBuilder.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation

class AudioMixCompositonBuilder: CompositionBuilder {
    private var timeline: TimeLine!
    private var composition: AVMutableComposition!
    func buildComposition() -> Composition? {
        composition = AVMutableComposition()
        let _ = addCompositionTrack(of: .video, items: timeline.videos as! [MediaItem])
        let _ = addCompositionTrack(of: .audio, items: timeline.voiceOvers as! [MediaItem])
        let musicTrack = addCompositionTrack(of: .audio, items: timeline.musicItems as! [MediaItem])
        let audioMix = buildAudioMix(with: musicTrack!)
        
        return AudioMixComposition(composition: composition, audioMix: audioMix!)
    }
    
    func addCompositionTrack(of type: AVMediaType, items: [MediaItem]) -> AVMutableCompositionTrack? {
        if items.count > 0 {
            let trackID = kCMPersistentTrackID_Invalid
            let track = composition.addMutableTrack(withMediaType: type, preferredTrackID: trackID)
            var cursorTime = CMTime.zero
            for item in items {
                if item.startTimeInTimeLine != CMTime.invalid {
                    cursorTime = item.startTimeInTimeLine ?? .zero
                }
                let assetTrack = item.asset?.tracks(withMediaType: type).first
                try! track?.insertTimeRange((item.timeRange)!, of: assetTrack!, at: cursorTime)
                cursorTime = CMTimeAdd(cursorTime, item.timeRange?.duration ?? .zero)
            }
            return track
        }
        return nil
    }
    
    func buildAudioMix(with track: AVMutableCompositionTrack) -> AVAudioMix? {
        let item = timeline.musicItems?.first as? AudioItem
        if item != nil {
            let audioMix = AVMutableAudioMix()
            let parameters = AVMutableAudioMixInputParameters(track: track)
            for automation in item?.volumnAutomation ?? [] {
                parameters.setVolumeRamp(fromStartVolume: Float(automation.startVolume), toEndVolume: Float(automation.endVolume), timeRange: automation.timeRange)
            }
            audioMix.inputParameters = [parameters]
            return audioMix
        }
        return nil
    }
    
    init(timeline: TimeLine) {
        self.timeline = timeline
    }
}
