//
//  VideoItem.swift
//  FifteenSeconds_Swift
//
//  Copyright © 2020 zxf. All rights reserved.
//

import Foundation
import UIKit
import CoreMedia
import AVFoundation

let THUMBNAIL_COUNT: Int = 4
let ITEM_THUMBNAIL_SIZE: CGSize = CGSize(width: 227, height: 128)

class VideoItem: MediaItem {
    var thumbnails: [UIImage]?
    
    var startTransition: VideoTransition?
    var endTransition: VideoTransition?
    
    override var mediaType: AVMediaType? {
        get {
            return AVMediaType.video
        }
    }

    
    var playThroughTimeRange: CMTimeRange? {
        get {
            return getPlayThroughRange()
        }
    }
    var startTransitionTimeRange: CMTimeRange? {
        get {
            if startTransition != nil && startTransition?.type != VideoTransitionType.none {
                return CMTimeRangeMake(start: .zero, duration: startTransition?.duration ?? .zero)
            }
            return CMTimeRangeMake(start: .zero, duration: .zero)
        }
    }
    var endTransitionTimeRange: CMTimeRange? {
        get {
            if endTransition != nil && endTransition?.type != VideoTransitionType.none {
                return CMTimeRangeMake(start: CMTimeSubtract(timeRange?.duration ?? .zero,
                                                             endTransition?.duration ?? .zero),
                                       duration: endTransition?.duration ?? .zero)
                
            }
            return CMTimeRangeMake(start: .zero, duration: .zero)
        }
    }
    
    
    private var imageGenerator: AVAssetImageGenerator?
    private var images: [UIImage]?
    
    
    override init(url: URL) {
        super.init(url: url)
        imageGenerator = AVAssetImageGenerator(asset: asset ?? AVAsset())
        imageGenerator?.maximumSize = ITEM_THUMBNAIL_SIZE
        thumbnails = []
        images = [UIImage]()
        
    }
    
    func getPlayThroughRange() -> CMTimeRange {
        guard var timerange = timeRange else  {return CMTimeRangeMake(start: .zero, duration: .zero)}
        if startTransition != nil && startTransition?.type != VideoTransitionType.none {
            timerange.start = CMTimeAdd(timerange.start , startTransition?.duration ?? .zero)
            timerange.duration = CMTimeSubtract(timerange.duration, startTransition?.duration ?? .zero)
        }
        if endTransition != nil && endTransition?.type != VideoTransitionType.none {
            timerange.duration = CMTimeSubtract(timerange.duration, endTransition?.duration ?? .zero)
        }
        return timerange
    }
    
    override func performPostPrepareActionsWithCompletionBlock(completionBlock: @escaping PreparationCompleteBlock) {
        DispatchQueue.global(qos: .default)
            .async {[weak self] in
                guard let strongSelf = self else {return}
                strongSelf.generateThumbnails(with: completionBlock)
                
        }
    }
    
    func generateThumbnails(with completionBlock: @escaping PreparationCompleteBlock) {
        guard let duration = asset?.duration else {return}
        let intervalsSeconds = duration.value / Int64(THUMBNAIL_COUNT)
        var time = CMTime.zero
        var times = [NSValue]()
        for _ in 0..<THUMBNAIL_COUNT {
            times.append(NSValue(time: time))
            time = CMTimeAdd(time, CMTime(seconds: Double(intervalsSeconds), preferredTimescale: duration.timescale))
        }
        
        imageGenerator?.generateCGImagesAsynchronously(forTimes: times,
                                                       completionHandler: { [weak self] (requestTime, image, absolateTime, result, error) in
                                                        guard let strongSelf = self else {return}
                                                        if image != nil {
                                                            let resultImage = UIImage(cgImage: image!)
                                                            strongSelf.images?.append(resultImage)
                                                        } else {
                                                            strongSelf.images?.append(UIImage(named: "video_thumbnail")!)
                                                        }
                                                        if strongSelf.images?.count == THUMBNAIL_COUNT {
                                                            strongSelf.thumbnails = strongSelf.images
                                                            DispatchQueue.main.async {[weak strongSelf] in
                                                                completionBlock(true)
                                                            }
                                                        }
        })
        
    }
    
    
}
