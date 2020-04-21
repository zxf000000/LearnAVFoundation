//
//  AVCaptureDevice+Additions.swift
//  CaptureDemo
//
//  Created by 壹九科技1 on 2020/4/15.
//  Copyright © 2020 zxf. All rights reserved.
//

import AVFoundation
import UIKit

extension AVCaptureDevice {
    func supportsHighFrameRateCapture() -> Bool {
        if hasMediaType(.video) == false {
            return false
        }
        return findHighestQualityOfService().isHightFrameRate
    }
    
    func findHighestQualityOfService() -> QualityOfService {
        var maxFormat: AVCaptureDevice.Format? = nil
        var maxFrameRateRange: AVFrameRateRange? = nil
        for format in formats {
            /// 遍历所有捕捉设备的支持 formats 并对每一个元素从 fromatDescription 中获取相应的
            /// codecType(mediaSubType), 只需要 420YpCbCr8BiPlanarVideoRange 这个格式,筛选出视频格式
            var codecType: FourCharCode? = nil
            if #available(iOS 13.0, *) {
                codecType = format.formatDescription.mediaSubType.rawValue
            } else {
                // Fallback on earlier versions
                codecType = CMFormatDescriptionGetMediaSubType(format.formatDescription)
            }
            if codecType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange {
                let frameRateRanges = format.videoSupportedFrameRateRanges
                for range in frameRateRanges {
                    if range.maxFrameRate > maxFrameRateRange?.maxFrameRate ?? 0 {
                        maxFormat = format
                        maxFrameRateRange = range
                    }
                }
            }
        }
        return QualityOfService(format: maxFormat, frameRateRange: maxFrameRateRange)
    }
    
    func enabledHightFrameRateCapture() -> Bool {
        let qos = findHighestQualityOfService()
        if qos.isHightFrameRate == false {
            let minFrameDuration = qos.frameRateRange.minFrameDuration
            do {
                try lockForConfiguration()
                // 设备的 activitFormat 属性设置为 qos 的format
                activeFormat = qos.format
                // 最小帧时长和最大帧时长都设置为 qos.frameRateRange 的minFrameDuration
                activeVideoMinFrameDuration = minFrameDuration
                activeVideoMaxFrameDuration = minFrameDuration
                unlockForConfiguration()
            } catch {
                return false
            }
        }
        return true
    }
}


class QualityOfService {
    var format: AVCaptureDevice.Format!
    var frameRateRange: AVFrameRateRange!
    var isHightFrameRate: Bool!

    init(format: AVCaptureDevice.Format?, frameRateRange: AVFrameRateRange?) {
        self.format = format
        self.frameRateRange = frameRateRange
    }
    
    func isHighFrameRate() -> Bool {
        return frameRateRange.maxFrameRate > 30
    }
}
