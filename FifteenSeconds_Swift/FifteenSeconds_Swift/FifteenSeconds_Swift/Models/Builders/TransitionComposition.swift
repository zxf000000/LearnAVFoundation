//
//  TransitionComposition.swift
//  FifteenSeconds_Swift
//
//  Created by mr.zhou on 2020/4/25.
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation

class TransitionComposition: Composition {
    
    var composition: AVComposition!
    var videoComposition: AVVideoComposition!
    var audioMix: AVAudioMix!
    
    init(composition: AVComposition, videoComposition: AVVideoComposition, audioMix: AVAudioMix) {
        self.composition = composition
        self.videoComposition = videoComposition
        self.audioMix = audioMix
    }
    
    func makePlayable() -> AVPlayerItem? {
        let playerItem = AVPlayerItem(asset: composition)
        playerItem.audioMix = audioMix
        playerItem.videoComposition = videoComposition
        return playerItem
    }
    
    func makeExportable() -> AVAssetExportSession? {
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.audioMix = audioMix
        exportSession?.videoComposition = videoComposition
        return exportSession
    }
    
    
}
