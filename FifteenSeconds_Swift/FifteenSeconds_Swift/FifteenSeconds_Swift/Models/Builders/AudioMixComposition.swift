//
//  AudioMixComposition.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation

class AudioMixComposition: Composition {

    
    var audioMix: AVAudioMix!
    var composition: AVComposition!
    
    init(composition: AVComposition, audioMix: AVAudioMix) {
        self.composition = composition
        self.audioMix = audioMix
    }
    
    func makePlayable() -> AVPlayerItem? {
        let playerItem = AVPlayerItem(asset: composition)
        playerItem.audioMix = audioMix
        return playerItem
    }
    
    func makeExportable() -> AVAssetExportSession? {
        let preset = AVAssetExportPresetHighestQuality
        let session = AVAssetExportSession(asset: composition, presetName: preset)
        session?.audioMix = audioMix
        return session!
    }
    
}
