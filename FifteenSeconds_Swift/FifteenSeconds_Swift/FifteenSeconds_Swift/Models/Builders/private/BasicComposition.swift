//
//  BasicComposition.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation

protocol Composition {
    func makePlayable() -> AVPlayerItem?
    func makeExportable() -> AVAssetExportSession?
}

class BasicComposition: Composition {
    
    var composition: AVComposition!
    
    init(composition: AVComposition) {
        self.composition = composition
    }
    
    func makePlayable() -> AVPlayerItem? {
        return AVPlayerItem(asset: composition)
    }
    
    func makeExportable() -> AVAssetExportSession? {
        let preset = AVAssetExportPresetHighestQuality
        return AVAssetExportSession(asset: composition,
                                    presetName: preset)
    }
    
    
}
