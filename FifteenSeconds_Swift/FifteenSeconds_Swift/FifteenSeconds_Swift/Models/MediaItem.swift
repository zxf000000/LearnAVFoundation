//
//  MediaItem.swift
//  FifteenSeconds_Swift
//
//  Created by 壹九科技1 on 2020/4/22.
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation
import CoreMedia
import AVFoundation

typealias PreparationCompleteBlock = (Bool) -> Void

let AVAssetTracksKey = "tracks";
let AVAssetDurationKey = "duration";
let AVAssetCommonMetadataKey = "commonMetadata";

class MediaItem: TimeLineItem {
    var asset: AVAsset?
    var prepared: Bool? = false
    var mediaType: AVMediaType? {
        get {
            return AVMediaType.video
        }
    }
    
    var _title: String?
    
    var title: String? {
        set {
            _title = newValue
        }
        get {
            if _title == nil {
                guard let metadatas = asset?.commonMetadata else {return nil}
                for metadataItem in metadatas {
                    if metadataItem.commonKey == AVMetadataKey.commonKeyTitle {
                        _title = metadataItem.stringValue
                        break
                    }
                }
            }
            if _title == nil {
                _title = fileName
            }
            return _title
        }
    }
    
    
    private var fileName: String?
    private var url: URL?
    
    init(url: URL) {
        super.init()
        self.url = url
        self.fileName = url.lastPathComponent
        self.asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
    }

    
    func prepare(with completionBlock: @escaping PreparationCompleteBlock) {
        asset?.loadValuesAsynchronously(forKeys: [AVAssetDurationKey, AVAssetTracksKey, AVAssetCommonMetadataKey],
                                        completionHandler: { [weak self] in
                                            guard let strongSelf = self else {return}
                                            let trackStatus = strongSelf.asset?.statusOfValue(forKey: AVAssetTracksKey, error: nil)
                                            let durationStatus = strongSelf.asset?.statusOfValue(forKey: AVAssetDurationKey, error: nil)
                                            strongSelf.prepared = (trackStatus == AVKeyValueStatus.loaded && durationStatus == AVKeyValueStatus.loaded)
                                            if strongSelf.prepared == true {
                                                strongSelf.timeRange = CMTimeRange(start: .zero, duration: strongSelf.asset?.duration ?? .zero)
                                                strongSelf.performPostPrepareActionsWithCompletionBlock(completionBlock: completionBlock)
                                            } else {
                                                completionBlock(false)
                                            }
        })
    }
    
    func performPostPrepareActionsWithCompletionBlock(completionBlock: @escaping PreparationCompleteBlock) {
        completionBlock(prepared!)
    }
    
    func isTrimmed() -> Bool {
        if self.prepared == false {
            return false
        }
        return CMTimeCompare(timeRange?.duration ?? .zero, asset?.duration ?? .zero) < 0
    }
    
    func makePlayable() -> AVPlayerItem {
        return AVPlayerItem(asset: asset ?? AVAsset())
    }
    
    
    
    
}
