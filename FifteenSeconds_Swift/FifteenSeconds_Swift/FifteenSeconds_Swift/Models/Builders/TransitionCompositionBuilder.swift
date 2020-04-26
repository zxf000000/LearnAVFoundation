//
//  TransitionCompositionBuilder.swift
//  FifteenSeconds_Swift
//
//  Created by mr.zhou on 2020/4/25.
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation

class TransitionCompositionBuilder: CompositionBuilder {
    
    var timeline: TimeLine!
    var composition: AVMutableComposition!
    var musicTrack: AVMutableCompositionTrack!
    
    init(timeline: TimeLine) {
        self.timeline = timeline
    }
    
    func buildComposition() -> Composition? {
        composition = AVMutableComposition()
        buildCompositionTracks()
        let videoComposition = buildVideoComposition()
        let audioMix = buildAudioMix()
        return TransitionComposition(composition: composition, videoComposition: videoComposition, audioMix: audioMix!)
    }
    
    func buildAudioMix() -> AVAudioMix? {
        guard let items = timeline.musicItems else {return nil}
        if items.count == 0 {
            let audioItem = items[0] as! AudioItem
            let audioMix = AVMutableAudioMix()
            let parameters = AVMutableAudioMixInputParameters(track: musicTrack)
            for automation in audioItem.volumnAutomation ?? [] {
                parameters.setVolumeRamp(fromStartVolume: Float(automation.startVolume),
                                         toEndVolume: Float(automation.endVolume),
                                         timeRange: automation.timeRange)
            }
            audioMix.inputParameters = [parameters]
            return audioMix
        }
        return nil
    }
    
    func buildCompositionTracks() {
        let trackID = kCMPersistentTrackID_Invalid
        let compositionTrackA = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackID)
        let compostitionTrackB = composition.addMutableTrack(withMediaType: .video, preferredTrackID: trackID)
        let tracks = [compositionTrackA, compostitionTrackB]
        var cursorTime = CMTime.zero
        var duration = CMTime.zero
        if timeline.transitons?.count ?? 0 > 0 {
            duration = DefaultTransitionDuration
        }
        let videos = timeline.videos as? [VideoItem]
        for (index, video) in (videos ?? []).enumerated() {
            let trackIndex = index % 2
            let currentTrack = tracks[trackIndex]
            let assetTrack = video.asset?.tracks(withMediaType: .video).first
            try! currentTrack?.insertTimeRange(video.timeRange ?? .zero, of: assetTrack!, at: cursorTime)
            cursorTime = CMTimeAdd(cursorTime, video.timeRange?.duration ?? .zero)
            cursorTime = CMTimeSubtract(cursorTime, duration)
        }
        let _ = addComposition(of: .video, with: timeline.voiceOvers as! [MediaItem])
        let musicItems = timeline.musicItems
        musicTrack = addComposition(of: .audio, with: musicItems as! [MediaItem])
    }
    
    func buildVideoComposition() -> AVVideoComposition {
        let videoComposition = AVMutableVideoComposition(propertiesOf: composition)
        let transitionInstructions = transitionInstructionsInVideoComposition(composition: videoComposition)
        for transitionInstruction in transitionInstructions {
            let timeRange = transitionInstruction.compositionInstruction?.timeRange
            let fromLayer = transitionInstruction.fromLayerInstruction
            let toLayer = transitionInstruction.toLayerInstruction
            let type =  transitionInstruction.videoTransition?.type
            if type == VideoTransitionType.dissolve {
                fromLayer?.setOpacityRamp(fromStartOpacity: 1, toEndOpacity: 0, timeRange: timeRange!)
            }
            
            if type == VideoTransitionType.push {
                let identityTransform = CGAffineTransform.identity
                let videoWidth = videoComposition.renderSize.width
                let fromDestTransform =  CGAffineTransform(translationX: -videoWidth, y: 0)
                let toStartTransform = CGAffineTransform(translationX: videoWidth, y: 0)
                fromLayer?.setTransformRamp(fromStart: identityTransform, toEnd: fromDestTransform, timeRange: timeRange!)
                toLayer?.setTransformRamp(fromStart: toStartTransform, toEnd: identityTransform, timeRange: timeRange!)
            }
            
            if type == VideoTransitionType.wipe {
                let videowidth = videoComposition.renderSize.width
                let videoHeight = videoComposition.renderSize.height
                
                let startRect = CGRect(x: 0, y: 0, width: videowidth, height: videoHeight)
                let endRect = CGRect(x: 0, y: videoHeight, width: videowidth, height: 0)
                
                fromLayer?.setCropRectangleRamp(fromStartCropRectangle: startRect, toEndCropRectangle: endRect, timeRange: timeRange!)
            }
            transitionInstruction.compositionInstruction?.layerInstructions = [fromLayer!, toLayer!]
        }
        return videoComposition
    }
    
    func transitionInstructionsInVideoComposition(composition: AVVideoComposition) -> [TransitionInstructions] {
        var transitionInstructions = [TransitionInstructions]()
        var layerInstructionIndex = 1
        let compositionInstructions = composition.instructions as! [AVMutableVideoCompositionInstruction]
        for vci in compositionInstructions {
            if vci.layerInstructions.count == 2 {
                let instructions = TransitionInstructions()
                instructions.compositionInstruction = vci
                instructions.fromLayerInstruction = vci.layerInstructions[1 - layerInstructionIndex] as? AVMutableVideoCompositionLayerInstruction
                instructions.toLayerInstruction = vci.layerInstructions[layerInstructionIndex] as? AVMutableVideoCompositionLayerInstruction
                
                transitionInstructions.append(instructions)
                layerInstructionIndex = layerInstructionIndex == 1 ? 0 : 1
            }
        }
        let transitions = timeline.transitons
        if transitions?.count ?? 0 == 0 {
            return transitionInstructions
        }
        for (index, trans) in transitionInstructions.enumerated() {
            trans.videoTransition = timeline.transitons?[index] as! VideoTransition
        }
        return transitionInstructions
    }
    
    func addComposition(of type: AVMediaType, with mediaItems: [MediaItem]) -> AVMutableCompositionTrack {
        var compositionTrack: AVMutableCompositionTrack? = nil
        if mediaItems.count > 0 {
            compositionTrack = composition.addMutableTrack(withMediaType: type, preferredTrackID: kCMPersistentTrackID_Invalid)
            var cursorTime = CMTime.zero
            for item in mediaItems {
                if item.startTimeInTimeLine != .invalid {
                    cursorTime = item.startTimeInTimeLine ?? .zero
                }
                let assetTrack = item.asset?.tracks(withMediaType: type).first
                try! compositionTrack?.insertTimeRange(item.timeRange ?? .zero, of: assetTrack!, at: cursorTime)
                cursorTime = CMTimeAdd(cursorTime, item.timeRange?.duration ?? .zero)
                
            }
        }
        return compositionTrack!
    }
    
    
}
